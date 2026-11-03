package runtime

import (
	"errors"
	"testing"
)

func TestAbortWaitingAllowsOnlyIntermission(t *testing.T) {
	r := NewRepository(nil)
	cfg := config()
	cfg.RequireReady = true
	state, err := r.Create(cfg)
	if err != nil {
		t.Fatal(err)
	}
	if err = r.AbortWaiting(state.ID, "outsider"); !errors.Is(err, ErrInvalidAction) {
		t.Fatalf("outsider: %v", err)
	}
	if err = r.AbortWaiting(state.ID, state.Players[0]); err != nil {
		t.Fatal(err)
	}
	state, err = r.Load(state.ID)
	if err != nil || state.Phase != Void || state.Result != nil || !state.Deadline.IsZero() {
		t.Fatalf("void: %#v %v", state, err)
	}
	if err = r.AbortWaiting(state.ID, state.Players[0]); err != nil {
		t.Fatalf("retry: %v", err)
	}
}
