//go:build autotest

package runtime

import (
	"context"
	"errors"
	"fmt"
	"testing"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/settlement"
)

type testMatchPersistence struct {
	starts, finishes int
	fail             bool
}

func (p *testMatchPersistence) StartLiveMatch(context.Context, State) error { p.starts++; return nil }
func (p *testMatchPersistence) FinishLiveMatch(_ context.Context, state State) (settlement.MatchResult, error) {
	p.finishes++
	if p.fail {
		return settlement.MatchResult{}, errors.New("storage unavailable")
	}
	return MatchResult(state)
}

func TestFinalActionCommitsOnlyAfterSettlementAndRetryIsOnce(t *testing.T) {
	persistence := &testMatchPersistence{}
	repository := NewPersistentRepository(nil, persistence)
	state, err := repository.CreateScenario(Config{ID: "atomic", HallID: "ordinary", OwnerID: "a", Players: [4]string{"a", "b", "c", "d"}}, "spring")
	if err != nil {
		t.Fatal(err)
	}
	for seat := 0; seat < 3; seat++ {
		result, err := repository.Submit(state.ID, state.Players[seat], Action{Seat: seat, Kind: PlayCards, Cards: state.Hands[seat], RequestID: fmt.Sprint(seat), ExpectedVersion: state.Version})
		if err != nil {
			t.Fatal(err)
		}
		state, err = repository.Load(result.Snapshot.ID)
		if err != nil {
			t.Fatal(err)
		}
	}
	last := Action{Seat: 3, Kind: PlayCards, Cards: state.Hands[3], RequestID: "last", ExpectedVersion: state.Version}
	persistence.fail = true
	if _, err := repository.Submit(state.ID, state.Players[3], last); err == nil {
		t.Fatal("storage failure hidden")
	}
	unchanged, _ := repository.Load(state.ID)
	if unchanged.Version != state.Version || unchanged.Phase != Playing {
		t.Fatal("failed settlement advanced memory")
	}
	persistence.fail = false
	for range 2 {
		if _, err := repository.Submit(state.ID, state.Players[3], last); err != nil {
			t.Fatal(err)
		}
	}
	if persistence.finishes != 2 || persistence.starts != 1 {
		t.Fatalf("callbacks = %+v", persistence)
	}
	finished, _ := repository.Load(state.ID)
	if finished.Result.NominalPoints != 480 || len(finished.Result.PointChanges) != 4 {
		t.Fatal("settled result missing")
	}
}

func TestPracticeDoesNotInvokeDurableCallbacks(t *testing.T) {
	persistence := &testMatchPersistence{}
	repository := NewPersistentRepository(nil, persistence)
	if _, err := repository.CreateScenario(Config{ID: "practice", Practice: true, Players: [4]string{"a", "b", "c", "d"}}, "spring"); err != nil {
		t.Fatal(err)
	}
	if persistence.starts != 0 {
		t.Fatal("practice entered durable storage")
	}
}
