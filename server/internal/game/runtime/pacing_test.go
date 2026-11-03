package runtime

import (
	"errors"
	"reflect"
	"testing"
	"time"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"
)

func TestHandDisplayOrderAndAdjacentPairs(t *testing.T) {
	want := []engine.Card{
		{Suit: engine.Hearts, Rank: 5}, {Suit: engine.Hearts, Rank: 5, Copy: 1},
		{Rank: 16}, {Rank: 16, Copy: 1}, {Rank: 15},
		{Suit: engine.Spades, Rank: 2},
		{Suit: engine.Hearts, Rank: 2}, {Suit: engine.Clubs, Rank: 2},
		{Suit: engine.Spades, Rank: 14}, {Suit: engine.Spades, Rank: 14, Copy: 1},
		{Suit: engine.Spades, Rank: 3},
		{Suit: engine.Hearts, Rank: 14}, {Suit: engine.Hearts, Rank: 6},
		{Suit: engine.Clubs, Rank: 14}, {Suit: engine.Diamonds, Rank: 14},
	}
	cards := append([]engine.Card(nil), want...)
	for i, j := 0, len(cards)-1; i < j; i, j = i+1, j-1 {
		cards[i], cards[j] = cards[j], cards[i]
	}
	sortHand(cards, engine.Trump{Suit: engine.Spades, Level: 2})
	if !reflect.DeepEqual(cards, want) {
		t.Fatalf("order = %+v", cards)
	}
	state, err := NewSession(Config{ID: "order", Players: [4]string{"a", "b", "c", "d"}}, func([]engine.Card) {})
	if err != nil {
		t.Fatal(err)
	}
	original := clone(state)
	if _, err := View(state, 0); err != nil {
		t.Fatal(err)
	}
	if !reflect.DeepEqual(state, original) {
		t.Fatal("display sorting mutated authoritative hands")
	}
	for _, suit := range []engine.Suit{engine.NoSuit, engine.Clubs, engine.Hearts, engine.Diamonds} {
		hand := []engine.Card{{Suit: engine.Clubs, Rank: 5}, {Suit: engine.Hearts, Rank: 5}, {Rank: 15}, {Rank: 16}}
		sortHand(hand, engine.Trump{Suit: suit, Level: 5})
		if hand[0].Suit != engine.Hearts || hand[1].Rank != 16 || hand[2].Rank != 15 {
			t.Fatalf("level-five order: %+v", hand)
		}
	}
}

func TestServerDealingReleasesOneCardPerInterval(t *testing.T) {
	r := NewRepository(func([]engine.Card) {})
	s, err := r.Create(Config{ID: "deal", Players: [4]string{"a", "b", "c", "d"}, DealInterval: 200 * time.Millisecond})
	if err != nil {
		t.Fatal(err)
	}
	if s.Phase != Dealing {
		t.Fatal(s.Phase)
	}
	if _, err := r.Submit(s.ID, "a", Action{Seat: 0, Kind: Pass, RequestID: "too-early", ExpectedVersion: s.Version}); !errors.Is(err, ErrPhase) {
		t.Fatal(err)
	}
	for count := 0; count <= 100; count++ {
		if count > 0 {
			s, err = r.AdvanceDealing(s.ID, s.Version, s.DealStarted.Add(time.Duration(count)*200*time.Millisecond))
			if err != nil {
				t.Fatal(err)
			}
		}
		total := 0
		for seat := 0; seat < 4; seat++ {
			view, err := View(s, seat)
			if err != nil {
				t.Fatal(err)
			}
			want := (count + 3 - seat) / 4
			if len(view.Hand) != want || view.HandCounts[seat] != want {
				t.Fatalf("card=%d seat=%d visible=%d", count, seat, len(view.Hand))
			}
			if len(view.Bottom) != 0 {
				t.Fatal("bottom exposed while dealing")
			}
			total += len(view.Hand)
		}
		if total != count {
			t.Fatalf("dealt=%d expected=%d", total, count)
		}
		closed, err := View(s, -1)
		if err != nil || len(closed.Hand) != 0 {
			t.Fatal("spectator received cards")
		}
	}
	if s.Phase != Declaration || len(r.Due(s.Deadline.Add(-time.Millisecond))) != 0 {
		t.Fatal("wrong declaration transition")
	}
}

func TestRobotAndAutoplayTurnsWaitTwoToFourSeconds(t *testing.T) {
	for i := 0; i < 32; i++ {
		r := NewRepository(func([]engine.Card) {})
		before := time.Now().UTC()
		s, err := r.Create(Config{ID: "robots", Practice: true, Players: [4]string{"practice:robots:a", "b", "c", "d"}})
		if err != nil {
			t.Fatal(err)
		}
		delay := s.Deadline.Sub(before)
		if delay < 2*time.Second || delay > 4*time.Second+100*time.Millisecond {
			t.Fatalf("delay=%v", delay)
		}
		if len(r.Due(s.Deadline.Add(-time.Nanosecond))) != 0 || len(r.Due(s.Deadline)) != 1 {
			t.Fatal("robot moved before deadline")
		}
	}
}

func TestCounterUsesConfiguredWindowForEveryPlayer(t *testing.T) {
	r := NewRepository(func([]engine.Card) {})
	s, err := r.Create(Config{ID: "counter", Players: [4]string{"a", "b", "c", "d"}, CounterWindow: 10 * time.Second})
	if err != nil {
		t.Fatal(err)
	}

	s.Phase, s.Turn = Counter, 0
	r.sessions[s.ID].state = s
	for seat := 0; seat < 2; seat++ {
		before := time.Now().UTC()
		result, err := r.Submit(s.ID, s.Players[seat], Action{Seat: seat, Kind: Pass, RequestID: string(rune('a' + seat)), ExpectedVersion: s.Version})
		if err != nil {
			t.Fatal(err)
		}
		s, err = r.Load(s.ID)
		if err != nil {
			t.Fatal(err)
		}
		if s.Deadline.Sub(before) < 10*time.Second || s.Deadline.Sub(before) > 10*time.Second+100*time.Millisecond ||
			result.Snapshot.Turn != seat+1 {
			t.Fatal("counter window not reset for next player")
		}
	}
}

func TestExplicitAutoplayAlsoUsesRandomDelay(t *testing.T) {
	r := NewRepository(func([]engine.Card) {})
	s, err := r.Create(Config{ID: "autoplay-delay", Players: [4]string{"a", "b", "c", "d"}})
	if err != nil {
		t.Fatal(err)
	}
	before := time.Now().UTC()
	submitted, err := r.Submit(s.ID, "a", Action{Seat: 0, Kind: SetAutoplay,
		Accept: true, RequestID: "enable", ExpectedVersion: s.Version})
	if err != nil {
		t.Fatal(err)
	}
	delay := submitted.Snapshot.Deadline.Sub(before)
	if delay < 2*time.Second || delay > 4*time.Second+100*time.Millisecond {
		t.Fatalf("autoplay delay=%v", delay)
	}
}

func TestCompletedTrickReportsOnlyActualDefenderPoints(t *testing.T) {
	for _, dealer := range []int{0, 1} {
		s := State{Phase: Playing, Turn: 0, Dealer: dealer, Trump: engine.Trump{Suit: engine.Hearts, Level: 2}}
		for seat, rank := range []engine.Rank{10, 14, 13, 9} {
			s.Hands[seat] = []engine.Card{{Suit: engine.Spades, Rank: rank}, {Suit: engine.Clubs, Rank: engine.Rank(seat + 3)}}
		}
		for seat := 0; seat < 4; seat++ {
			if err := s.play(Action{Seat: seat, Cards: []engine.Card{s.Hands[seat][0]}}); err != nil {
				t.Fatal(err)
			}
		}
		if len(s.Completed) != 1 || s.Completed[0].Winner != 1 {
			t.Fatal("wrong winner")
		}
		expected := 20
		if dealer == 1 {
			expected = 0
		}
		if s.Completed[0].CapturedPoints != expected || s.DefenderPoints != expected {
			t.Fatal("wrong captured points")
		}
	}
}
