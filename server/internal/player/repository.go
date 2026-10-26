package player

import (
	"context"
	"time"
)

type Profile struct {
	UserID string
	Points int64
	Rank   string
}

type ProfileRepository interface {
	FindProfile(ctx context.Context, userID string) (Profile, error)
	SaveProfile(ctx context.Context, profile Profile) error
}

type PublicProfile struct {
	UserID    string
	Nickname  string
	AvatarURL string
	CreatedAt time.Time
}

type PublicProfileRepository interface {
	GetPublicProfile(ctx context.Context, userID string) (PublicProfile, error)
	UpdatePublicProfile(ctx context.Context, userID, nickname, avatarURL string) (PublicProfile, error)
}
