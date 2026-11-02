//go:build !autotest

package grpc

import (
	"errors"
	"testing"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/runtime"
)

func TestProductionRejectsScenarioMetadata(t *testing.T) {
	repository := runtime.NewRepository(nil)
	config := runtime.Config{ID: "production", Players: [4]string{"a", "b", "c", "d"}}
	if _, err := createGameSession(repository, config, []string{"spring"}); !errors.Is(err, runtime.ErrInvalidConfig) {
		t.Fatalf("production accepted scenario: %v", err)
	}
	if _, err := repository.Load(config.ID); !errors.Is(err, runtime.ErrNotFound) {
		t.Fatal("rejected scenario must not create a session")
	}
}
