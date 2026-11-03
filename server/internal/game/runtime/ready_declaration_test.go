package runtime

import (
	"errors"
	"fmt"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"
	"testing"
	"time"
)

func readySession(t *testing.T, practice bool) (*Repository, State) {
	t.Helper()
	players := [4]string{"a", "b", "c", "d"}
	if practice {
		players = [4]string{"a", "practice:ready:Yao", "practice:ready:Jia", "practice:ready:Zhang"}
	}
	r := NewRepository(func([]engine.Card) {})
	s, err := r.Create(Config{ID: "ready", Players: players, RequireReady: true, Practice: practice, DealInterval: 200 * time.Millisecond})
	if err != nil {
		t.Fatal(err)
	}
	return r, s
}
func readyAction(t *testing.T, r *Repository, s State, seat int) State {
	t.Helper()
	_, err := r.Submit(s.ID, s.Players[seat], Action{Kind: Continue, Seat: seat, ExpectedVersion: s.Version, RequestID: fmt.Sprintf("ready:%d:%d", s.Version, seat)})
	if err != nil {
		t.Fatal(err)
	}
	s, err = r.Load(s.ID)
	if err != nil {
		t.Fatal(err)
	}
	return s
}
func TestReadyBarrierDoesNotExposeOrDealCards(t *testing.T) {
	r, s := readySession(t, false)
	deadline := s.Deadline
	if delay := time.Until(deadline); delay < 299*time.Second || delay > 300*time.Second {
		t.Fatal(delay)
	}
	for seat := 0; seat < 4; seat++ {
		v, err := View(s, seat)
		if err != nil || len(v.Hand) != 0 {
			t.Fatal("pre-ready hand leaked")
		}
		s = readyAction(t, r, s, seat)
		if seat < 3 && (s.Phase != AwaitingReady || s.Deadline != deadline) {
			t.Fatal("early deal or timer reset")
		}
	}
	if s.Phase != Dealing || s.DealtCards != 0 {
		t.Fatal("all-ready did not start deal")
	}
}
func TestDealingDeclarationOnlyUsesAlreadyReceivedCards(t *testing.T) {
	r, s := readySession(t, true)
	if s.Ready != [4]bool{false, true, true, true} {
		t.Fatal("robots not ready")
	}
	s = readyAction(t, r, s, 0)
	level := s.Hands[0][0]
	if _, err := r.Submit(s.ID, "a", Action{Kind: Declare, Seat: 0, Cards: []engine.Card{level}, ExpectedVersion: s.Version, RequestID: "before-deal"}); !errors.Is(err, ErrCards) {
		t.Fatal(err)
	}
	start := s.DealStarted
	s, err := r.AdvanceDealing(s.ID, s.Version, start.Add(s.DealInterval))
	if err != nil {
		t.Fatal(err)
	}
	v, _ := View(s, 0)
	if len(v.Actions) != 1 || v.Actions[0].Kind != Declare {
		t.Fatal("dealing claim button missing")
	}
	if _, err = r.Submit(s.ID, "a", Action{Kind: Declare, Seat: 0, Cards: []engine.Card{level}, ExpectedVersion: s.Version, RequestID: "claim"}); err != nil {
		t.Fatal(err)
	}
	s, _ = r.Load(s.ID)
	if s.Phase != Dealing || s.DealStarted != start || s.Declarer != 0 || len(s.Bottom) != 8 {
		t.Fatal("claim interrupted deal")
	}
	s, err = r.AdvanceDealing(s.ID, s.Version, start.Add(100*s.DealInterval))
	if err != nil {
		t.Fatal(err)
	}
	if s.Phase != Bury || s.Turn != s.Dealer || len(s.Hands[s.Dealer]) != 33 {
		t.Fatal("claim did not carry to bury")
	}
}
func TestPostDealTenSecondFallbackRevealsOnlyFirstBottomCard(t *testing.T) {
	r, s := readySession(t, true)
	s = readyAction(t, r, s, 0)
	bottom := s.Bottom[0]
	now := s.DealStarted.Add(100 * s.DealInterval)
	s, err := r.AdvanceDealing(s.ID, s.Version, now)
	if err != nil {
		t.Fatal(err)
	}
	if s.Deadline.Sub(now) != 10*time.Second {
		t.Fatal("fallback deadline")
	}
	if _, err = r.AdvanceWaiting(s.ID, s.Version, s.Deadline.Add(-time.Nanosecond)); !errors.Is(err, ErrPhase) {
		t.Fatal("early fallback")
	}
	s, err = r.AdvanceWaiting(s.ID, s.Version, s.Deadline)
	if err != nil {
		t.Fatal(err)
	}
	expected, _ := engine.FallbackTrump(bottom, s.Trump.Level)
	v, _ := View(s, 1)
	if s.Phase != Bury || s.Trump != expected || v.FallbackCard == nil || *v.FallbackCard != bottom || len(v.Bottom) != 0 {
		t.Fatal("incorrect fallback privacy")
	}
}
func TestReadyTimeoutRequiresDistinctNoVotesAndNeverSettlesPoints(t *testing.T) {
	for _, practice := range []bool{false, true} {
		r, s := readySession(t, practice)
		var err error
		s, err = r.AdvanceWaiting(s.ID, s.Version, s.Deadline)
		if err != nil {
			t.Fatal(err)
		}
		if !s.WaitPrompt || !s.Deadline.IsZero() {
			t.Fatal("prompt missing")
		}
		limit := 2
		if practice {
			limit = 1
		}
		for seat := 0; seat < limit; seat++ {
			_, err = r.Submit(s.ID, s.Players[seat], Action{Kind: WaitVote, Seat: seat, RequestID: fmt.Sprintf("no:%d", seat), ExpectedVersion: s.Version})
			if err != nil {
				t.Fatal(err)
			}
			s, _ = r.Load(s.ID)
			if seat == 0 && !practice && s.Phase == Void {
				t.Fatal("one vote voided regular room")
			}
		}
		if s.Phase != Void || s.Result != nil || !s.Deadline.IsZero() {
			t.Fatal("void awarded points or did not finish")
		}
	}
}
