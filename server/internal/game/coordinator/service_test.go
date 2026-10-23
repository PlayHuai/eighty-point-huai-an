package coordinator

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"sync"
	"testing"
	"time"
)

type memoryRepository struct {
	mu     sync.Mutex
	states map[string]GameState
	events map[string][]GameEvent
}

func newMemoryRepository() *memoryRepository {
	return &memoryRepository{
		states: map[string]GameState{
			"session-1": {
				SessionID: "session-1", RoomID: "room-1", Status: "ACTIVE",
				Snapshot: []byte(`{"turn":0}`),
			},
		},
		events: make(map[string][]GameEvent),
	}
}

func (r *memoryRepository) CommitGameUpdate(_ context.Context, expectedVersion uint64, state GameState, event GameEvent) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	current := r.states[state.SessionID]
	if current.Version != expectedVersion {
		return ErrVersionConflict
	}
	state.Version = expectedVersion + 1
	event.Seq = state.Version
	r.states[state.SessionID] = cloneState(state)
	r.events[state.SessionID] = append(r.events[state.SessionID], event)
	return nil
}

func (r *memoryRepository) LoadRecoveryState(_ context.Context, sessionID string) (RecoveryState, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	state, ok := r.states[sessionID]
	if !ok {
		return RecoveryState{}, errors.New("session not found")
	}
	return RecoveryState{GameState: cloneState(state)}, nil
}

func (r *memoryRepository) FindGameEventByRequest(_ context.Context, sessionID, requestID string) (GameEvent, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	for _, event := range r.events[sessionID] {
		if event.RequestID == requestID {
			return event, nil
		}
	}
	return GameEvent{}, ErrEventNotFound
}

func (r *memoryRepository) LoadGameEventsAfter(_ context.Context, sessionID string, seq uint64, limit uint32) ([]GameEvent, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	events := make([]GameEvent, 0)
	for _, event := range r.events[sessionID] {
		if event.Seq > seq {
			events = append(events, event)
			if len(events) == int(limit) {
				break
			}
		}
	}
	return cloneEvents(events), nil
}

type testRules struct{}

func (testRules) Apply(_ context.Context, state GameState, action Action) (GameState, error) {
	next := cloneState(state)
	next.Snapshot = []byte(fmt.Sprintf(`{"last_action":%q}`, action.Type))
	return next, nil
}

func (testRules) Autoplay(_ context.Context, _ GameState, _ string) (Action, error) {
	return Action{Type: "PLAY_CARDS", Payload: json.RawMessage(`{"cards":["2C"]}`)}, nil
}

func testCoordinator(t *testing.T, repository Repository) *Coordinator {
	t.Helper()
	service, err := New(repository, testRules{})
	if err != nil {
		t.Fatal(err)
	}
	return service
}

func testAction(requestID string) Action {
	return Action{
		SessionID: "session-1", HandID: "hand-1", RequestID: requestID,
		ExpectedVersion: 0, ActorID: "player-1", Type: "PLAY_CARDS",
		Payload: json.RawMessage(`{"cards":["2C"]}`),
	}
}

func TestSubmitActionIsIdempotentAfterRecovery(t *testing.T) {
	repository := newMemoryRepository()
	result, err := testCoordinator(t, repository).SubmitAction(context.Background(), testAction("request-1"))
	if err != nil || result.Duplicate || result.State.Version != 1 {
		t.Fatalf("first action = (%+v, %v)", result, err)
	}

	recovered := testCoordinator(t, repository)
	replay, err := recovered.SubmitAction(context.Background(), testAction("request-1"))
	if err != nil || !replay.Duplicate || replay.State.Version != 1 {
		t.Fatalf("duplicate action = (%+v, %v)", replay, err)
	}
	if _, err := recovered.SubmitAction(context.Background(), func() Action {
		action := testAction("request-1")
		action.Payload = json.RawMessage(`{"cards":["3C"]}`)
		return action
	}()); !errors.Is(err, ErrRequestConflict) {
		t.Fatalf("reusing request ID for another action: got %v", err)
	}
}

func TestConcurrentActionsSerializeByRoom(t *testing.T) {
	repository := newMemoryRepository()
	service := testCoordinator(t, repository)
	var wait sync.WaitGroup
	errs := make(chan error, 2)
	for _, requestID := range []string{"request-a", "request-b"} {
		wait.Add(1)
		go func(requestID string) {
			defer wait.Done()
			_, err := service.SubmitAction(context.Background(), testAction(requestID))
			errs <- err
		}(requestID)
	}
	wait.Wait()
	close(errs)

	successes, conflicts := 0, 0
	for err := range errs {
		switch {
		case err == nil:
			successes++
		case errors.Is(err, ErrVersionConflict):
			conflicts++
		default:
			t.Fatalf("unexpected action error: %v", err)
		}
	}
	if successes != 1 || conflicts != 1 {
		t.Fatalf("successes/conflicts = %d/%d, want 1/1", successes, conflicts)
	}
	events, err := service.EventsAfter(context.Background(), "session-1", 0, 10)
	if err != nil || len(events) != 1 || events[0].Seq != 1 {
		t.Fatalf("event catch-up = (%+v, %v)", events, err)
	}
}

func TestDisconnectTimeoutUsesAuditedServerAction(t *testing.T) {
	repository := newMemoryRepository()
	service := testCoordinator(t, repository)
	disconnectedAt := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)
	if _, err := service.HandleDisconnectTimeout(context.Background(), "session-1", "player-1", "hand-1",
		0, disconnectedAt, disconnectedAt.Add(time.Minute-time.Second), time.Minute); !errors.Is(err, ErrTimeoutNotReached) {
		t.Fatalf("early timeout action: got %v", err)
	}

	result, err := service.HandleDisconnectTimeout(context.Background(), "session-1", "player-1", "hand-1",
		0, disconnectedAt, disconnectedAt.Add(time.Minute), time.Minute)
	if err != nil || result.State.Version != 1 {
		t.Fatalf("timeout action = (%+v, %v)", result, err)
	}
	events, err := service.EventsAfter(context.Background(), "session-1", 0, 10)
	if err != nil || len(events) != 1 || events[0].Type != "AUTOPLAY" || events[0].ActorID != "" {
		t.Fatalf("hosted action event = (%+v, %v)", events, err)
	}
	var audit automationPayload
	if err := json.Unmarshal(events[0].Payload, &audit); err != nil {
		t.Fatal(err)
	}
	if audit.Actor != "SERVER" || audit.Reason != "disconnect_timeout" || audit.ControlledUserID != "player-1" {
		t.Fatalf("missing hosted-action attribution: %+v", audit)
	}
	retry, err := testCoordinator(t, repository).HandleDisconnectTimeout(context.Background(), "session-1",
		"player-1", "hand-1", 0, disconnectedAt, disconnectedAt.Add(time.Minute), time.Minute)
	if err != nil || !retry.Duplicate || retry.State.Version != 1 {
		t.Fatalf("repeated timeout action = (%+v, %v)", retry, err)
	}
}

func TestRecoverRestoresCommittedSnapshotAndEvents(t *testing.T) {
	repository := newMemoryRepository()
	if _, err := testCoordinator(t, repository).SubmitAction(context.Background(), testAction("request-1")); err != nil {
		t.Fatal(err)
	}
	recovery, err := testCoordinator(t, repository).Recover(context.Background(), "session-1")
	if err != nil {
		t.Fatal(err)
	}
	if recovery.Version != 1 || string(recovery.Snapshot) != `{"last_action":"PLAY_CARDS"}` ||
		len(recovery.Events) != 0 {
		t.Fatalf("unexpected recovered game: %+v", recovery)
	}
}
