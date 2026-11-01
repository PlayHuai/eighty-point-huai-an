package runtime

import (
	"fmt"
	"math/rand"
	"testing"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"
)

func TestSuggestedPlayFollowsSideHearts510KInsteadOfRedFiveTrumpSuit(t *testing.T) {
	state := State{
		Phase: Playing, Turn: 1, Trump: engine.Trump{Suit: engine.Clubs, Level: engine.RankTwo},
		Trick: Trick{Leader: 0, Winner: 0, Plays: []Played{{Seat: 0, Cards: []engine.Card{
			{Suit: engine.Hearts, Rank: 5}, {Suit: engine.Hearts, Rank: 10}, {Suit: engine.Hearts, Rank: 13},
		}}}},
	}
	state.Hands[1] = []engine.Card{
		{Suit: engine.Clubs, Rank: 3}, {Suit: engine.Clubs, Rank: 4}, {Suit: engine.Clubs, Rank: 6},
		{Suit: engine.Hearts, Rank: 3}, {Suit: engine.Hearts, Rank: 4}, {Suit: engine.Hearts, Rank: 6},
	}
	cards, err := choosePlay(state, 1)
	if err != nil || len(cards) != 3 {
		t.Fatalf("side 510k suggestion = %+v, %v", cards, err)
	}
	for _, card := range cards {
		if card.Suit != engine.Hearts {
			t.Fatal("side 510k must follow its physical suit")
		}
	}
	if err := state.ValidatePlay(1, cards); err != nil {
		t.Fatal(err)
	}
}

func TestSuggestedPlayCompletesSeededMatches(t *testing.T) {
	for seed := int64(0); seed < 4; seed++ {
		t.Run(fmt.Sprint(seed), func(t *testing.T) {
			random := rand.New(rand.NewSource(seed))
			shuffle := func(cards []engine.Card) {
				random.Shuffle(len(cards), func(i, j int) { cards[i], cards[j] = cards[j], cards[i] })
			}
			state, err := NewSession(Config{ID: "match", Players: [4]string{"a", "b", "c", "d"}}, shuffle)
			if err != nil {
				t.Fatal(err)
			}
			for step := 0; step < 20000 && state.Phase != Finished; step++ {
				action := Action{Seat: state.Turn, RequestID: fmt.Sprint(step), ExpectedVersion: state.Version}
				switch state.Phase {
				case Declaration, Counter:
					action.Kind = Pass
				case Bury:
					action.Kind, action.Cards = BuryCards, state.Hands[action.Seat][:8]
				case Playing:
					action.Kind = PlayCards
					action.Cards, err = choosePlay(state, action.Seat)
					if err != nil {
						t.Fatalf("no legal suggestion at hand %d step %d: %v; state=%+v", state.HandNumber, step, err, state)
					}
				case HandOver:
					action.Kind = Continue
					for seat, ready := range state.Ready {
						if !ready {
							action.Seat = seat
							break
						}
					}
				}
				state, err = Apply(state, action, shuffle)
				if err != nil {
					t.Fatalf("step %d: %v", step, err)
				}
			}
			if state.Phase != Finished {
				t.Fatal("match did not finish within action budget")
			}
		})
	}
}
