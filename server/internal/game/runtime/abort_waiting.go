package runtime

import (
	"context"
	"errors"
	"time"
)

// AbortWaiting serializes an intermission departure against the last ready vote.
func (r *Repository) AbortWaiting(id, playerID string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	item, ok := r.sessions[id]
	if !ok {
		return ErrNotFound
	}
	member := false
	for _, id := range item.state.Players {
		if id == playerID {
			member = true
			break
		}
	}
	if !member {
		return ErrInvalidAction
	}
	if item.state.Phase == Void {
		return nil
	}
	if item.state.Phase != AwaitingReady && item.state.Phase != HandOver {
		return ErrPhase
	}
	state := clone(item.state)
	state.Phase = Void
	state.Result = nil
	state.WaitPrompt = false
	state.Deadline = time.Time{}
	state.Version++
	if r.persistence != nil && !state.Practice {
		store, ok := r.persistence.(interface {
			VoidLiveMatch(context.Context, State) error
		})
		if !ok {
			return errors.New("void match persistence unavailable")
		}
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		err := store.VoidLiveMatch(ctx, state)
		cancel()
		if err != nil {
			return err
		}
	}
	item.state = state
	item.events = append(item.events, Event{Sequence: state.Version, HandID: state.ID, Kind: WaitVote, CreatedAt: time.Now().UTC()})
	return nil
}
