package auth

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"net/mail"
	"strings"
	"time"
	"unicode"
	"unicode/utf8"

	"golang.org/x/crypto/argon2"
)

const (
	accessTokenLifetime  = 7 * 24 * time.Hour
	refreshTokenLifetime = 30 * 24 * time.Hour
	passwordSaltSize     = 16
	passwordKeySize      = 32
	passwordMemory       = 64 * 1024
	passwordIterations   = 3
	passwordParallelism  = 2
)

var (
	ErrInvalidCredentials = errors.New("invalid credentials")
	ErrInvalidInput       = errors.New("invalid input")
	ErrUnauthenticated    = errors.New("unauthenticated")
)

type Profile struct {
	UserID    string
	Nickname  string
	CreatedAt time.Time
}

type Result struct {
	AccessToken          string
	RefreshToken         string
	AccessTokenExpiresAt time.Time
	Profile              Profile
}

type Service struct {
	repository Repository
	dummyHash  []byte
}

func NewService(repository Repository) (*Service, error) {
	if repository == nil {
		return nil, errors.New("auth repository is required")
	}
	dummyHash, err := hashPassword("invalid-login-credential")
	if err != nil {
		return nil, err
	}
	return &Service{repository: repository, dummyHash: dummyHash}, nil
}

func (s *Service) Register(ctx context.Context, account, password, nickname string) (Result, error) {
	normalized, isEmail, err := normalizeAccount(account)
	if err != nil || !validPassword(password) || !validNickname(nickname) {
		return Result{}, ErrInvalidInput
	}
	hash, err := hashPassword(password)
	if err != nil {
		return Result{}, err
	}
	userID, err := randomID()
	if err != nil {
		return Result{}, err
	}
	credential := NewAccount{
		UserID: userID, Account: normalized, Email: isEmail,
		Nickname: strings.TrimSpace(nickname), PasswordHash: hash,
	}
	if err := s.repository.CreateAccount(ctx, credential); err != nil {
		return Result{}, err
	}
	return s.createSession(ctx, Profile{
		UserID: userID, Nickname: credential.Nickname, CreatedAt: time.Now().UTC(),
	}, "")
}

func (s *Service) Login(ctx context.Context, account, password, deviceID string) (Result, error) {
	normalized, isEmail, err := normalizeAccount(account)
	if err != nil || !validExistingPassword(password) {
		return Result{}, ErrInvalidCredentials
	}
	if len(deviceID) > 128 || strings.ContainsAny(deviceID, "\x00\r\n") || !utf8.ValidString(deviceID) {
		return Result{}, ErrInvalidInput
	}
	credential, err := s.repository.FindByAccount(ctx, normalized, isEmail)
	if errors.Is(err, ErrCredentialNotFound) {
		verifyPassword(password, s.dummyHash)
		return Result{}, ErrInvalidCredentials
	}
	if err == nil && !verifyPassword(password, credential.PasswordHash) {
		return Result{}, ErrInvalidCredentials
	}
	if err != nil {
		return Result{}, err
	}
	return s.createSession(ctx, Profile{
		UserID: credential.UserID, Nickname: credential.Nickname, CreatedAt: credential.CreatedAt,
	}, deviceID)
}

func (s *Service) Refresh(ctx context.Context, refreshToken string) (Result, error) {
	if !validOpaqueToken(refreshToken) {
		return Result{}, ErrUnauthenticated
	}
	refreshHash := hashToken(refreshToken)
	accessToken, err := randomToken()
	if err != nil {
		return Result{}, err
	}
	newRefreshToken, err := randomToken()
	if err != nil {
		return Result{}, err
	}
	now := time.Now().UTC()
	replacement := Session{
		RefreshTokenHash:     hashToken(newRefreshToken),
		AccessTokenHash:      hashToken(accessToken),
		ExpiresAt:            now.Add(refreshTokenLifetime),
		AccessTokenExpiresAt: now.Add(accessTokenLifetime),
	}
	session, err := s.repository.RotateSession(ctx, refreshHash, replacement, now)
	if err != nil {
		if errors.Is(err, ErrInvalidSession) {
			return Result{}, ErrUnauthenticated
		}
		return Result{}, err
	}
	return Result{
		AccessToken: accessToken, RefreshToken: newRefreshToken,
		AccessTokenExpiresAt: replacement.AccessTokenExpiresAt,
		Profile: Profile{
			UserID: session.UserID, Nickname: session.Nickname, CreatedAt: session.UserCreatedAt,
		},
	}, nil
}

func (s *Service) Logout(ctx context.Context, refreshToken string) error {
	if !validOpaqueToken(refreshToken) {
		return ErrUnauthenticated
	}
	return s.repository.RevokeSession(ctx, hashToken(refreshToken), time.Now().UTC())
}

func (s *Service) ChangePassword(ctx context.Context, userID, currentPassword, newPassword string) error {
	if userID == "" || !validExistingPassword(currentPassword) || !validPassword(newPassword) {
		return ErrInvalidInput
	}
	credential, err := s.repository.FindByUserID(ctx, userID)
	if errors.Is(err, ErrCredentialNotFound) || (err == nil && !verifyPassword(currentPassword, credential.PasswordHash)) {
		return ErrInvalidCredentials
	}
	if err != nil {
		return err
	}
	hash, err := hashPassword(newPassword)
	if err != nil {
		return err
	}
	return s.repository.UpdatePasswordAndRevokeSessions(ctx, userID, hash, time.Now().UTC())
}

func (s *Service) AuthenticateAccess(ctx context.Context, token string) (string, error) {
	if !validOpaqueToken(token) {
		return "", ErrUnauthenticated
	}
	userID, err := s.repository.AuthenticateAccess(ctx, hashToken(token), time.Now().UTC())
	if err != nil || userID == "" {
		return "", ErrUnauthenticated
	}
	return userID, nil
}

func (s *Service) createSession(ctx context.Context, profile Profile, deviceID string) (Result, error) {
	accessToken, err := randomToken()
	if err != nil {
		return Result{}, err
	}
	refreshToken, err := randomToken()
	if err != nil {
		return Result{}, err
	}
	sessionID, err := randomID()
	if err != nil {
		return Result{}, err
	}
	now := time.Now().UTC()
	session := Session{
		ID: sessionID, UserID: profile.UserID, DeviceID: deviceID,
		Nickname: profile.Nickname, UserCreatedAt: profile.CreatedAt,
		RefreshTokenHash:     hashToken(refreshToken),
		AccessTokenHash:      hashToken(accessToken),
		ExpiresAt:            now.Add(refreshTokenLifetime),
		AccessTokenExpiresAt: now.Add(accessTokenLifetime),
	}
	if err := s.repository.CreateSession(ctx, session); err != nil {
		return Result{}, err
	}
	return Result{
		AccessToken: accessToken, RefreshToken: refreshToken,
		AccessTokenExpiresAt: session.AccessTokenExpiresAt, Profile: profile,
	}, nil
}

func normalizeAccount(account string) (string, bool, error) {
	account = strings.TrimSpace(account)
	if !utf8.ValidString(account) {
		return "", false, ErrInvalidInput
	}
	if strings.Contains(account, "@") {
		parsed, err := mail.ParseAddress(account)
		if err != nil || parsed.Address != account || len(account) > 254 {
			return "", false, ErrInvalidInput
		}
		return strings.ToLower(account), true, nil
	}
	if len(account) < 3 || len(account) > 64 || strings.ContainsAny(account, "\x00\r\n\t ") {
		return "", false, ErrInvalidInput
	}
	return strings.ToLower(account), false, nil
}

func validPassword(password string) bool {
	if !validExistingPassword(password) || !utf8.ValidString(password) {
		return false
	}
	hasLetter, hasDigit := false, false
	for _, character := range password {
		hasLetter = hasLetter || unicode.IsLetter(character)
		hasDigit = hasDigit || unicode.IsDigit(character)
	}
	return hasLetter && hasDigit
}

func validExistingPassword(password string) bool {
	return len(password) >= 8 && len(password) <= 128
}

func validNickname(nickname string) bool {
	nickname = strings.TrimSpace(nickname)
	return nickname != "" && utf8.ValidString(nickname) && utf8.RuneCountInString(nickname) <= 64
}

func hashPassword(password string) ([]byte, error) {
	salt := make([]byte, passwordSaltSize)
	if _, err := rand.Read(salt); err != nil {
		return nil, err
	}
	key := argon2.IDKey([]byte(password), salt, passwordIterations, passwordMemory, passwordParallelism, passwordKeySize)
	encoded := "$argon2id$v=19$m=65536,t=3,p=2$" +
		base64.RawStdEncoding.EncodeToString(salt) + "$" +
		base64.RawStdEncoding.EncodeToString(key)
	return []byte(encoded), nil
}

func verifyPassword(password string, encoded []byte) bool {
	parts := strings.Split(string(encoded), "$")
	if len(parts) != 6 || parts[1] != "argon2id" || parts[2] != "v=19" || parts[3] != "m=65536,t=3,p=2" {
		return false
	}
	salt, err := base64.RawStdEncoding.DecodeString(parts[4])
	if err != nil || len(salt) != passwordSaltSize {
		return false
	}
	want, err := base64.RawStdEncoding.DecodeString(parts[5])
	if err != nil || len(want) != passwordKeySize {
		return false
	}
	got := argon2.IDKey([]byte(password), salt, passwordIterations, passwordMemory, passwordParallelism, passwordKeySize)
	return subtle.ConstantTimeCompare(got, want) == 1
}

func randomToken() (string, error) {
	value := make([]byte, 32)
	if _, err := rand.Read(value); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(value), nil
}

func randomID() (string, error) {
	value := make([]byte, 16)
	if _, err := rand.Read(value); err != nil {
		return "", err
	}
	return hex.EncodeToString(value), nil
}

func hashToken(token string) [32]byte {
	return sha256.Sum256([]byte(token))
}

func validOpaqueToken(token string) bool {
	if len(token) != 43 {
		return false
	}
	decoded, err := base64.RawURLEncoding.DecodeString(token)
	return err == nil && len(decoded) == 32
}
