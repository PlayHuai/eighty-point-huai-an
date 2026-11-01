package runtime

import (
	"encoding/json"
	"errors"
	"fmt"
	"reflect"
	"sync"
	"time"
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

// Repository owns live sessions only. There is intentionally no persistence
// dependency or callback, so practice sessions cannot enter durable storage.
// Callers should discard a session with Delete when its room closes.
type Repository struct {
	mu       sync.Mutex
	sessions map[string]*entry
	shuffle  Shuffle
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
	r.sessions[state.ID] = &entry{state: state, receipts: make(map[string]receipt)}
	return clone(state), nil
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
