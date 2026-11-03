package runtime

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"reflect"
	"sync"
	"time"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/settlement"
)

type receipt struct {
	action   Action
	snapshot Snapshot
}

type entry struct {
	state    State
	receipts map[string]receipt
	events   []Event
}

// Event is public action metadata only: private cards and declaration proofs
// must never enter a shared replay log.
type Event struct {
	ID        string
	Sequence  uint64
	HandID    string
	Kind      ActionKind
	CreatedAt time.Time
}

// Repository owns live state and replay. Optional match persistence records
// ordinary match boundaries only; practice sessions never invoke it.
type Repository struct {
	mu          sync.Mutex
	sessions    map[string]*entry
	shuffle     Shuffle
	persistence MatchPersistence
}

type MatchPersistence interface {
	StartLiveMatch(context.Context, State) error
	FinishLiveMatch(context.Context, State) (settlement.MatchResult, error)
}

func NewPersistentRepository(shuffle Shuffle, persistence MatchPersistence) *Repository {
	return &Repository{sessions: make(map[string]*entry), shuffle: shuffle, persistence: persistence}
}

func NewRepository(shuffle Shuffle) *Repository {
	return &Repository{sessions: make(map[string]*entry), shuffle: shuffle}
}

func (r *Repository) Create(config Config) (State, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if _, exists := r.sessions[config.ID]; exists {
		return State{}, ErrExists
	}
	state, err := NewSession(config, r.shuffle)
	if err != nil {
		return State{}, err
	}
	if err := initializeLiveState(&state); err != nil {
		return State{}, err
	}
	if err := r.startPersistent(state); err != nil {
		return State{}, err
	}
	r.sessions[state.ID] = &entry{state: state, receipts: make(map[string]receipt)}
	return clone(state), nil
}

func initializeLiveState(state *State) error {
	var id [16]byte
	if _, err := rand.Read(id[:]); err != nil {
		return err
	}
	state.MatchID = hex.EncodeToString(id[:])
	return scheduleTurn(state, time.Now().UTC())
}

// Load returns server-private state for trusted domain callers, never transport
// clients. Every returned object is a deep copy.
func (r *Repository) Load(id string) (State, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	item, ok := r.sessions[id]
	if !ok {
		return State{}, ErrNotFound
	}
	return clone(item.state), nil
}

func (r *Repository) Snapshot(id, playerID string) (Snapshot, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	item, ok := r.sessions[id]
	if !ok {
		return Snapshot{}, ErrNotFound
	}
	for seat, player := range item.state.Players {
		if player == playerID {
			return View(item.state, seat)
		}
	}
	return Snapshot{}, ErrInvalidAction
}

type Submission struct {
	Snapshot  Snapshot `json:"snapshot"`
	Duplicate bool     `json:"duplicate"`
}

// Submit binds the actor to its authenticated player ID. Retries reuse their
// request ID and original expected version; they return the original private
// snapshot even after subsequent actions. Failed actions reserve no request ID.
func (r *Repository) Submit(id, playerID string, action Action) (Submission, error) {
	return r.submit(id, playerID, "", action)
}

var ErrHand = errors.New("action belongs to another hand")

func (r *Repository) SubmitHand(id, playerID, handID string, action Action) (Submission, error) {
	return r.submit(id, playerID, handID, action)
}

func (r *Repository) submit(id, playerID, handID string, action Action) (Submission, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	item, ok := r.sessions[id]
	if !ok {
		return Submission{}, ErrNotFound
	}
	if action.Seat < 0 || action.Seat > 3 || item.state.Players[action.Seat] != playerID {
		return Submission{}, ErrInvalidAction
	}
	if previous, ok := item.receipts[action.RequestID]; ok {
		if !reflect.DeepEqual(previous.action, action) {
			return Submission{}, ErrRequest
		}
		return Submission{Snapshot: cloneSnapshot(previous.snapshot), Duplicate: true}, nil
	}
	if handID != "" && handID != fmt.Sprintf("%s:%d", id, item.state.HandNumber) {
		return Submission{}, ErrHand
	}
	state, err := Apply(item.state, action, r.shuffle)
	if err != nil {
		return Submission{}, err
	}
	if state.Phase != item.state.Phase {
		state.Deadline = time.Time{}
	}
	if state.Phase == Dealing && item.state.Phase == Dealing {
		// Declarations and autoplay preferences must not restart the deal clock.
	} else if action.Kind != SetAutoplay || (state.Turn == action.Seat && state.Phase != Dealing) {
		if err := scheduleTurn(&state, time.Now().UTC()); err != nil {
			return Submission{}, err
		}
		if state.Phase == Void && r.persistence != nil && !state.Practice {
			store, ok := r.persistence.(interface {
				VoidLiveMatch(context.Context, State) error
			})
			if !ok {
				return Submission{}, errors.New("void match persistence unavailable")
			}
			ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
			err := store.VoidLiveMatch(ctx, state)
			cancel()
			if err != nil {
				return Submission{}, err
			}
		}
	}
	if state.Phase == Finished && !state.Practice && state.HallID != "" {
		requested, err := MatchResult(state)
		if err != nil {
			return Submission{}, err
		}
		for _, change := range requested.Changes {
			if change.Delta > 0 {
				state.Result.NominalPoints = change.Delta
				break
			}
		}
	}
	if state.Phase == Finished && r.persistence != nil && !state.Practice {
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		settled, err := r.persistence.FinishLiveMatch(ctx, state)
		cancel()
		if err != nil {
			return Submission{}, err
		}
		state.Result.PointChanges = settled.Changes
	}
	copied := action
	copied.Cards = append(action.Cards[:0:0], action.Cards...)
	view, err := View(state, action.Seat)
	if err != nil {
		return Submission{}, err
	}
	item.state = state
	item.receipts[action.RequestID] = receipt{action: copied, snapshot: cloneSnapshot(view)}
	item.events = append(item.events, Event{
		ID: action.RequestID, Sequence: state.Version,
		HandID: fmt.Sprintf("%s:%d", id, state.HandNumber),
		Kind:   action.Kind, CreatedAt: time.Now().UTC(),
	})
	return Submission{Snapshot: view}, nil
}

func (r *Repository) startPersistent(state State) error {
	if state.Practice || r.persistence == nil {
		return nil
	}
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	return r.persistence.StartLiveMatch(ctx, state)
}

// Due returns isolated candidates. Submit's version check arbitrates races with
// player commands; the scheduler never advances an obsolete turn.
func (r *Repository) Due(now time.Time) []State {
	r.mu.Lock()
	defer r.mu.Unlock()
	var due []State
	for _, item := range r.sessions {
		s := item.state
		if s.Turn < 0 || s.Turn > 3 || s.Phase == Finished || s.Deadline.IsZero() {
			continue
		}
		if !now.Before(s.Deadline) {
			due = append(due, clone(s))
		}
	}
	return due
}

func (r *Repository) EventsAfter(id string, sequence uint64, limit int) ([]Event, uint64, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	item, ok := r.sessions[id]
	if !ok {
		return nil, 0, ErrNotFound
	}
	if sequence > item.state.Version || limit < 1 || limit > 1000 {
		return nil, 0, ErrInvalidAction
	}
	events := make([]Event, 0)
	for _, event := range item.events {
		if event.Sequence > sequence {
			events = append(events, event)
			if len(events) == limit {
				break
			}
		}
	}
	return events, item.state.Version, nil
}

func (r *Repository) Delete(id string) {
	r.mu.Lock()
	defer r.mu.Unlock()
	delete(r.sessions, id)
}

func cloneSnapshot(snapshot Snapshot) Snapshot {
	data, _ := json.Marshal(snapshot)
	var result Snapshot
	_ = json.Unmarshal(data, &result)
	return result
}
