package mysql

import (
	"context"
	"database/sql"
	"time"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/auth"
)

// Serialize attempts in MySQL so a correct concurrent request cannot clear an
// active lock, and neither a service restart nor a second replica bypasses it.
func (s *Store) RecordPasswordAttempt(ctx context.Context, userID string, correct bool, now time.Time) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	if _, err := tx.ExecContext(ctx, `INSERT INTO password_attempts (user_id)
		VALUES (?) ON DUPLICATE KEY UPDATE user_id = VALUES(user_id)`, userID); err != nil {
		return err
	}
	var failures int
	var until sql.NullTime
	if err := tx.QueryRowContext(ctx, `SELECT failures, locked_until FROM password_attempts
		WHERE user_id = ? FOR UPDATE`, userID).Scan(&failures, &until); err != nil {
		return err
	}
	if until.Valid && now.Before(until.Time) {
		return auth.ErrLoginLocked
	}
	if until.Valid || correct {
		failures = 0
	}
	if !correct {
		failures++
	}
	var lockedUntil any
	if failures >= 5 {
		lockedUntil = now.Add(15 * time.Minute)
	}
	if _, err := tx.ExecContext(ctx, `UPDATE password_attempts SET failures = ?, locked_until = ?
		WHERE user_id = ?`, failures, lockedUntil, userID); err != nil {
		return err
	}
	if err := tx.Commit(); err != nil {
		return err
	}
	if lockedUntil != nil {
		return auth.ErrLoginLocked
	}
	return nil
}
