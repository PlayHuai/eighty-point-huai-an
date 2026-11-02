package grpc

import (
	"errors"
	"testing"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/social"
)

func TestFriendRequestUUIDRetries(t *testing.T) {
	server := &friendServer{}
	const id = "00000000-0000-4000-8000-000000000001"
	calls := 0
	send := func() error { calls++; return nil }
	for i := 0; i < 2; i++ {
		if err := server.sendRequestOnce("caller", id, "friend", send); err != nil {
			t.Fatal(err)
		}
	}
	if calls != 1 {
		t.Fatalf("retry invoked mutation %d times", calls)
	}
	if err := server.sendRequestOnce("caller", id, "other", send); !errors.Is(err, social.ErrInvalidInput) {
		t.Fatal("request ID accepted changed target")
	}
	if err := server.sendRequestOnce("caller", "invalid", "friend", send); !errors.Is(err, social.ErrInvalidInput) {
		t.Fatal("invalid UUID accepted")
	}
	if err := server.sendRequestOnce("second", id, "friend", send); err != nil || calls != 2 {
		t.Fatal("receipts must be scoped by authenticated caller")
	}
}
