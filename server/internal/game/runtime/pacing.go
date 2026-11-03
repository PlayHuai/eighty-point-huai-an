package runtime

import (
	"crypto/rand"
	"fmt"
	"math/big"
	"strings"
	"time"
)

func robotSeat(s State, seat int) bool {
	return seat >= 0 && seat < 4 && s.Practice &&
		strings.HasPrefix(s.Players[seat], "practice:"+s.ID+":")
}

func scheduleTurn(s *State, now time.Time) error {
	if s.Phase == Finished || s.Phase == Void {
		s.Deadline = time.Time{}
		return nil
	}
	if s.Phase == Dealing {
		s.DealStarted = now
		s.Deadline = now.Add(s.DealInterval)
		return nil
	}
	if s.RequireReady && (s.Phase == HandOver || s.Phase == AwaitingReady) {
		for seat := range s.Ready {
			if robotSeat(*s, seat) {
				s.Ready[seat] = true
			}
		}
		if s.WaitPrompt {
			s.Deadline = time.Time{}
		} else if s.Deadline.IsZero() {
			s.Deadline = now.Add(5 * time.Minute)
		}
		return nil
	}
	if s.RequireReady && s.Phase == Declaration {
		s.Deadline = now.Add(10 * time.Second)
		return nil
	}
	if s.Phase == HandOver {
		s.Deadline = time.Time{}
		for seat := range s.Players {
			if robotSeat(*s, seat) && !s.Ready[seat] {
				s.Turn = seat
				break
			}
		}
		if !robotSeat(*s, s.Turn) || s.Ready[s.Turn] {
			return nil
		}
	}
	window := time.Minute
	if s.Phase == Counter && s.CounterWindow > 0 {
		window = s.CounterWindow
	}
	if robotSeat(*s, s.Turn) || (s.Turn >= 0 && s.Turn < 4 && s.Autoplay[s.Turn]) {
		milliseconds, err := rand.Int(rand.Reader, big.NewInt(2001))
		if err != nil {
			return fmt.Errorf("schedule automatic turn: %w", err)
		}
		delay := 2*time.Second + time.Duration(milliseconds.Int64())*time.Millisecond
		if delay < window {
			window = delay
		}
	}
	s.Deadline = now.Add(window)
	return nil
}

// AdvanceDealing releases only the cards already dealt by the server clock.
// The version guard makes scheduler races harmless without exposing the deck.
func (r *Repository) AdvanceDealing(id string, version uint64, now time.Time) (State, error) {
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
	if s.Phase != Dealing || now.Before(s.Deadline) {
		return State{}, ErrPhase
	}
	count := int(now.Sub(s.DealStarted) / s.DealInterval)
	if count > 100 {
		count = 100
	}
	s.DealtCards = count
	if count == 100 {
		s.Phase = Declaration
		if s.Declarer >= 0 {
			s.pickBottom(s.Dealer)
		}
		if err := scheduleTurn(&s, now); err != nil {
			return State{}, err
		}

	} else {
		s.Deadline = s.DealStarted.Add(time.Duration(count+1) * s.DealInterval)
	}
	s.Version++
	item.state = s
	item.events = append(item.events, Event{
		ID: fmt.Sprintf("deal:%d", s.Version), Sequence: s.Version,
		HandID: fmt.Sprintf("%s:%d", id, s.HandNumber), Kind: ActionKind("deal"), CreatedAt: now,
	})
	return clone(s), nil
}
