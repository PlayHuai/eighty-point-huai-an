//go:build autotest

package mysql

import (
	"context"
	"database/sql"
	"errors"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/runtime"
	"os"
	"strings"
)

func prepareLiveFixture(ctx context.Context, tx *sql.Tx, state runtime.State) error {
	if state.TestScenario == "" {
		return nil
	}
	if os.Getenv("HUAI_AUTOTEST") != "1" {
		return errors.New("test fixtures disabled")
	}
	if state.TestScenario != "spring" && !strings.HasPrefix(state.TestScenario, "score/14/") {
		return nil
	}
	for _, playerID := range state.Players {
		if _, err := tx.ExecContext(ctx, `UPDATE player_profiles SET points = 1000, rank_name = '白银' WHERE user_id = ?`, playerID); err != nil {
			return err
		}
	}
	return nil
}
