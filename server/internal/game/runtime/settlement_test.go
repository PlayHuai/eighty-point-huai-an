package runtime

import (
	"testing"
	"time"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"
)

func TestLiveSettlementRatesAndEqualLevelMinimum(t *testing.T) {
	for _, test := range []struct {
		difference int
		spring     bool
		expected   int64
	}{
		{0, false, 5}, {1, false, 5}, {5, false, 25},
		{6, false, 60}, {11, false, 110}, {12, false, 180}, {12, true, 480},
	} {
		state := State{MatchID: "match", Phase: Finished, HallID: "ordinary", Players: [4]string{"a", "b", "c", "d"},
			Levels: [2]engine.Rank{engine.Rank(2 + test.difference), engine.RankTwo},
			Result: &Result{WinnerTeam: 0, Spring: test.spring}}
		result, err := MatchResult(state)
		if err != nil {
			t.Fatal(err)
		}
		for seat, change := range result.Changes {
			expected := test.expected
			if seat%2 != 0 {
				expected = -expected
			}
			if change.Delta != expected {
				t.Fatalf("difference=%d spring=%v seat=%d delta=%d", test.difference, test.spring, seat, change.Delta)
			}
		}
	}
}

func TestDeadlineAndAutoplayAreServerOwned(t *testing.T) {
	repository := NewRepository(func([]engine.Card) {})
	state, err := repository.Create(Config{ID: "deadline", Players: [4]string{"a", "b", "c", "d"}})
	if err != nil {
		t.Fatal(err)
	}
	if len(repository.Due(state.Deadline.Add(-time.Millisecond))) != 0 {
		t.Fatal("advanced early")
	}
	if len(repository.Due(state.Deadline)) != 1 {
		t.Fatal("deadline not due")
	}
	action := Action{Seat: state.Turn, Kind: SetAutoplay, Accept: true, RequestID: "enable", ExpectedVersion: state.Version}
	submitted, err := repository.Submit(state.ID, state.Players[state.Turn], action)
	if err != nil {
		t.Fatal(err)
	}
	if len(repository.Due(time.Now())) != 1 {
		t.Fatal("explicit autoplay not due")
	}
	action.RequestID, action.Accept, action.ExpectedVersion = "disable", false, submitted.Snapshot.Version
	if _, err := repository.Submit(state.ID, state.Players[state.Turn], action); err != nil {
		t.Fatal(err)
	}
	if len(repository.Due(time.Now())) != 0 {
		t.Fatal("autoplay cancellation ignored")
	}
}
