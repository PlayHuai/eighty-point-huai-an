package auth

import "context"

type Credential struct {
	UserID       string
	Username     string
	PasswordHash []byte
}

type CredentialRepository interface {
	FindByUsername(ctx context.Context, username string) (Credential, error)
}
