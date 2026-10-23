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
	"time"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/auth"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/coordinator"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/player"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/settlement"
)

//go:embed migrations/*.sql
var migrationFiles embed.FS

var (
	ErrVersionConflict    = coordinator.ErrVersionConflict
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

	known := make(map[uint64]migration, len(migrations))
	for _, item := range migrations {
		known[item.version] = item
	}
	for version, previous := range applied {
		item, ok := known[version]
		if !ok {
			return fmt.Errorf("database contains unknown migration version %d", version)
		}
		if previous.name != item.name || previous.checksum != item.checksum {
			return fmt.Errorf("applied migration %d (%s) does not match embedded migration", item.version, item.name)
		}
	}
	missingVersion := false
	for _, item := range migrations {
		_, exists := applied[item.version]
		if !exists {
			missingVersion = true
		} else if missingVersion {
			return fmt.Errorf("database migration history has a gap before version %d", item.version)
		}
	}
	for _, item := range migrations {
		if _, ok := applied[item.version]; ok {
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
		if err != nil || version == 0 || version != previous+1 {
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

func (s *Store) FindByAccount(ctx context.Context, account string, email bool) (auth.Credential, error) {
	column := "username"
	if email {
		column = "email"
	}
	var credential auth.Credential
	err := s.db.QueryRowContext(ctx, `SELECT u.id, p.nickname, u.password_hash, u.created_at
		FROM users u JOIN player_profiles p ON p.user_id = u.id
		WHERE u.`+column+` = ? AND u.status = 'ACTIVE'`, account).Scan(
		&credential.UserID, &credential.Nickname, &credential.PasswordHash, &credential.CreatedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return auth.Credential{}, auth.ErrCredentialNotFound
	}
	return credential, err
}

func (s *Store) FindByUserID(ctx context.Context, userID string) (auth.Credential, error) {
	var credential auth.Credential
	err := s.db.QueryRowContext(ctx, `SELECT u.id, p.nickname, u.password_hash, u.created_at
		FROM users u JOIN player_profiles p ON p.user_id = u.id
		WHERE u.id = ? AND u.status = 'ACTIVE'`, userID).Scan(
		&credential.UserID, &credential.Nickname, &credential.PasswordHash, &credential.CreatedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return auth.Credential{}, auth.ErrCredentialNotFound
	}
	return credential, err
}

func (s *Store) CreateAccount(ctx context.Context, account auth.NewAccount) error {
	if account.UserID == "" || account.Account == "" || account.Nickname == "" || len(account.PasswordHash) == 0 {
		return errors.New("invalid account")
	}
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin account creation: %w", err)
	}
	defer tx.Rollback()

	var email, username any
	if account.Email {
		email = account.Account
	} else {
		username = account.Account
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO users (id, email, username, password_hash)
		VALUES (?, ?, ?, ?)`, account.UserID, email, username, account.PasswordHash); err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "duplicate") {
			return auth.ErrAccountExists
		}
		return fmt.Errorf("insert user account: %w", err)
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO player_profiles (user_id, nickname, points, rank_name)
		VALUES (?, ?, 0, '青铜')`, account.UserID, account.Nickname); err != nil {
		return fmt.Errorf("insert initial player profile: %w", err)
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit account creation: %w", err)
	}
	return nil
}

func (s *Store) UpdatePasswordAndRevokeSessions(ctx context.Context, userID string, passwordHash []byte, now time.Time) error {
	if userID == "" || len(passwordHash) == 0 {
		return errors.New("invalid password update")
	}
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin password update: %w", err)
	}
	defer tx.Rollback()
	result, err := tx.ExecContext(ctx, "UPDATE users SET password_hash = ? WHERE id = ? AND status = 'ACTIVE'", passwordHash, userID)
	if err != nil {
		return fmt.Errorf("update password hash: %w", err)
	}
	affected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("check password update: %w", err)
	}
	if affected != 1 {
		return auth.ErrInvalidCredentials
	}
	if _, err := tx.ExecContext(ctx, "UPDATE sessions SET revoked_at = ? WHERE user_id = ? AND revoked_at IS NULL", now, userID); err != nil {
		return fmt.Errorf("revoke sessions after password change: %w", err)
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit password update: %w", err)
	}
	return nil
}

func (s *Store) CreateSession(ctx context.Context, session auth.Session) error {
	if session.ID == "" || session.UserID == "" || session.ExpiresAt.IsZero() || session.AccessTokenExpiresAt.IsZero() {
		return errors.New("invalid session")
	}
	_, err := s.db.ExecContext(ctx, `INSERT INTO sessions
		(id, user_id, token_hash, access_token_hash, expires_at, access_expires_at, device_id)
		VALUES (?, ?, ?, ?, ?, ?, ?)`,
		session.ID, session.UserID, session.RefreshTokenHash[:], session.AccessTokenHash[:],
		session.ExpiresAt, session.AccessTokenExpiresAt, session.DeviceID)
	if err != nil {
		return fmt.Errorf("insert session: %w", err)
	}
	return nil
}

func (s *Store) RotateSession(ctx context.Context, refreshTokenHash [32]byte, replacement auth.Session, now time.Time) (auth.Session, error) {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return auth.Session{}, fmt.Errorf("begin session refresh: %w", err)
	}
	defer tx.Rollback()
	var session auth.Session
	err = tx.QueryRowContext(ctx, `SELECT s.id, s.user_id, s.device_id, p.nickname, u.created_at
		FROM sessions s JOIN users u ON u.id = s.user_id
		JOIN player_profiles p ON p.user_id = s.user_id
		WHERE s.token_hash = ? AND s.revoked_at IS NULL AND s.expires_at > ?
		AND u.status = 'ACTIVE' FOR UPDATE`,
		refreshTokenHash[:], now).Scan(
		&session.ID, &session.UserID, &session.DeviceID, &session.Nickname, &session.UserCreatedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return auth.Session{}, auth.ErrInvalidSession
	}
	if err != nil {
		return auth.Session{}, fmt.Errorf("find refresh session: %w", err)
	}
	result, err := tx.ExecContext(ctx, `UPDATE sessions
		SET token_hash = ?, access_token_hash = ?, expires_at = ?, access_expires_at = ?
		WHERE id = ? AND token_hash = ? AND revoked_at IS NULL`,
		replacement.RefreshTokenHash[:], replacement.AccessTokenHash[:],
		replacement.ExpiresAt, replacement.AccessTokenExpiresAt, session.ID, refreshTokenHash[:])
	if err != nil {
		return auth.Session{}, fmt.Errorf("rotate session tokens: %w", err)
	}
	affected, err := result.RowsAffected()
	if err != nil {
		return auth.Session{}, fmt.Errorf("check refreshed session: %w", err)
	}
	if affected != 1 {
		return auth.Session{}, auth.ErrInvalidSession
	}
	if err := tx.Commit(); err != nil {
		return auth.Session{}, fmt.Errorf("commit session refresh: %w", err)
	}
	return session, nil
}

func (s *Store) RevokeSession(ctx context.Context, refreshTokenHash [32]byte, now time.Time) error {
	_, err := s.db.ExecContext(ctx, `UPDATE sessions SET revoked_at = ?
		WHERE token_hash = ? AND revoked_at IS NULL`, now, refreshTokenHash[:])
	if err != nil {
		return fmt.Errorf("revoke session: %w", err)
	}
	return nil
}

func (s *Store) AuthenticateAccess(ctx context.Context, accessTokenHash [32]byte, now time.Time) (string, error) {
	var userID string
	err := s.db.QueryRowContext(ctx, `SELECT s.user_id FROM sessions s
		JOIN users u ON u.id = s.user_id
		WHERE s.access_token_hash = ? AND s.access_expires_at > ?
		AND s.expires_at > ? AND s.revoked_at IS NULL AND u.status = 'ACTIVE'`,
		accessTokenHash[:], now, now).Scan(&userID)
	return userID, err
}

func (s *Store) FindProfile(ctx context.Context, userID string) (player.Profile, error) {
	var profile player.Profile
	err := s.db.QueryRowContext(ctx,
		"SELECT user_id, points, rank_name FROM player_profiles WHERE user_id = ?",
		userID,
	).Scan(&profile.UserID, &profile.Points, &profile.Rank)
	return profile, err
}

func (s *Store) SaveProfile(ctx context.Context, profile player.Profile) error {
	if profile.UserID == "" || profile.Points < 0 || profile.Rank == "" {
		return errors.New("invalid player profile")
	}
	_, err := s.db.ExecContext(ctx, `INSERT INTO player_profiles (user_id, nickname, points, rank_name)
		VALUES (?, ?, ?, ?)
		ON DUPLICATE KEY UPDATE points = VALUES(points), rank_name = VALUES(rank_name)`,
		profile.UserID, profile.UserID, profile.Points, profile.Rank)
	return err
}

func (s *Store) CommitGameUpdate(ctx context.Context, expectedVersion uint64, state coordinator.GameState, event coordinator.GameEvent) error {
	if state.SessionID == "" || event.SessionID != state.SessionID ||
		(state.Status != "ACTIVE" && state.Status != "ABORTED") ||
		event.Type == "" || !json.Valid(event.Payload) || expectedVersion == math.MaxUint64 {
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
	rows, err := s.db.QueryContext(ctx, `SELECT seq, hand_id, event_type, payload, actor_id, request_id
		FROM game_events WHERE game_session_id = ? AND seq > ? ORDER BY seq`,
		sessionID, state.Version)
	if err != nil {
		return coordinator.RecoveryState{}, fmt.Errorf("load game events: %w", err)
	}
	defer rows.Close()
	for rows.Next() {
		var event coordinator.GameEvent
		var handID, actorID, requestID sql.NullString
		if err := rows.Scan(&event.Seq, &handID, &event.Type, &event.Payload, &actorID, &requestID); err != nil {
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

func (s *Store) FindGameEventByRequest(ctx context.Context, sessionID, requestID string) (coordinator.GameEvent, error) {
	var event coordinator.GameEvent
	var handID, actorID, storedRequestID sql.NullString
	err := s.db.QueryRowContext(ctx, `SELECT seq, hand_id, event_type, payload, actor_id, request_id
		FROM game_events WHERE game_session_id = ? AND request_id = ?`,
		sessionID, requestID).Scan(
		&event.Seq, &handID, &event.Type, &event.Payload, &actorID, &storedRequestID)
	if errors.Is(err, sql.ErrNoRows) {
		return coordinator.GameEvent{}, coordinator.ErrEventNotFound
	}
	if err != nil {
		return coordinator.GameEvent{}, fmt.Errorf("find game event by request: %w", err)
	}
	event.SessionID = sessionID
	event.HandID = handID.String
	event.ActorID = actorID.String
	event.RequestID = storedRequestID.String
	return event, nil
}

func (s *Store) LoadGameEventsAfter(ctx context.Context, sessionID string, seq uint64, limit uint32) ([]coordinator.GameEvent, error) {
	if sessionID == "" || limit == 0 || limit > 500 {
		return nil, errors.New("invalid game event query")
	}
	rows, err := s.db.QueryContext(ctx, `SELECT seq, hand_id, event_type, payload, actor_id, request_id
		FROM game_events WHERE game_session_id = ? AND seq > ? ORDER BY seq LIMIT ?`,
		sessionID, seq, limit)
	if err != nil {
		return nil, fmt.Errorf("load game events: %w", err)
	}
	defer rows.Close()

	events := make([]coordinator.GameEvent, 0)
	for rows.Next() {
		var event coordinator.GameEvent
		var handID, actorID, requestID sql.NullString
		if err := rows.Scan(&event.Seq, &handID, &event.Type, &event.Payload, &actorID, &requestID); err != nil {
			return nil, fmt.Errorf("scan game event: %w", err)
		}
		event.SessionID = sessionID
		event.HandID = handID.String
		event.ActorID = actorID.String
		event.RequestID = requestID.String
		events = append(events, event)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("load game events: %w", err)
	}
	return events, nil
}

func settlementHash(result settlement.MatchResult) ([32]byte, error) {
	normalized := result
	normalized.Changes = append([]settlement.PointChange(nil), result.Changes...)
	for i := range normalized.Changes {
		normalized.Changes[i].Rank = ""
	}
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
		result.EndType == "" || len(result.Changes) != 4 {
		return ErrInvalidSettlement
	}
	expectedPoints, err := settlement.PointsFor(result.LevelDifference, result.EndType, result.HallMultiplierBP)
	if err != nil {
		return ErrInvalidSettlement
	}
	seen := make(map[string]bool, len(result.Changes))
	winners, losers := 0, 0
	for _, change := range result.Changes {
		if change.UserID == "" || seen[change.UserID] {
			return ErrInvalidSettlement
		}
		seen[change.UserID] = true
		switch change.Delta {
		case expectedPoints:
			winners++
		case -expectedPoints:
			losers++
		default:
			return ErrInvalidSettlement
		}
	}
	if winners != 2 || losers != 2 {
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

	type playerBalance struct {
		change  settlement.PointChange
		balance int64
		delta   int64
	}
	players := make([]playerBalance, 0, len(requested.Changes))
	changes := append([]settlement.PointChange(nil), requested.Changes...)
	sort.Slice(changes, func(i, j int) bool { return changes[i].UserID < changes[j].UserID })
	var totalLoss int64
	for _, change := range changes {
		var balance int64
		if err := tx.QueryRowContext(ctx,
			"SELECT points FROM player_profiles WHERE user_id = ? FOR UPDATE", change.UserID,
		).Scan(&balance); err != nil {
			return settlement.MatchResult{}, err
		}
		if balance < 0 {
			return settlement.MatchResult{}, ErrInvalidSettlement
		}
		delta := change.Delta
		if delta < 0 && delta < -balance {
			delta = -balance
		}
		if delta < 0 {
			totalLoss -= delta
		}
		players = append(players, playerBalance{change: change, balance: balance, delta: delta})
	}

	award, remainder := totalLoss/2, totalLoss%2
	for i := range players {
		if players[i].change.Delta <= 0 {
			continue
		}
		players[i].delta = award
		if remainder > 0 {
			players[i].delta++
			remainder--
		}
	}

	actual := requested
	actual.Changes = make([]settlement.PointChange, 0, len(players))
	for _, player := range players {
		if player.delta > 0 && player.balance > math.MaxInt64-player.delta {
			return settlement.MatchResult{}, ErrInvalidSettlement
		}
		balanceAfter := player.balance + player.delta
		rank, err := settlement.RankForPoints(balanceAfter)
		if err != nil {
			return settlement.MatchResult{}, ErrInvalidSettlement
		}
		if _, err := tx.ExecContext(ctx, `UPDATE player_profiles SET points = ?, rank_name = ? WHERE user_id = ?`,
			balanceAfter, rank, player.change.UserID); err != nil {
			return settlement.MatchResult{}, fmt.Errorf("update player profile %q: %w", player.change.UserID, err)
		}
		if _, err := tx.ExecContext(ctx, `INSERT INTO point_ledger
			(game_session_id, user_id, delta, balance_after, rank_name, config_version)
			VALUES (?, ?, ?, ?, ?, ?)`,
			requested.GameSessionID, player.change.UserID, player.delta, balanceAfter,
			rank, requested.ConfigVersion); err != nil {
			return settlement.MatchResult{}, fmt.Errorf("insert point ledger for %q: %w", player.change.UserID, err)
		}
		actual.Changes = append(actual.Changes, settlement.PointChange{
			UserID: player.change.UserID, Delta: player.delta, Rank: rank,
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
		"SELECT user_id, delta, rank_name FROM point_ledger WHERE game_session_id = ? ORDER BY user_id", sessionID)
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
	_ auth.Repository          = (*Store)(nil)
	_ player.ProfileRepository = (*Store)(nil)
	_ coordinator.Repository   = (*Store)(nil)
	_ settlement.Repository    = (*Store)(nil)
)
