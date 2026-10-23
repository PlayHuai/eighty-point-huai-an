package mysql

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"embed"
	"encoding/json"
	"errors"
	"fmt"
	"io/fs"
	"math"
	"path"
	"sort"
	"strconv"
	"strings"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/auth"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/coordinator"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/player"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/settlement"
)

//go:embed migrations/*.sql
var migrationFiles embed.FS

var (
	ErrVersionConflict    = errors.New("game state version conflict")
	ErrInvalidSettlement  = errors.New("invalid settlement")
	ErrSettlementConflict = errors.New("game session already settled with different result")
	ErrGameNotActive      = errors.New("game session is not active")
)

type Store struct {
	db *sql.DB
}

type migration struct {
	version  uint64
	name     string
	checksum [32]byte
	sql      string
}

func New(db *sql.DB) (*Store, error) {
	if db == nil {
		return nil, errors.New("mysql database is required")
	}
	return &Store{db: db}, nil
}

func ApplyMigrations(ctx context.Context, db *sql.DB) error {
	if db == nil {
		return errors.New("mysql database is required")
	}
	if _, err := db.ExecContext(ctx, `CREATE TABLE IF NOT EXISTS schema_migrations (
		version BIGINT UNSIGNED NOT NULL PRIMARY KEY,
		name VARCHAR(255) NOT NULL,
		checksum BINARY(32) NOT NULL,
		applied_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
	) ENGINE=InnoDB`); err != nil {
		return fmt.Errorf("create migration metadata table: %w", err)
	}

	migrations, err := loadMigrations()
	if err != nil {
		return err
	}
	applied := make(map[uint64]migration, len(migrations))
	rows, err := db.QueryContext(ctx, "SELECT version, name, checksum FROM schema_migrations")
	if err != nil {
		return fmt.Errorf("read migration versions: %w", err)
	}
	for rows.Next() {
		var item migration
		var checksum []byte
		if err := rows.Scan(&item.version, &item.name, &checksum); err != nil {
			rows.Close()
			return fmt.Errorf("read migration version: %w", err)
		}
		if len(checksum) != len(item.checksum) {
			rows.Close()
			return fmt.Errorf("invalid checksum stored for migration %d", item.version)
		}
		copy(item.checksum[:], checksum)
		applied[item.version] = item
	}
	if err := rows.Err(); err != nil {
		rows.Close()
		return fmt.Errorf("read migration versions: %w", err)
	}
	if err := rows.Close(); err != nil {
		return fmt.Errorf("close migration versions: %w", err)
	}

	known := make(map[uint64]bool, len(migrations))
	for _, item := range migrations {
		known[item.version] = true
		if previous, ok := applied[item.version]; ok {
			if previous.name != item.name || previous.checksum != item.checksum {
				return fmt.Errorf("applied migration %d (%s) does not match embedded migration", item.version, item.name)
			}
			continue
		}
		for _, statement := range strings.Split(item.sql, ";") {
			statement = strings.TrimSpace(statement)
			if statement == "" {
				continue
			}
			if _, err := db.ExecContext(ctx, statement); err != nil {
				return fmt.Errorf("apply migration %d (%s): %w", item.version, item.name, err)
			}
		}
		if _, err := db.ExecContext(ctx,
			"INSERT INTO schema_migrations (version, name, checksum) VALUES (?, ?, ?)",
			item.version, item.name, item.checksum[:]); err != nil {
			return fmt.Errorf("record migration %d (%s): %w", item.version, item.name, err)
		}
	}
	for version := range applied {
		if !known[version] {
			return fmt.Errorf("database contains unknown migration version %d", version)
		}
	}
	return nil
}

func loadMigrations() ([]migration, error) {
	files, err := fs.Glob(migrationFiles, "migrations/*.sql")
	if err != nil {
		return nil, fmt.Errorf("list migrations: %w", err)
	}
	sort.Strings(files)
	migrations := make([]migration, 0, len(files))
	var previous uint64
	for _, filename := range files {
		base := path.Base(filename)
		parts := strings.SplitN(base, "_", 2)
		if len(parts) != 2 || !strings.HasSuffix(parts[1], ".sql") {
			return nil, fmt.Errorf("invalid migration filename %q", base)
		}
		version, err := strconv.ParseUint(parts[0], 10, 64)
		if err != nil || version == 0 || version <= previous {
			return nil, fmt.Errorf("invalid migration version in %q", base)
		}
		content, err := migrationFiles.ReadFile(filename)
		if err != nil {
			return nil, fmt.Errorf("read migration %q: %w", base, err)
		}
		migrations = append(migrations, migration{
			version: version, name: base, checksum: sha256.Sum256(content), sql: string(content),
		})
		previous = version
	}
	return migrations, nil
}

func (s *Store) FindByUsername(ctx context.Context, username string) (auth.Credential, error) {
	var credential auth.Credential
	err := s.db.QueryRowContext(ctx,
		"SELECT id, username, password_hash FROM users WHERE username = ? AND status = 'ACTIVE'",
		username,
	).Scan(&credential.UserID, &credential.Username, &credential.PasswordHash)
	return credential, err
}

func (s *Store) FindProfile(ctx context.Context, userID string) (player.Profile, error) {
	var profile player.Profile
	err := s.db.QueryRowContext(ctx,
		"SELECT user_id, points, rank FROM player_profiles WHERE user_id = ?",
		userID,
	).Scan(&profile.UserID, &profile.Points, &profile.Rank)
	return profile, err
}

func (s *Store) SaveProfile(ctx context.Context, profile player.Profile) error {
	if profile.UserID == "" || profile.Points < 0 {
		return errors.New("invalid player profile")
	}
	_, err := s.db.ExecContext(ctx, `INSERT INTO player_profiles (user_id, nickname, points, rank)
		VALUES (?, ?, ?, ?)
		ON DUPLICATE KEY UPDATE points = VALUES(points), rank = VALUES(rank)`,
		profile.UserID, profile.UserID, profile.Points, profile.Rank)
	return err
}

func (s *Store) CommitGameUpdate(ctx context.Context, expectedVersion uint64, state coordinator.GameState, event coordinator.GameEvent) error {
	if state.SessionID == "" || event.SessionID != state.SessionID ||
		(state.Status != "ACTIVE" && state.Status != "ABORTED") ||
		!json.Valid(event.Payload) || expectedVersion == math.MaxUint64 {
		return errors.New("invalid game update")
	}
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin game update: %w", err)
	}
	defer tx.Rollback()

	result, err := tx.ExecContext(ctx, `UPDATE game_sessions
		SET snapshot = ?, status = ?, state_version = state_version + 1
		WHERE id = ? AND state_version = ? AND status = 'ACTIVE'`,
		state.Snapshot, state.Status, state.SessionID, expectedVersion)
	if err != nil {
		return fmt.Errorf("update game snapshot: %w", err)
	}
	affected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("check game snapshot update: %w", err)
	}
	if affected != 1 {
		return ErrVersionConflict
	}

	var handID, actorID, requestID any
	if event.HandID != "" {
		handID = event.HandID
	}
	if event.ActorID != "" {
		actorID = event.ActorID
	}
	if event.RequestID != "" {
		requestID = event.RequestID
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO game_events
		(game_session_id, seq, hand_id, event_type, payload, actor_id, request_id)
		VALUES (?, ?, ?, ?, ?, ?, ?)`,
		event.SessionID, expectedVersion+1, handID, event.Type, event.Payload, actorID, requestID); err != nil {
		return fmt.Errorf("append game event: %w", err)
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit game update: %w", err)
	}
	return nil
}

func (s *Store) LoadRecoveryState(ctx context.Context, sessionID string) (coordinator.RecoveryState, error) {
	var state coordinator.RecoveryState
	err := s.db.QueryRowContext(ctx, `SELECT id, room_id, status, state_version, snapshot
		FROM game_sessions WHERE id = ?`, sessionID).Scan(
		&state.SessionID, &state.RoomID, &state.Status, &state.Version, &state.Snapshot)
	if err != nil {
		return coordinator.RecoveryState{}, err
	}
	rows, err := s.db.QueryContext(ctx, `SELECT hand_id, event_type, payload, actor_id, request_id
		FROM game_events WHERE game_session_id = ? AND seq > ? ORDER BY seq`,
		sessionID, state.Version)
	if err != nil {
		return coordinator.RecoveryState{}, fmt.Errorf("load game events: %w", err)
	}
	defer rows.Close()
	for rows.Next() {
		var event coordinator.GameEvent
		var handID, actorID, requestID sql.NullString
		if err := rows.Scan(&handID, &event.Type, &event.Payload, &actorID, &requestID); err != nil {
			return coordinator.RecoveryState{}, fmt.Errorf("scan game event: %w", err)
		}
		event.SessionID = sessionID
		event.HandID = handID.String
		event.ActorID = actorID.String
		event.RequestID = requestID.String
		state.Events = append(state.Events, event)
	}
	if err := rows.Err(); err != nil {
		return coordinator.RecoveryState{}, fmt.Errorf("load game events: %w", err)
	}
	return state, nil
}

func settlementHash(result settlement.MatchResult) ([32]byte, error) {
	normalized := result
	normalized.Changes = append([]settlement.PointChange(nil), result.Changes...)
	sort.Slice(normalized.Changes, func(i, j int) bool {
		return normalized.Changes[i].UserID < normalized.Changes[j].UserID
	})
	content, err := json.Marshal(normalized)
	if err != nil {
		return [32]byte{}, err
	}
	return sha256.Sum256(content), nil
}

func validateSettlement(result settlement.MatchResult) error {
	if result.GameSessionID == "" || (result.Winner != "DEALER" && result.Winner != "DEFENDER") ||
		result.LevelDifference < 1 || result.LevelDifference > 12 ||
		result.EndType == "" || result.HallMultiplierBP == 0 ||
		len(result.Changes) != 4 {
		return ErrInvalidSettlement
	}
	seen := make(map[string]bool, len(result.Changes))
	var total int64
	for _, change := range result.Changes {
		if change.UserID == "" || change.Rank == "" || seen[change.UserID] {
			return ErrInvalidSettlement
		}
		seen[change.UserID] = true
		if (change.Delta > 0 && total > math.MaxInt64-change.Delta) ||
			(change.Delta < 0 && total < math.MinInt64-change.Delta) {
			return ErrInvalidSettlement
		}
		total += change.Delta
	}
	if total != 0 {
		return ErrInvalidSettlement
	}
	return nil
}

func (s *Store) Settle(ctx context.Context, requested settlement.MatchResult) (settlement.MatchResult, error) {
	if err := validateSettlement(requested); err != nil {
		return settlement.MatchResult{}, err
	}
	requestHash, err := settlementHash(requested)
	if err != nil {
		return settlement.MatchResult{}, fmt.Errorf("hash settlement: %w", err)
	}
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return settlement.MatchResult{}, fmt.Errorf("begin settlement: %w", err)
	}
	defer tx.Rollback()

	var status string
	if err := tx.QueryRowContext(ctx,
		"SELECT status FROM game_sessions WHERE id = ? FOR UPDATE", requested.GameSessionID,
	).Scan(&status); err != nil {
		return settlement.MatchResult{}, err
	}
	if status == "SETTLED" {
		existing, storedHash, err := readSettlement(ctx, tx, requested.GameSessionID)
		if err != nil {
			return settlement.MatchResult{}, err
		}
		if storedHash != requestHash {
			return settlement.MatchResult{}, ErrSettlementConflict
		}
		return existing, nil
	}
	if status != "ACTIVE" {
		return settlement.MatchResult{}, ErrGameNotActive
	}

	if _, err := tx.ExecContext(ctx, `INSERT INTO match_results
		(game_session_id, winner, level_difference, end_type, hall_multiplier_bp, config_version, request_hash)
		VALUES (?, ?, ?, ?, ?, ?, ?)`,
		requested.GameSessionID, requested.Winner, requested.LevelDifference, requested.EndType,
		requested.HallMultiplierBP, requested.ConfigVersion, requestHash[:]); err != nil {
		return settlement.MatchResult{}, fmt.Errorf("insert match result: %w", err)
	}

	actual := requested
	actual.Changes = make([]settlement.PointChange, 0, len(requested.Changes))
	for _, change := range requested.Changes {
		var balance int64
		if err := tx.QueryRowContext(ctx,
			"SELECT points FROM player_profiles WHERE user_id = ? FOR UPDATE", change.UserID,
		).Scan(&balance); err != nil {
			return settlement.MatchResult{}, err
		}
		delta := change.Delta
		if delta < 0 && delta < -balance {
			delta = -balance
		}
		if delta > 0 && balance > math.MaxInt64-delta {
			return settlement.MatchResult{}, ErrInvalidSettlement
		}
		balanceAfter := balance + delta
		if _, err := tx.ExecContext(ctx, `UPDATE player_profiles SET points = ?, rank = ? WHERE user_id = ?`,
			balanceAfter, change.Rank, change.UserID); err != nil {
			return settlement.MatchResult{}, fmt.Errorf("update player profile %q: %w", change.UserID, err)
		}
		if _, err := tx.ExecContext(ctx, `INSERT INTO point_ledger
			(game_session_id, user_id, delta, balance_after, rank, config_version)
			VALUES (?, ?, ?, ?, ?, ?)`,
			requested.GameSessionID, change.UserID, delta, balanceAfter, change.Rank, requested.ConfigVersion); err != nil {
			return settlement.MatchResult{}, fmt.Errorf("insert point ledger for %q: %w", change.UserID, err)
		}
		actual.Changes = append(actual.Changes, settlement.PointChange{
			UserID: change.UserID, Delta: delta, Rank: change.Rank,
		})
	}

	result, err := tx.ExecContext(ctx, `UPDATE game_sessions
		SET status = 'SETTLED', ended_at = CURRENT_TIMESTAMP(6)
		WHERE id = ? AND status = 'ACTIVE'`, requested.GameSessionID)
	if err != nil {
		return settlement.MatchResult{}, fmt.Errorf("mark game settled: %w", err)
	}
	affected, err := result.RowsAffected()
	if err != nil {
		return settlement.MatchResult{}, fmt.Errorf("check settled game update: %w", err)
	}
	if affected != 1 {
		return settlement.MatchResult{}, ErrGameNotActive
	}
	if err := tx.Commit(); err != nil {
		return settlement.MatchResult{}, fmt.Errorf("commit settlement: %w", err)
	}
	return actual, nil
}

func readSettlement(ctx context.Context, tx *sql.Tx, sessionID string) (settlement.MatchResult, [32]byte, error) {
	var result settlement.MatchResult
	var hashBytes []byte
	result.GameSessionID = sessionID
	err := tx.QueryRowContext(ctx, `SELECT winner, level_difference, end_type, hall_multiplier_bp,
		config_version, request_hash FROM match_results WHERE game_session_id = ?`, sessionID).Scan(
		&result.Winner, &result.LevelDifference, &result.EndType, &result.HallMultiplierBP,
		&result.ConfigVersion, &hashBytes)
	if err != nil {
		return settlement.MatchResult{}, [32]byte{}, err
	}
	if len(hashBytes) != 32 {
		return settlement.MatchResult{}, [32]byte{}, errors.New("invalid stored settlement hash")
	}
	var storedHash [32]byte
	copy(storedHash[:], hashBytes)
	rows, err := tx.QueryContext(ctx,
		"SELECT user_id, delta, rank FROM point_ledger WHERE game_session_id = ? ORDER BY user_id", sessionID)
	if err != nil {
		return settlement.MatchResult{}, [32]byte{}, err
	}
	defer rows.Close()
	for rows.Next() {
		var change settlement.PointChange
		if err := rows.Scan(&change.UserID, &change.Delta, &change.Rank); err != nil {
			return settlement.MatchResult{}, [32]byte{}, err
		}
		result.Changes = append(result.Changes, change)
	}
	if err := rows.Err(); err != nil {
		return settlement.MatchResult{}, [32]byte{}, err
	}
	return result, storedHash, nil
}

var (
	_ auth.CredentialRepository = (*Store)(nil)
	_ player.ProfileRepository  = (*Store)(nil)
	_ coordinator.Repository    = (*Store)(nil)
	_ settlement.Repository     = (*Store)(nil)
)
