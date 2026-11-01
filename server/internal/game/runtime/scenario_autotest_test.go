//go:build autotest

package runtime

import (
	"fmt"
	"testing"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"
)

func TestScenarioCardInventoryAndFinalTransitions(t *testing.T) {
	names := []string{"declaration", "red", "fallback/2", "fallback/5", "fallback/15", "fallback/16",
		"sky", "spring", "redfive", "pair", "tractor", "throw", "follow", "draw", "combo",
		"bottom/1", "bottom/2", "bottom/4", "bottom/6",
		"comeback/11/70", "comeback/11/80/pair", "comeback/14/75",
		"comeback/14/80", "comeback/14/100/pair"}
	for _, level := range []int{2, 4, 11, 14} {
		for score := 0; score <= 200; score += 5 {
			names = append(names, fmt.Sprintf("score/%d/%d", level, score))
		}
	}
	for _, name := range names {
		t.Run(name, func(t *testing.T) {
			repository := NewRepository(nil)
			state, err := repository.CreateScenario(Config{ID: "scenario", Players: [4]string{"a", "b", "c", "d"}}, name)
			if err != nil {
				t.Fatal(err)
			}
			cards := append([]engine.Card(nil), state.Bottom...)
			for _, hand := range state.Hands {
				cards = append(cards, hand...)
			}
			for _, trick := range state.Completed {
				for _, play := range trick.Plays {
					cards = append(cards, play.Cards...)
				}
			}
			if len(cards) != 108 || !unique(cards) {
				t.Fatalf("fixture inventory invalid: %d cards", len(cards))
			}
			if state.Phase != Playing || name == "throw" || name == "follow" || name == "draw" || name == "combo" {
				return
			}
			for seat := 0; seat < 4; seat++ {
				state, err = Apply(state, Action{
					Seat: seat, Kind: PlayCards, Cards: state.Hands[seat],
					RequestID: fmt.Sprintf("play-%d", seat), ExpectedVersion: state.Version,
				}, nil)
				if err != nil {
					t.Fatalf("seat %d: %v", seat, err)
				}
			}
			if state.Result == nil || (state.Phase != HandOver && state.Phase != Finished) {
				t.Fatal("final fixture did not settle")
			}
		})
	}
}

func TestScenarioUnknownAndDuplicatesFail(t *testing.T) {
	repository := NewRepository(nil)
	config := Config{ID: "scenario", Players: [4]string{"a", "b", "c", "d"}}
	if _, err := repository.CreateScenario(config, "unknown"); err == nil {
		t.Fatal("unknown fixture accepted")
	}
	if _, err := repository.CreateScenario(config, "declaration"); err != nil {
		t.Fatal(err)
	}
	if _, err := repository.CreateScenario(config, "declaration"); err != ErrExists {
		t.Fatalf("duplicate fixture = %v", err)
	}
}
