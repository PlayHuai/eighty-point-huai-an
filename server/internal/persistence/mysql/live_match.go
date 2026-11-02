package mysql

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/runtime"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/settlement"
)

func (s *Store) StartLiveMatch(ctx context.Context, state runtime.State) error {
	if state.Practice || state.ID == "" || state.MatchID == "" || state.OwnerID == "" {
		return errors.New("invalid durable live match")
	}
	snapshot, err := json.Marshal(state)
	if err != nil {
		return err
	}
	players, err := json.Marshal(state.Players)
	if err != nil {
		return err
	}
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	if err := prepareLiveFixture(ctx, tx, state); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO rooms (id, hall_id, owner_id, status, settings_json)
		VALUES (?, ?, ?, 'PLAYING', '{}')
		ON DUPLICATE KEY UPDATE status = 'PLAYING', owner_id = VALUES(owner_id)`,
		state.ID, state.HallID, state.OwnerID); err != nil {
		return fmt.Errorf("persist live room: %w", err)
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO game_sessions
		(id, room_id, config_version, status, player_mapping, state_version, snapshot)
		VALUES (?, ?, 1, 'ACTIVE', ?, ?, ?)`, state.MatchID, state.ID, players, state.Version, snapshot); err != nil {
		return fmt.Errorf("persist live match: %w", err)
	}
	return tx.Commit()
}

func (s *Store) FinishLiveMatch(ctx context.Context, state runtime.State) (settlement.MatchResult, error) {
	requested, err := runtime.MatchResult(state)
	if err != nil {
		return settlement.MatchResult{}, err
	}
	snapshot, err := json.Marshal(state)
	if err != nil {
		return settlement.MatchResult{}, err
	}
	if _, err := s.db.ExecContext(ctx, `UPDATE game_sessions SET snapshot = ?, state_version = ?
		WHERE id = ? AND status = 'ACTIVE'`, snapshot, state.Version, state.MatchID); err != nil {
		return settlement.MatchResult{}, fmt.Errorf("persist final live snapshot: %w", err)
	}
	result, err := s.Settle(ctx, requested)
	if err != nil {
		return settlement.MatchResult{}, err
	}
	if _, err := s.db.ExecContext(ctx, `UPDATE rooms SET status = 'WAITING' WHERE id = ?`, state.ID); err != nil {
		return settlement.MatchResult{}, fmt.Errorf("persist completed room: %w", err)
	}
	return result, nil
}

var _ runtime.MatchPersistence = (*Store)(nil)
