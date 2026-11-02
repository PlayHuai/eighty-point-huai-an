//go:build autotest

package grpc

import (
	"testing"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/runtime"
)

func TestAutotestScenarioRequiresExplicitEnvironment(t *testing.T) {
	repository := runtime.NewRepository(nil)
	config := runtime.Config{ID: "scenario", Players: [4]string{"a", "b", "c", "d"}}
	t.Setenv("HUAI_AUTOTEST", "")
	if _, err := createGameSession(repository, config, []string{"spring"}); err == nil {
		t.Fatal("test build must still require HUAI_AUTOTEST=1")
	}
	t.Setenv("HUAI_AUTOTEST", "1")
	if _, err := createGameSession(repository, config, []string{"spring", "sky"}); err == nil {
		t.Fatal("ambiguous fixture metadata accepted")
	}
	if _, err := createGameSession(repository, config, []string{"spring"}); err != nil {
		t.Fatal(err)
	}
}
