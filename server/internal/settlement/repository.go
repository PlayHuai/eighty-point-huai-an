package settlement

import "context"

type PointChange struct {
	UserID string
	Delta  int64
	Rank   string
}

type MatchResult struct {
	GameSessionID    string
	Winner           string
	LevelDifference  uint8
	EndType          string
	HallMultiplierBP uint32
	ConfigVersion    uint64
	Changes          []PointChange
}

type Repository interface {
	Settle(ctx context.Context, result MatchResult) (MatchResult, error)
}
