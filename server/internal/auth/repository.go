package auth

import (
	"context"
	"errors"
	"time"
)

var (
	ErrAccountExists      = errors.New("account already exists")
	ErrCredentialNotFound = errors.New("credential not found")
	ErrInvalidSession     = errors.New("invalid session")
)

type Credential struct {
	UserID        string
	Nickname      string
	PasswordHash  []byte
	CreatedAt     time.Time
	WeChatAccount bool
}

type NewAccount struct {
	UserID       string
	Account      string
	Email        bool
	Nickname     string
	PasswordHash []byte
}

type NewWeChatAccount struct {
	UserID       string
	OpenID       string
	Nickname     string
	PasswordHash []byte
}

type Session struct {
	ID                   string
	UserID               string
	DeviceID             string
	Nickname             string
	UserCreatedAt        time.Time
	RefreshTokenHash     [32]byte
	AccessTokenHash      [32]byte
	ExpiresAt            time.Time
	AccessTokenExpiresAt time.Time
}

type Repository interface {
	FindByAccount(ctx context.Context, account string, email bool) (Credential, error)
	FindByUserID(ctx context.Context, userID string) (Credential, error)
	FindByWeChatOpenID(ctx context.Context, openID string) (Credential, error)
	CreateAccount(ctx context.Context, account NewAccount) error
	CreateWeChatAccount(ctx context.Context, account NewWeChatAccount) error
	UpdatePasswordAndRevokeSessions(ctx context.Context, userID string, passwordHash []byte, now time.Time) error
	CreateSession(ctx context.Context, session Session) error
	RotateSession(ctx context.Context, refreshTokenHash [32]byte, replacement Session, now time.Time) (Session, error)
	RevokeSession(ctx context.Context, refreshTokenHash [32]byte, now time.Time) error
	AuthenticateAccess(ctx context.Context, accessTokenHash [32]byte, now time.Time) (string, error)
}
