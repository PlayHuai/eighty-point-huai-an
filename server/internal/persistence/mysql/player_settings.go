package mysql

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/runtime"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/player"
)

func (s *Store) GetPlayerSettings(ctx context.Context, userID string) (player.Settings, error) {
	var setting player.Settings
	err := s.db.QueryRowContext(ctx, "SELECT show_hand_to_spectators, settings_version FROM player_profiles WHERE user_id = ?", userID).Scan(&setting.ShowHand, &setting.Version)
	if errors.Is(err, sql.ErrNoRows) {
		return setting, player.ErrProfileNotFound
	}
	return setting, err
}
func (s *Store) UpdatePlayerSettings(ctx context.Context, userID string, show bool, version uint64, requestID string) (player.Settings, error) {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return player.Settings{}, err
	}
	defer tx.Rollback()
	var current player.Settings
	if err := tx.QueryRowContext(ctx, "SELECT show_hand_to_spectators, settings_version FROM player_profiles WHERE user_id = ? FOR UPDATE", userID).Scan(&current.ShowHand, &current.Version); err != nil {
		return current, err
	}
	var oldShow bool
	var expected, result uint64
	err = tx.QueryRowContext(ctx, "SELECT expected_version, show_hand, result_version FROM player_settings_requests WHERE user_id = ? AND request_id = ?", userID, requestID).Scan(&expected, &oldShow, &result)
	if err == nil {
		if expected != version || oldShow != show {
			return current, player.ErrSettingsRequest
		}
		return player.Settings{ShowHand: oldShow, Version: result}, tx.Commit()
	}
	if !errors.Is(err, sql.ErrNoRows) {
		return current, err
	}
	if current.Version != version {
		return current, player.ErrSettingsConflict
	}
	current.ShowHand, current.Version = show, version+1
	if _, err = tx.ExecContext(ctx, "UPDATE player_profiles SET show_hand_to_spectators = ?, settings_version = ? WHERE user_id = ?", show, current.Version, userID); err != nil {
		return current, err
	}
	if _, err = tx.ExecContext(ctx, "INSERT INTO player_settings_requests (user_id,request_id,expected_version,show_hand,result_version) VALUES (?,?,?,?,?)", userID, requestID, version, show, current.Version); err != nil {
		return current, err
	}
	return current, tx.Commit()
}
func (s *Store) VoidLiveMatch(ctx context.Context, state runtime.State) error {
	data, err := json.Marshal(state)
	if err != nil {
		return err
	}
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	if _, err = tx.ExecContext(ctx, "UPDATE game_sessions SET status='ABORTED', snapshot=?, state_version=?, ended_at=CURRENT_TIMESTAMP(6) WHERE id=? AND status='ACTIVE'", data, state.Version, state.MatchID); err != nil {
		return err
	}
	if _, err = tx.ExecContext(ctx, "UPDATE rooms SET status='WAITING' WHERE id=?", state.ID); err != nil {
		return err
	}
	return tx.Commit()
}
