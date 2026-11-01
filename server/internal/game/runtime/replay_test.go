package runtime

import (
	"testing"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"
)

func TestReplayOrderedIsolatedAndDeduplicated(t *testing.T) {
	repository := NewRepository(func(_ []engine.Card) {})
	state, err := repository.Create(Config{ID: "replay", Players: [4]string{"a", "b", "c", "d"}})
	if err != nil {
		t.Fatal(err)
	}
	action := Action{Seat: state.Turn, Kind: Pass, RequestID: "first", ExpectedVersion: state.Version}
	for range 2 {
		if _, err := repository.Submit(state.ID, state.Players[action.Seat], action); err != nil {
			t.Fatal(err)
		}
	}
	events, latest, err := repository.EventsAfter(state.ID, state.Version, 1)
	if err != nil || len(events) != 1 || latest != state.Version+1 {
		t.Fatalf("replay = %+v, %d, %v", events, latest, err)
	}
	if events[0].ID != "first" || events[0].Kind != Pass || events[0].CreatedAt.IsZero() {
		t.Fatalf("event metadata = %+v", events[0])
	}
	events[0].ID = "tampered"
	again, _, _ := repository.EventsAfter(state.ID, state.Version, 100)
	if again[0].ID != "first" {
		t.Fatal("caller mutated retained replay")
	}
	empty, _, err := repository.EventsAfter(state.ID, latest, 100)
	if err != nil || len(empty) != 0 {
		t.Fatal("replayed already-seen event")
	}
	if _, _, err := repository.EventsAfter(state.ID, latest+1, 100); err != ErrInvalidAction {
		t.Fatal("future sequence accepted")
	}
}
