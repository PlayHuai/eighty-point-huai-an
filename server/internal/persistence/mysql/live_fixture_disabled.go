//go:build !autotest

package mysql

import (
	"context"
	"database/sql"
	"errors"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/runtime"
)

func prepareLiveFixture(_ context.Context, _ *sql.Tx, state runtime.State) error {
	if state.TestScenario != "" {
		return errors.New("test fixture forbidden in production")
	}
	return nil
}
