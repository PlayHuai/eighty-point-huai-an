package runtime

import (
	"fmt"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"
	"time"
)

func (r *Repository) AdvanceWaiting(id string, version uint64, now time.Time) (State, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	item, ok := r.sessions[id]
	if !ok {
		return State{}, ErrNotFound
	}
	s := clone(item.state)
	if s.Version != version {
		return State{}, ErrVersion
	}
	if s.Deadline.IsZero() || now.Before(s.Deadline) {
		return State{}, ErrPhase
	}
	switch s.Phase {
	case AwaitingReady, HandOver:
		s.WaitPrompt = true
		s.Deadline = time.Time{}
	case Declaration:
		trump, err := engine.FallbackTrump(s.Bottom[0], s.Trump.Level)
		if err != nil {
			return State{}, err
		}
		card := s.Bottom[0]
		s.FallbackCard = &card
		s.Trump = trump
		s.pickBottom(s.Dealer)
		if err := scheduleTurn(&s, now); err != nil {
			return State{}, err
		}
	default:
		return State{}, ErrPhase
	}
	s.Version++
	item.state = s
	item.events = append(item.events, Event{ID: fmt.Sprintf("wait:%d", s.Version), Sequence: s.Version,
		HandID: fmt.Sprintf("%s:%d", id, s.HandNumber), Kind: ActionKind("wait"), CreatedAt: now})
	return clone(s), nil
}
