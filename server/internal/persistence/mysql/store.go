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
	"unicode/utf8"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/auth"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/chat"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/coordinator"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/player"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/settlement"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/social"
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
	db          *sql.DB
	roomManager *room.Manager
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

func NewWithRoomManager(db *sql.DB, roomManager *room.Manager) (*Store, error) {
	if db == nil || roomManager == nil {
		return nil, errors.New("mysql database and room manager are required")
	}
	return &Store{db: db, roomManager: roomManager}, nil
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
	err := s.db.QueryRowContext(ctx, `SELECT u.id, p.nickname, u.password_hash, u.created_at,
		u.wechat_openid IS NOT NULL
		FROM users u JOIN player_profiles p ON p.user_id = u.id
		WHERE u.`+column+` = ? AND u.status = 'ACTIVE'`, account).Scan(
		&credential.UserID, &credential.Nickname, &credential.PasswordHash, &credential.CreatedAt,
		&credential.WeChatAccount)
	if errors.Is(err, sql.ErrNoRows) {
		return auth.Credential{}, auth.ErrCredentialNotFound
	}
	return credential, err
}

func (s *Store) FindByUserID(ctx context.Context, userID string) (auth.Credential, error) {
	var credential auth.Credential
	err := s.db.QueryRowContext(ctx, `SELECT u.id, p.nickname, u.password_hash, u.created_at,
		u.wechat_openid IS NOT NULL
		FROM users u JOIN player_profiles p ON p.user_id = u.id
		WHERE u.id = ? AND u.status = 'ACTIVE'`, userID).Scan(
		&credential.UserID, &credential.Nickname, &credential.PasswordHash, &credential.CreatedAt,
		&credential.WeChatAccount)
	if errors.Is(err, sql.ErrNoRows) {
		return auth.Credential{}, auth.ErrCredentialNotFound
	}
	return credential, err
}

func (s *Store) FindByWeChatOpenID(ctx context.Context, openID string) (auth.Credential, error) {
	var credential auth.Credential
	err := s.db.QueryRowContext(ctx, `SELECT u.id, p.nickname, u.password_hash, u.created_at
		FROM users u JOIN player_profiles p ON p.user_id = u.id
		WHERE u.wechat_openid = ? AND u.status = 'ACTIVE'`, openID).Scan(
		&credential.UserID, &credential.Nickname, &credential.PasswordHash, &credential.CreatedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return auth.Credential{}, auth.ErrCredentialNotFound
	}
	credential.WeChatAccount = err == nil
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

func (s *Store) CreateWeChatAccount(ctx context.Context, account auth.NewWeChatAccount) error {
	if account.UserID == "" || account.OpenID == "" || account.Nickname == "" || len(account.PasswordHash) == 0 {
		return errors.New("invalid WeChat account")
	}
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin WeChat account creation: %w", err)
	}
	defer tx.Rollback()
	if _, err := tx.ExecContext(ctx, `INSERT INTO users (id, wechat_openid, password_hash)
		VALUES (?, ?, ?)`, account.UserID, account.OpenID, account.PasswordHash); err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "duplicate") {
			return auth.ErrAccountExists
		}
		return fmt.Errorf("insert WeChat account: %w", err)
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO player_profiles (user_id, nickname, points, rank_name)
		VALUES (?, ?, 0, '青铜')`, account.UserID, account.Nickname); err != nil {
		return fmt.Errorf("insert initial WeChat player profile: %w", err)
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit WeChat account creation: %w", err)
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

func (s *Store) GetPublicProfile(ctx context.Context, userID string) (player.PublicProfile, error) {
	var profile player.PublicProfile
	err := s.db.QueryRowContext(ctx, `SELECT p.user_id, p.nickname, p.avatar, u.created_at
		FROM player_profiles p JOIN users u ON u.id = p.user_id
		WHERE p.user_id = ? AND u.status = 'ACTIVE'`, userID).Scan(
		&profile.UserID, &profile.Nickname, &profile.AvatarURL, &profile.CreatedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return player.PublicProfile{}, player.ErrProfileNotFound
	}
	return profile, err
}

func (s *Store) GetPublicProfiles(ctx context.Context, userIDs []string) (map[string]player.PublicProfile, error) {
	profiles := make(map[string]player.PublicProfile, len(userIDs))
	if len(userIDs) == 0 {
		return profiles, nil
	}

	placeholders := strings.TrimSuffix(strings.Repeat("?,", len(userIDs)), ",")
	args := make([]any, len(userIDs))
	for i, userID := range userIDs {
		args[i] = userID
	}
	rows, err := s.db.QueryContext(ctx, `SELECT p.user_id, p.nickname, p.avatar, u.created_at
		FROM player_profiles p JOIN users u ON u.id = p.user_id
		WHERE p.user_id IN (`+placeholders+`) AND u.status = 'ACTIVE'`, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var profile player.PublicProfile
		if err := rows.Scan(&profile.UserID, &profile.Nickname, &profile.AvatarURL, &profile.CreatedAt); err != nil {
			return nil, err
		}
		profiles[profile.UserID] = profile
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return profiles, nil
}

func (s *Store) AreFriends(ctx context.Context, firstUserID, secondUserID string) (bool, error) {
	if firstUserID == "" || secondUserID == "" || firstUserID == secondUserID {
		return false, nil
	}
	var friends bool
	err := s.db.QueryRowContext(ctx, `SELECT EXISTS (
		SELECT 1 FROM friendships
		WHERE user_id = ? AND friend_id = ? AND status = 'ACCEPTED'
	)`, firstUserID, secondUserID).Scan(&friends)
	if err != nil {
		return false, fmt.Errorf("check player friendship: %w", err)
	}
	return friends, nil
}

func (s *Store) GetStatistics(ctx context.Context, userID string) (player.Statistics, error) {
	if userID == "" {
		return player.Statistics{}, player.ErrInvalidProfile
	}
	var statistics player.Statistics
	err := s.db.QueryRowContext(ctx, `SELECT
		COUNT(DISTINCT l.game_session_id),
		COALESCE(SUM(l.won), 0),
		p.points,
		p.rank_name
		FROM player_profiles p
		LEFT JOIN point_ledger l ON l.user_id = p.user_id
		WHERE p.user_id = ?
		GROUP BY p.user_id, p.points, p.rank_name`, userID).Scan(
		&statistics.TotalGames, &statistics.Wins, &statistics.Points, &statistics.Rank)
	if errors.Is(err, sql.ErrNoRows) {
		return player.Statistics{}, player.ErrProfileNotFound
	}
	if err != nil {
		return player.Statistics{}, fmt.Errorf("get player statistics: %w", err)
	}
	statistics.Losses = statistics.TotalGames - statistics.Wins
	return statistics, nil
}

func (s *Store) ListRecentResults(ctx context.Context, userID string, offset, limit uint32) ([]player.RecentResult, error) {
	if userID == "" || limit == 0 || limit > 101 {
		return nil, player.ErrInvalidPage
	}
	rows, err := s.db.QueryContext(ctx, `SELECT l.game_session_id, l.delta, l.won, g.ended_at
		FROM point_ledger l
		JOIN game_sessions g ON g.id = l.game_session_id
		WHERE l.user_id = ? AND g.ended_at IS NOT NULL
		ORDER BY g.ended_at DESC, l.game_session_id DESC
		LIMIT ? OFFSET ?`, userID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("list recent player results: %w", err)
	}
	defer rows.Close()
	results := make([]player.RecentResult, 0, limit)
	for rows.Next() {
		var result player.RecentResult
		if err := rows.Scan(&result.GameSessionID, &result.PointsDelta, &result.Won, &result.EndedAt); err != nil {
			return nil, fmt.Errorf("scan recent player result: %w", err)
		}
		results = append(results, result)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read recent player results: %w", err)
	}
	return results, nil
}

func (s *Store) UpdatePublicProfile(ctx context.Context, userID, nickname, avatarURL string) (player.PublicProfile, error) {
	if userID == "" || nickname == "" || utf8.RuneCountInString(nickname) > 64 ||
		utf8.RuneCountInString(avatarURL) > 512 {
		return player.PublicProfile{}, player.ErrInvalidProfile
	}
	_, err := s.db.ExecContext(ctx, `UPDATE player_profiles p JOIN users u ON u.id = p.user_id
		SET p.nickname = ?, p.avatar = ?
		WHERE p.user_id = ? AND u.status = 'ACTIVE'`, nickname, avatarURL, userID)
	if err != nil {
		return player.PublicProfile{}, fmt.Errorf("update player profile: %w", err)
	}
	return s.GetPublicProfile(ctx, userID)
}

func (s *Store) SearchPlayers(ctx context.Context, query, excludedUserID string, offset, limit uint32) ([]social.Player, error) {
	if strings.TrimSpace(query) == "" || excludedUserID == "" || limit == 0 || limit > 101 {
		return nil, social.ErrInvalidInput
	}
	rows, err := s.db.QueryContext(ctx, `SELECT u.id, p.nickname, p.avatar, u.created_at
		FROM users u JOIN player_profiles p ON p.user_id = u.id
		WHERE u.status = 'ACTIVE' AND u.id <> ?
		AND (LOCATE(?, u.id) > 0 OR LOCATE(?, p.nickname) > 0 OR LOCATE(?, COALESCE(u.phone, '')) > 0)
		ORDER BY p.nickname, u.id LIMIT ? OFFSET ?`,
		excludedUserID, query, query, query, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("search players: %w", err)
	}
	defer rows.Close()
	players := make([]social.Player, 0, limit)
	for rows.Next() {
		var result social.Player
		if err := rows.Scan(&result.UserID, &result.Nickname, &result.AvatarURL, &result.CreatedAt); err != nil {
			return nil, fmt.Errorf("scan player search result: %w", err)
		}
		players = append(players, result)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read player search results: %w", err)
	}
	return players, nil
}

func (s *Store) SendFriendRequest(ctx context.Context, userID, targetUserID string) error {
	if userID == "" || targetUserID == "" || userID == targetUserID {
		return social.ErrInvalidInput
	}
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin friend request: %w", err)
	}
	defer tx.Rollback()
	var target string
	if err := tx.QueryRowContext(ctx, "SELECT id FROM users WHERE id = ? AND status = 'ACTIVE'", targetUserID).Scan(&target); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return social.ErrPlayerNotFound
		}
		return fmt.Errorf("find friend request target: %w", err)
	}
	var status string
	err = tx.QueryRowContext(ctx, `SELECT status FROM friendships
		WHERE user_id = ? AND friend_id = ? FOR UPDATE`, userID, targetUserID).Scan(&status)
	if err == nil {
		switch status {
		case "ACCEPTED":
			return social.ErrAlreadyFriends
		case "PENDING":
			return social.ErrFriendRequestExists
		default:
			return social.ErrNotFriends
		}
	}
	if !errors.Is(err, sql.ErrNoRows) {
		return fmt.Errorf("read friend request state: %w", err)
	}
	err = tx.QueryRowContext(ctx, `SELECT status FROM friendships
		WHERE user_id = ? AND friend_id = ? FOR UPDATE`, targetUserID, userID).Scan(&status)
	if err == nil {
		switch status {
		case "ACCEPTED":
			return social.ErrAlreadyFriends
		case "PENDING":
			return social.ErrFriendRequestExists
		default:
			return social.ErrNotFriends
		}
	} else if !errors.Is(err, sql.ErrNoRows) {
		return fmt.Errorf("read reverse friend request state: %w", err)
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO friendships (user_id, friend_id, status)
		VALUES (?, ?, 'PENDING')`, userID, targetUserID); err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "duplicate") {
			return social.ErrFriendRequestExists
		}
		return fmt.Errorf("insert friend request: %w", err)
	}
	payload, err := json.Marshal(struct {
		RequesterID string `json:"requester_user_id"`
		RecipientID string `json:"recipient_user_id"`
	}{userID, targetUserID})
	if err != nil {
		return fmt.Errorf("encode friend request event: %w", err)
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO outbox_events (event_type, aggregate_id, payload)
		VALUES ('FRIEND_REQUEST_CREATED', ?, ?)`, targetUserID, payload); err != nil {
		return fmt.Errorf("store friend request event: %w", err)
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit friend request: %w", err)
	}
	return nil
}

func (s *Store) RespondFriendRequest(ctx context.Context, requesterID, recipientID string, accept bool) error {
	if requesterID == "" || recipientID == "" || requesterID == recipientID {
		return social.ErrInvalidInput
	}
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin friend request response: %w", err)
	}
	defer tx.Rollback()
	var status string
	err = tx.QueryRowContext(ctx, `SELECT status FROM friendships
		WHERE user_id = ? AND friend_id = ? FOR UPDATE`, requesterID, recipientID).Scan(&status)
	if errors.Is(err, sql.ErrNoRows) {
		return social.ErrFriendRequestMissing
	}
	if err != nil {
		return fmt.Errorf("read friend request: %w", err)
	}
	if status != "PENDING" {
		if status == "ACCEPTED" {
			return social.ErrAlreadyFriends
		}
		return social.ErrFriendRequestMissing
	}
	if accept {
		var reverseStatus string
		err := tx.QueryRowContext(ctx, `SELECT status FROM friendships
			WHERE user_id = ? AND friend_id = ? FOR UPDATE`, recipientID, requesterID).Scan(&reverseStatus)
		if err == nil && reverseStatus == "BLOCKED" {
			return social.ErrNotFriends
		}
		if err != nil && !errors.Is(err, sql.ErrNoRows) {
			return fmt.Errorf("read reverse friendship state: %w", err)
		}
		if _, err := tx.ExecContext(ctx, `UPDATE friendships SET status = 'ACCEPTED'
			WHERE user_id = ? AND friend_id = ? AND status = 'PENDING'`, requesterID, recipientID); err != nil {
			return fmt.Errorf("accept friend request: %w", err)
		}
		if _, err := tx.ExecContext(ctx, `INSERT INTO friendships (user_id, friend_id, status)
			VALUES (?, ?, 'ACCEPTED')
			ON DUPLICATE KEY UPDATE status = 'ACCEPTED', updated_at = CURRENT_TIMESTAMP(6)`,
			recipientID, requesterID); err != nil {
			return fmt.Errorf("create reciprocal friendship: %w", err)
		}
	} else if _, err := tx.ExecContext(ctx, `DELETE FROM friendships
		WHERE user_id = ? AND friend_id = ? AND status = 'PENDING'`, requesterID, recipientID); err != nil {
		return fmt.Errorf("decline friend request: %w", err)
	}
	payload, err := json.Marshal(struct {
		RequesterID string `json:"requester_user_id"`
		RecipientID string `json:"recipient_user_id"`
		Accepted    bool   `json:"accepted"`
	}{requesterID, recipientID, accept})
	if err != nil {
		return fmt.Errorf("encode friend response event: %w", err)
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO outbox_events (event_type, aggregate_id, payload)
		VALUES ('FRIEND_REQUEST_RESPONDED', ?, ?)`, requesterID, payload); err != nil {
		return fmt.Errorf("store friend response event: %w", err)
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit friend request response: %w", err)
	}
	return nil
}

func (s *Store) ListFriendRequests(ctx context.Context, userID string, offset, limit uint32) ([]social.PendingFriendRequest, error) {
	if userID == "" || limit == 0 || limit > 101 {
		return nil, social.ErrInvalidInput
	}
	rows, err := s.db.QueryContext(ctx, `SELECT u.id, p.nickname, p.avatar, u.created_at, f.created_at
		FROM friendships f JOIN users u ON u.id = f.user_id
		JOIN player_profiles p ON p.user_id = f.user_id
		WHERE f.friend_id = ? AND f.status = 'PENDING' AND u.status = 'ACTIVE'
		ORDER BY f.created_at DESC, f.user_id LIMIT ? OFFSET ?`, userID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("list friend requests: %w", err)
	}
	defer rows.Close()
	requests := make([]social.PendingFriendRequest, 0, limit)
	for rows.Next() {
		var request social.PendingFriendRequest
		if err := rows.Scan(&request.UserID, &request.Nickname, &request.AvatarURL, &request.CreatedAt, &request.RequestedAt); err != nil {
			return nil, fmt.Errorf("scan friend request: %w", err)
		}
		requests = append(requests, request)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read friend requests: %w", err)
	}
	return requests, nil
}

func (s *Store) ListFriends(ctx context.Context, userID string, offset, limit uint32) ([]social.Friend, error) {
	if userID == "" || limit == 0 || limit > 101 {
		return nil, social.ErrInvalidInput
	}
	rows, err := s.db.QueryContext(ctx, `SELECT p.user_id, p.nickname, p.avatar, u.created_at, f.updated_at
		FROM friendships f JOIN users u ON u.id = f.friend_id
		JOIN player_profiles p ON p.user_id = f.friend_id
		WHERE f.user_id = ? AND f.status = 'ACCEPTED' AND u.status = 'ACTIVE'
		ORDER BY f.updated_at DESC, f.friend_id LIMIT ? OFFSET ?`, userID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("list friends: %w", err)
	}
	defer rows.Close()
	friends := make([]social.Friend, 0, limit)
	for rows.Next() {
		var friend social.Friend
		if err := rows.Scan(&friend.UserID, &friend.Nickname, &friend.AvatarURL, &friend.CreatedAt, &friend.FriendsSince); err != nil {
			return nil, fmt.Errorf("scan friend: %w", err)
		}
		friends = append(friends, friend)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read friends: %w", err)
	}
	return friends, nil
}

func (s *Store) ListFriendIDs(ctx context.Context, userID string) ([]string, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT friend_id FROM friendships
		WHERE user_id = ? AND status = 'ACCEPTED' ORDER BY friend_id`, userID)
	if err != nil {
		return nil, fmt.Errorf("list accepted friend IDs: %w", err)
	}
	defer rows.Close()
	friendIDs := make([]string, 0)
	for rows.Next() {
		var friendID string
		if err := rows.Scan(&friendID); err != nil {
			return nil, fmt.Errorf("scan accepted friend ID: %w", err)
		}
		friendIDs = append(friendIDs, friendID)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read accepted friend IDs: %w", err)
	}
	return friendIDs, nil
}

func (s *Store) RemoveFriend(ctx context.Context, userID, friendID string) error {
	if userID == "" || friendID == "" || userID == friendID {
		return social.ErrInvalidInput
	}
	result, err := s.db.ExecContext(ctx, `DELETE FROM friendships
		WHERE status = 'ACCEPTED' AND ((user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?))`,
		userID, friendID, friendID, userID)
	if err != nil {
		return fmt.Errorf("remove friendship: %w", err)
	}
	affected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("check friendship removal: %w", err)
	}
	if affected == 0 {
		return social.ErrNotFriends
	}
	return nil
}

func (s *Store) SendPrivateMessage(
	ctx context.Context,
	senderID, recipientID, requestID, body string,
) (chat.Message, error) {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return chat.Message{}, fmt.Errorf("begin private message: %w", err)
	}
	defer tx.Rollback()

	var friendshipStatus string
	err = tx.QueryRowContext(ctx, `SELECT f.status FROM friendships f
			JOIN users sender ON sender.id = f.user_id AND sender.status = 'ACTIVE'
			JOIN users recipient ON recipient.id = f.friend_id AND recipient.status = 'ACTIVE'
			WHERE f.user_id = ? AND f.friend_id = ? FOR UPDATE`, senderID, recipientID).Scan(&friendshipStatus)
	if errors.Is(err, sql.ErrNoRows) || (err == nil && friendshipStatus != "ACCEPTED") {
		return chat.Message{}, chat.ErrNotFriends
	}
	if err != nil {
		return chat.Message{}, fmt.Errorf("authorize private message: %w", err)
	}

	var existing chat.Message
	err = tx.QueryRowContext(ctx, `SELECT CAST(id AS CHAR), sender_id, recipient_id, body, created_at
			FROM chat_messages WHERE sender_id = ? AND request_id = ?`, senderID, requestID).Scan(
		&existing.ID, &existing.SenderID, &existing.RecipientID, &existing.Body, &existing.CreatedAt)
	if err == nil {
		if existing.RecipientID != recipientID || existing.Body != body {
			return chat.Message{}, chat.ErrRequestConflict
		}
		if err := tx.Commit(); err != nil {
			return chat.Message{}, fmt.Errorf("commit duplicate private message: %w", err)
		}
		return existing, nil
	}
	if !errors.Is(err, sql.ErrNoRows) {
		return chat.Message{}, fmt.Errorf("find private message retry: %w", err)
	}

	result, err := tx.ExecContext(ctx, `INSERT INTO chat_messages
			(room_id, sender_id, recipient_id, request_id, body)
			VALUES (NULL, ?, ?, ?, ?)`,
		senderID, recipientID, requestID, body)
	if err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "duplicate") {
			err = tx.QueryRowContext(ctx, `SELECT CAST(id AS CHAR), sender_id, recipient_id, body, created_at
					FROM chat_messages WHERE sender_id = ? AND request_id = ? FOR UPDATE`, senderID, requestID).Scan(
				&existing.ID, &existing.SenderID, &existing.RecipientID, &existing.Body, &existing.CreatedAt)
			if err != nil {
				return chat.Message{}, fmt.Errorf("read concurrent private message retry: %w", err)
			}
			if existing.RecipientID != recipientID || existing.Body != body {
				return chat.Message{}, chat.ErrRequestConflict
			}
			if err := tx.Commit(); err != nil {
				return chat.Message{}, fmt.Errorf("commit concurrent private message retry: %w", err)
			}
			return existing, nil
		}
		return chat.Message{}, fmt.Errorf("insert private message: %w", err)
	}
	messageID, err := result.LastInsertId()
	if err != nil {
		return chat.Message{}, fmt.Errorf("read private message ID: %w", err)
	}
	payload, err := json.Marshal(struct {
		MessageID   string `json:"message_id"`
		SenderID    string `json:"sender_user_id"`
		RecipientID string `json:"recipient_user_id"`
	}{strconv.FormatInt(messageID, 10), senderID, recipientID})
	if err != nil {
		return chat.Message{}, fmt.Errorf("encode private message event: %w", err)
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO outbox_events (event_type, aggregate_id, payload)
			VALUES ('PRIVATE_MESSAGE_CREATED', ?, ?)`, recipientID, payload); err != nil {
		return chat.Message{}, fmt.Errorf("store private message event: %w", err)
	}
	if err := tx.QueryRowContext(ctx, `SELECT created_at FROM chat_messages WHERE id = ?`, messageID).
		Scan(&existing.CreatedAt); err != nil {
		return chat.Message{}, fmt.Errorf("read private message timestamp: %w", err)
	}
	existing.ID = strconv.FormatInt(messageID, 10)
	existing.SenderID = senderID
	existing.RecipientID = recipientID
	existing.Body = body
	if err := tx.Commit(); err != nil {
		return chat.Message{}, fmt.Errorf("commit private message: %w", err)
	}
	return existing, nil
}

func (s *Store) ListPrivateMessages(
	ctx context.Context,
	userID, peerID string,
	offset, limit uint32,
) ([]chat.Message, error) {
	if limit == 0 || limit > 101 {
		return nil, chat.ErrInvalidInput
	}
	rows, err := s.db.QueryContext(ctx, `SELECT CAST(id AS CHAR), sender_id, recipient_id, body, created_at
			FROM chat_messages
			WHERE room_id IS NULL AND
				expires_at > UTC_TIMESTAMP(6) AND
				((sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?))
				AND NOT EXISTS (
					SELECT 1 FROM chat_message_hides hidden
					WHERE hidden.message_id = chat_messages.id AND hidden.user_id = ?
				)
			ORDER BY id LIMIT ? OFFSET ?`, userID, peerID, peerID, userID, userID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("list private messages: %w", err)
	}
	defer rows.Close()
	messages := make([]chat.Message, 0, limit)
	for rows.Next() {
		var message chat.Message
		if err := rows.Scan(&message.ID, &message.SenderID, &message.RecipientID, &message.Body, &message.CreatedAt); err != nil {
			return nil, fmt.Errorf("scan private message: %w", err)
		}
		messages = append(messages, message)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read private messages: %w", err)
	}
	return messages, nil
}

func (s *Store) HidePrivateMessage(ctx context.Context, userID, messageID string) error {
	result, err := s.db.ExecContext(ctx, `INSERT IGNORE INTO chat_message_hides (message_id, user_id)
		SELECT id, ? FROM chat_messages
		WHERE id = ? AND room_id IS NULL AND (sender_id = ? OR recipient_id = ?)`,
		userID, messageID, userID, userID)
	if err != nil {
		return fmt.Errorf("hide private message: %w", err)
	}
	if affected, err := result.RowsAffected(); err != nil {
		return fmt.Errorf("check private message visibility: %w", err)
	} else if affected == 0 {
		var exists bool
		if err := s.db.QueryRowContext(ctx, `SELECT EXISTS(
			SELECT 1 FROM chat_messages WHERE id = ? AND room_id IS NULL
			AND (sender_id = ? OR recipient_id = ?))`, messageID, userID, userID).Scan(&exists); err != nil {
			return fmt.Errorf("authorize private message hiding: %w", err)
		} else if !exists {
			return chat.ErrMessageNotFound
		}
	}
	return nil
}

func (s *Store) ReportPrivateMessage(ctx context.Context, userID, messageID, reason string) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin private message report: %w", err)
	}
	defer tx.Rollback()

	var authorizedMessageID string
	if err := tx.QueryRowContext(ctx, `SELECT CAST(id AS CHAR) FROM chat_messages
		WHERE id = ? AND room_id IS NULL AND recipient_id = ? FOR UPDATE`,
		messageID, userID).Scan(&authorizedMessageID); errors.Is(err, sql.ErrNoRows) {
		return chat.ErrMessageNotFound
	} else if err != nil {
		return fmt.Errorf("authorize private message report: %w", err)
	}
	if _, err := tx.ExecContext(ctx, `UPDATE chat_messages
		SET reported_at = COALESCE(reported_at, UTC_TIMESTAMP(6)) WHERE id = ?`, messageID); err != nil {
		return fmt.Errorf("retain reported private message: %w", err)
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO chat_message_reports (message_id, reporter_id, reason)
		VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE reason = VALUES(reason)`,
		messageID, userID, reason); err != nil {
		return fmt.Errorf("store private message report: %w", err)
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit private message report: %w", err)
	}
	return nil
}

func (s *Store) PurgeExpiredChatMessages(ctx context.Context, limit uint32) (int64, error) {
	if limit == 0 || limit > 10000 {
		return 0, chat.ErrInvalidInput
	}
	result, err := s.db.ExecContext(ctx, `DELETE FROM chat_messages
		WHERE room_id IS NULL AND expires_at <= UTC_TIMESTAMP(6) AND reported_at IS NULL
		AND NOT EXISTS (
			SELECT 1 FROM chat_message_reports reports WHERE reports.message_id = chat_messages.id
		)
		ORDER BY expires_at LIMIT ?`, limit)
	if err != nil {
		return 0, fmt.Errorf("purge expired private messages: %w", err)
	}
	deleted, err := result.RowsAffected()
	if err != nil {
		return 0, fmt.Errorf("count purged private messages: %w", err)
	}
	return deleted, nil
}

func (s *Store) CreateRoomInvite(ctx context.Context, userID, roomID, friendID string) error {
	if userID == "" || roomID == "" || friendID == "" || userID == friendID {
		return social.ErrInvalidInput
	}
	if s.roomManager == nil || !s.roomManager.CanInvite(roomID, userID) {
		return social.ErrRoomUnavailable
	}
	friendRoom := s.roomManager.IsFriendRoom(roomID)
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin room invitation: %w", err)
	}
	defer tx.Rollback()
	reservationID := ""
	defer func() {
		if reservationID != "" {
			s.roomManager.CancelFriendInvitation(roomID, reservationID)
		}
	}()
	if !s.roomManager.CanInvite(roomID, userID) {
		return social.ErrRoomUnavailable
	}
	var friendshipStatus string
	err = tx.QueryRowContext(ctx, `SELECT f.status FROM friendships f
		JOIN users u ON u.id = f.friend_id
		WHERE f.user_id = ? AND f.friend_id = ? AND u.status = 'ACTIVE'`, userID, friendID).Scan(&friendshipStatus)
	if errors.Is(err, sql.ErrNoRows) || err == nil && friendshipStatus != "ACCEPTED" {
		return social.ErrNotFriends
	}
	if err != nil {
		return fmt.Errorf("check room invitation friendship: %w", err)
	}
	if friendRoom {
		reservationID, err = s.roomManager.ReserveFriendInvitation(roomID, userID, friendID)
		if err != nil {
			return social.ErrRoomUnavailable
		}
	}
	payload, err := json.Marshal(struct {
		InviterID string `json:"inviter_user_id"`
		FriendID  string `json:"friend_user_id"`
		RoomID    string `json:"room_id"`
	}{userID, friendID, roomID})
	if err != nil {
		return fmt.Errorf("encode room invitation: %w", err)
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO outbox_events (event_type, aggregate_id, payload)
		VALUES ('FRIEND_ROOM_INVITE', ?, ?)`, friendID, payload); err != nil {
		return fmt.Errorf("store room invitation: %w", err)
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit room invitation: %w", err)
	}
	if reservationID != "" {
		s.roomManager.CommitFriendInvitation(roomID, reservationID)
		reservationID = ""
	}
	return nil
}

func (s *Store) ListRoomInvitations(ctx context.Context, userID string, offset, limit uint32) ([]social.RoomInvitation, error) {
	if userID == "" || limit == 0 || limit > 101 {
		return nil, social.ErrInvalidInput
	}
	invitations := make([]social.RoomInvitation, 0, limit)
	var rawOffset uint64
	var friendOffset uint64
	const batchSize uint32 = 128
	for uint32(len(invitations)) < limit {
		rows, err := s.db.QueryContext(ctx, `SELECT p.user_id, p.nickname, p.avatar, u.created_at,
			JSON_UNQUOTE(JSON_EXTRACT(e.payload, '$.room_id')), e.created_at
			FROM outbox_events e
			JOIN player_profiles p ON p.user_id = JSON_UNQUOTE(JSON_EXTRACT(e.payload, '$.inviter_user_id'))
			JOIN users u ON u.id = p.user_id
			WHERE e.aggregate_id = ? AND e.event_type = 'FRIEND_ROOM_INVITE' AND u.status = 'ACTIVE'
			ORDER BY e.id DESC LIMIT ? OFFSET ?`, userID, batchSize, rawOffset)
		if err != nil {
			return nil, fmt.Errorf("list room invitations: %w", err)
		}
		batchCount := uint64(0)
		for rows.Next() {
			batchCount++
			var invitation social.RoomInvitation
			if err := rows.Scan(
				&invitation.Inviter.UserID, &invitation.Inviter.Nickname, &invitation.Inviter.AvatarURL,
				&invitation.Inviter.CreatedAt, &invitation.RoomID, &invitation.InvitedAt,
			); err != nil {
				rows.Close()
				return nil, fmt.Errorf("scan room invitation: %w", err)
			}
			if s.roomManager == nil || !s.roomManager.IsFriendRoom(invitation.RoomID) {
				continue
			}
			if friendOffset < uint64(offset) {
				friendOffset++
				continue
			}
			invitations = append(invitations, invitation)
			friendOffset++
			if uint32(len(invitations)) == limit {
				break
			}
		}
		rowsErr := rows.Err()
		if err := rows.Close(); err != nil && rowsErr == nil {
			rowsErr = err
		}
		if rowsErr != nil {
			return nil, fmt.Errorf("read room invitations: %w", rowsErr)
		}
		rawOffset += batchCount
		if batchCount < uint64(batchSize) || uint32(len(invitations)) == limit {
			break
		}
	}
	return invitations, nil
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
	return hashSettlement(result, false)
}

func legacySettlementHash(result settlement.MatchResult) ([32]byte, error) {
	return hashSettlement(result, true)
}

func hashSettlement(result settlement.MatchResult, includeRanks bool) ([32]byte, error) {
	normalized := result
	normalized.Changes = append([]settlement.PointChange(nil), result.Changes...)
	if !includeRanks {
		for i := range normalized.Changes {
			normalized.Changes[i].Rank = ""
		}
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
	legacyRequestHash, err := legacySettlementHash(requested)
	if err != nil {
		return settlement.MatchResult{}, fmt.Errorf("hash legacy settlement: %w", err)
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
		if storedHash != requestHash && storedHash != legacyRequestHash {
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
			(game_session_id, user_id, delta, balance_after, rank_name, config_version, won)
			VALUES (?, ?, ?, ?, ?, ?, ?)`,
			requested.GameSessionID, player.change.UserID, player.delta, balanceAfter,
			rank, requested.ConfigVersion, player.change.Delta > 0); err != nil {
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
	_ auth.Repository                = (*Store)(nil)
	_ player.ProfileRepository       = (*Store)(nil)
	_ player.PublicProfileRepository = (*Store)(nil)
	_ coordinator.Repository         = (*Store)(nil)
	_ social.Repository              = (*Store)(nil)
	_ chat.Repository                = (*Store)(nil)
	_ settlement.Repository          = (*Store)(nil)
)
