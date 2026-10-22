package player

import "context"

type Profile struct {
	UserID string
	Points int64
	Rank   string
}

type ProfileRepository interface {
	FindProfile(ctx context.Context, userID string) (Profile, error)
	SaveProfile(ctx context.Context, profile Profile) error
}
