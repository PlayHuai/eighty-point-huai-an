//go:build !autotest

package grpc

import "github.com/Derek0120/eighty-point-huai-an/server/internal/game/runtime"

func createGameSession(sessions *runtime.Repository, config runtime.Config, scenarios []string) (runtime.State, error) {
	if len(scenarios) != 0 {
		return runtime.State{}, runtime.ErrInvalidConfig
	}
	return sessions.Create(config)
}
