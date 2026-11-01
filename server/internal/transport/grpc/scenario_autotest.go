//go:build autotest

package grpc

import (
	"os"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/runtime"
)

func createGameSession(sessions *runtime.Repository, config runtime.Config, scenarios []string) (runtime.State, error) {
	if len(scenarios) == 0 {
		return sessions.Create(config)
	}
	if len(scenarios) != 1 || os.Getenv("HUAI_AUTOTEST") != "1" {
		return runtime.State{}, runtime.ErrInvalidConfig
	}
	return sessions.CreateScenario(config, scenarios[0])
}
