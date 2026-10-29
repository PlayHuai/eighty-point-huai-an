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

type Statistics struct {
	TotalGames int64
	Wins       int64
	Losses     int64
	Points     int64
	Rank       string
}

type RecentResult struct {
	GameSessionID string
	Won           bool
	PointsDelta   int64
	EndedAt       time.Time
}

type StatisticsRepository interface {
	AreFriends(ctx context.Context, firstUserID, secondUserID string) (bool, error)
	GetStatistics(ctx context.Context, userID string) (Statistics, error)
	ListRecentResults(ctx context.Context, userID string, offset, limit uint32) ([]RecentResult, error)
}
