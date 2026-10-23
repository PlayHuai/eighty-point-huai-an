package coordinator

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"reflect"
	"strings"
	"sync"
	"time"
)

var (
	ErrInvalidAction     = errors.New("invalid game action")
	ErrVersionConflict   = errors.New("game state version conflict")
	ErrRequestConflict   = errors.New("request ID was already used for a different action")
	ErrTimeoutNotReached = errors.New("disconnect grace period has not elapsed")
	ErrGameNotActive     = errors.New("game session is not active")
)

type Action struct {
	SessionID       string          `json:"session_id"`
	HandID          string          `json:"hand_id,omitempty"`
	RequestID       string          `json:"request_id,omitempty"`
	ExpectedVersion uint64          `json:"expected_version"`
	ActorID         string          `json:"actor_id"`
	Type            string          `json:"type"`
	Payload         json.RawMessage `json:"payload"`
}

type Rules interface {
	Apply(context.Context, GameState, Action) (GameState, error)
	Autoplay(context.Context, GameState, string) (Action, error)
}

type ActionResult struct {
	State     GameState
	Duplicate bool
}

type automationPayload struct {
	Actor            string `json:"actor"`
	Reason           string `json:"reason"`
	ControlledUserID string `json:"controlled_user_id"`
	Action           Action `json:"action"`
}

type Coordinator struct {
	repository Repository
	rules      Rules

	mu        sync.Mutex
	states    map[string]GameState
	roomLocks map[string]*sync.Mutex
	loadLocks map[string]*sync.Mutex
}

func New(repository Repository, rules Rules) (*Coordinator, error) {
	if repository == nil || rules == nil {
		return nil, errors.New("game repository and rules are required")
	}
	return &Coordinator{
		repository: repository,
		rules:      rules,
		states:     make(map[string]GameState),
		roomLocks:  make(map[string]*sync.Mutex),
		loadLocks:  make(map[string]*sync.Mutex),
	}, nil
}

func (c *Coordinator) Recover(ctx context.Context, sessionID string) (RecoveryState, error) {
	if strings.TrimSpace(sessionID) == "" {
		return RecoveryState{}, ErrInvalidAction
	}
	recovery, err := c.repository.LoadRecoveryState(ctx, sessionID)
	if err != nil {
		return RecoveryState{}, err
	}
	if recovery.SessionID != sessionID || recovery.RoomID == "" ||
		(recovery.Status != "ACTIVE" && recovery.Status != "ABORTED" && recovery.Status != "SETTLED") {
		return RecoveryState{}, errors.New("invalid recovered game state")
	}
	lock := c.roomLock(recovery.RoomID)
	lock.Lock()
	defer lock.Unlock()
	recovery, err = c.repository.LoadRecoveryState(ctx, sessionID)
	if err != nil {
		return RecoveryState{}, err
	}
	if recovery.SessionID != sessionID || recovery.RoomID == "" ||
		(recovery.Status != "ACTIVE" && recovery.Status != "ABORTED" && recovery.Status != "SETTLED") {
		return RecoveryState{}, errors.New("invalid recovered game state")
	}
	c.mu.Lock()
	c.states[sessionID] = cloneState(recovery.GameState)
	c.mu.Unlock()
	recovery.Events = cloneEvents(recovery.Events)
	recovery.Snapshot = append([]byte(nil), recovery.Snapshot...)
	return recovery, nil
}

func (c *Coordinator) SubmitAction(ctx context.Context, action Action) (ActionResult, error) {
	if err := validateAction(action, true); err != nil {
		return ActionResult{}, err
	}
	return c.process(ctx, action, action.Type, action.ActorID, mustJSON(action), action.RequestID)
}

func (c *Coordinator) HandleDisconnectTimeout(
	ctx context.Context,
	sessionID, userID, handID string,
	expectedVersion uint64,
	disconnectedAt, now time.Time,
	gracePeriod time.Duration,
) (ActionResult, error) {
	if sessionID == "" || userID == "" || gracePeriod <= 0 || disconnectedAt.IsZero() || now.IsZero() {
		return ActionResult{}, ErrInvalidAction
	}
	if now.Before(disconnectedAt.Add(gracePeriod)) {
		return ActionResult{}, ErrTimeoutNotReached
	}
	requestID := fmt.Sprintf("autoplay:%d:%s", expectedVersion, userID)
	if len(requestID) > 128 {
		return ActionResult{}, ErrInvalidAction
	}
	state, err := c.loadState(ctx, sessionID)
	if err != nil {
		return ActionResult{}, err
	}
	lock := c.roomLock(state.RoomID)
	lock.Lock()
	defer lock.Unlock()
	state, err = c.loadState(ctx, sessionID)
	if err != nil {
		return ActionResult{}, err
	}
	previous, findErr := c.repository.FindGameEventByRequest(ctx, sessionID, requestID)
	if findErr == nil {
		var audit automationPayload
		if previous.Type != "AUTOPLAY" || previous.ActorID != "" || previous.HandID != handID ||
			json.Unmarshal(previous.Payload, &audit) != nil || audit.Actor != "SERVER" ||
			audit.Reason != "disconnect_timeout" || audit.ControlledUserID != userID ||
			audit.Action.SessionID != sessionID || audit.Action.ExpectedVersion != expectedVersion {
			return ActionResult{}, ErrRequestConflict
		}
		state, err := c.loadDurableState(ctx, sessionID)
		if err != nil {
			return ActionResult{}, err
		}
		return ActionResult{State: state, Duplicate: true}, nil
	}
	if !errors.Is(findErr, ErrEventNotFound) {
		return ActionResult{}, findErr
	}
	if state.Status != "ACTIVE" {
		return ActionResult{}, ErrGameNotActive
	}
	if state.Version != expectedVersion {
		return ActionResult{}, ErrVersionConflict
	}
	action, err := c.rules.Autoplay(ctx, state, userID)
	if err != nil {
		return ActionResult{}, err
	}
	action.SessionID = sessionID
	action.HandID = handID
	action.ExpectedVersion = expectedVersion
	action.ActorID = userID
	if err := validateAction(action, false); err != nil {
		return ActionResult{}, err
	}
	payload, err := json.Marshal(automationPayload{
		Actor: "SERVER", Reason: "disconnect_timeout", ControlledUserID: userID, Action: action,
	})
	if err != nil {
		return ActionResult{}, err
	}
	return c.processLocked(ctx, action, "AUTOPLAY", "", payload, requestID)
}

func (c *Coordinator) EventsAfter(ctx context.Context, sessionID string, seq uint64, limit uint32) ([]GameEvent, error) {
	if strings.TrimSpace(sessionID) == "" || limit == 0 || limit > 500 {
		return nil, ErrInvalidAction
	}
	events, err := c.repository.LoadGameEventsAfter(ctx, sessionID, seq, limit)
	if err != nil {
		return nil, err
	}
	return cloneEvents(events), nil
}

func (c *Coordinator) process(
	ctx context.Context,
	action Action,
	eventType, eventActor string,
	eventPayload []byte,
	requestID string,
) (ActionResult, error) {
	state, err := c.loadState(ctx, action.SessionID)
	if err != nil {
		return ActionResult{}, err
	}
	lock := c.roomLock(state.RoomID)
	lock.Lock()
	defer lock.Unlock()
	return c.processLocked(ctx, action, eventType, eventActor, eventPayload, requestID)
}

func (c *Coordinator) processLocked(
	ctx context.Context,
	action Action,
	eventType, eventActor string,
	eventPayload []byte,
	requestID string,
) (ActionResult, error) {
	state, err := c.loadState(ctx, action.SessionID)
	if err != nil {
		return ActionResult{}, err
	}
	if requestID != "" {
		event, findErr := c.repository.FindGameEventByRequest(ctx, action.SessionID, requestID)
		if findErr == nil {
			if event.Type != eventType || event.ActorID != eventActor || event.HandID != action.HandID ||
				!equalJSON(event.Payload, eventPayload) {
				return ActionResult{}, ErrRequestConflict
			}
			state, err := c.loadDurableState(ctx, action.SessionID)
			if err != nil {
				return ActionResult{}, err
			}
			return ActionResult{State: state, Duplicate: true}, nil
		}
		if !errors.Is(findErr, ErrEventNotFound) {
			return ActionResult{}, findErr
		}
	}
	if state.Status != "ACTIVE" {
		return ActionResult{}, ErrGameNotActive
	}
	if action.ExpectedVersion != state.Version {
		return ActionResult{}, ErrVersionConflict
	}
	next, err := c.rules.Apply(ctx, cloneState(state), action)
	if err != nil {
		return ActionResult{}, err
	}
	if next.SessionID != state.SessionID || next.RoomID != state.RoomID ||
		(next.Status != "ACTIVE" && next.Status != "ABORTED") || state.Version == ^uint64(0) {
		return ActionResult{}, ErrInvalidAction
	}
	next.Version = state.Version + 1
	event := GameEvent{
		SessionID: state.SessionID,
		HandID:    action.HandID,
		Type:      eventType,
		Payload:   append([]byte(nil), eventPayload...),
		ActorID:   eventActor,
		RequestID: requestID,
	}
	if err := c.repository.CommitGameUpdate(ctx, state.Version, next, event); err != nil {
		if errors.Is(err, ErrVersionConflict) {
			return ActionResult{}, ErrVersionConflict
		}
		return ActionResult{}, err
	}
	c.mu.Lock()
	c.states[action.SessionID] = cloneState(next)
	c.mu.Unlock()
	return ActionResult{State: cloneState(next)}, nil
}

func (c *Coordinator) loadState(ctx context.Context, sessionID string) (GameState, error) {
	c.mu.Lock()
	if state, ok := c.states[sessionID]; ok {
		c.mu.Unlock()
		return cloneState(state), nil
	}
	loadLock := c.loadLocks[sessionID]
	if loadLock == nil {
		loadLock = &sync.Mutex{}
		c.loadLocks[sessionID] = loadLock
	}
	c.mu.Unlock()

	loadLock.Lock()
	defer loadLock.Unlock()
	c.mu.Lock()
	if state, ok := c.states[sessionID]; ok {
		c.mu.Unlock()
		return cloneState(state), nil
	}
	c.mu.Unlock()

	recovery, err := c.repository.LoadRecoveryState(ctx, sessionID)
	if err != nil {
		return GameState{}, err
	}
	if recovery.SessionID != sessionID || recovery.RoomID == "" ||
		(recovery.Status != "ACTIVE" && recovery.Status != "ABORTED" && recovery.Status != "SETTLED") {
		return GameState{}, errors.New("invalid recovered game state")
	}
	state := cloneState(recovery.GameState)
	c.mu.Lock()
	if cached, ok := c.states[sessionID]; ok {
		c.mu.Unlock()
		return cloneState(cached), nil
	}
	c.states[sessionID] = state
	c.mu.Unlock()
	return cloneState(state), nil
}

func (c *Coordinator) loadDurableState(ctx context.Context, sessionID string) (GameState, error) {
	recovery, err := c.repository.LoadRecoveryState(ctx, sessionID)
	if err != nil {
		return GameState{}, err
	}
	if recovery.SessionID != sessionID || recovery.RoomID == "" ||
		(recovery.Status != "ACTIVE" && recovery.Status != "ABORTED" && recovery.Status != "SETTLED") {
		return GameState{}, errors.New("invalid recovered game state")
	}
	state := cloneState(recovery.GameState)
	c.mu.Lock()
	c.states[sessionID] = state
	c.mu.Unlock()
	return cloneState(state), nil
}

func (c *Coordinator) roomLock(roomID string) *sync.Mutex {
	c.mu.Lock()
	defer c.mu.Unlock()
	lock := c.roomLocks[roomID]
	if lock == nil {
		lock = &sync.Mutex{}
		c.roomLocks[roomID] = lock
	}
	return lock
}

func validateAction(action Action, requireRequestID bool) error {
	if strings.TrimSpace(action.SessionID) == "" || strings.TrimSpace(action.ActorID) == "" ||
		strings.TrimSpace(action.Type) == "" || !json.Valid(action.Payload) ||
		(requireRequestID && strings.TrimSpace(action.RequestID) == "") ||
		len(action.RequestID) > 128 ||
		(requireRequestID && hasServerRequestIDPrefix(action.RequestID)) {
		return ErrInvalidAction
	}
	return nil
}

func hasServerRequestIDPrefix(requestID string) bool {
	const prefix = "autoplay:"
	return len(requestID) >= len(prefix) && strings.EqualFold(requestID[:len(prefix)], prefix)
}

func mustJSON(action Action) []byte {
	payload, _ := json.Marshal(action)
	return payload
}

func equalJSON(left, right []byte) bool {
	decode := func(payload []byte) (any, error) {
		decoder := json.NewDecoder(strings.NewReader(string(payload)))
		decoder.UseNumber()
		var value any
		if err := decoder.Decode(&value); err != nil {
			return nil, err
		}
		var extra any
		if err := decoder.Decode(&extra); !errors.Is(err, io.EOF) {
			if err == nil {
				return nil, errors.New("multiple JSON values")
			}
			return nil, err
		}
		return value, nil
	}

	leftValue, err := decode(left)
	if err != nil {
		return false
	}
	rightValue, err := decode(right)
	return err == nil && reflect.DeepEqual(leftValue, rightValue)
}

func cloneState(state GameState) GameState {
	state.Snapshot = append([]byte(nil), state.Snapshot...)
	return state
}

func cloneEvents(events []GameEvent) []GameEvent {
	result := make([]GameEvent, len(events))
	for i, event := range events {
		result[i] = event
		result[i].Payload = append([]byte(nil), event.Payload...)
	}
	return result
}
