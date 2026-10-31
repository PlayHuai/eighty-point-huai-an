package mysql

import (
	"context"
	"fmt"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/feedback"
)

func (s *Store) SaveFeedback(ctx context.Context, userID, requestID, kind, body string) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin feedback transaction: %w", err)
	}
	defer tx.Rollback()
	_, err = tx.ExecContext(ctx, `INSERT INTO feedback (user_id, request_id, kind, body)
		VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE id = id`, userID, requestID, kind, body)
	if err != nil {
		return fmt.Errorf("insert feedback: %w", err)
	}
	var storedKind, storedBody string
	if err := tx.QueryRowContext(ctx, `SELECT kind, body FROM feedback
		WHERE user_id = ? AND request_id = ?`, userID, requestID).Scan(&storedKind, &storedBody); err != nil {
		return fmt.Errorf("read feedback: %w", err)
	}
	if storedKind != kind || storedBody != body {
		return feedback.ErrRequestConflict
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit feedback: %w", err)
	}
	return nil
}
