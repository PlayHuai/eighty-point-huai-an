package settlement

import (
	"context"
	"errors"
	"math"
)

var ErrInvalidResult = errors.New("invalid match result")

const SpringEndType = "SPRING"

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

func PointsFor(levelDifference uint8, endType string, hallMultiplierBP uint32) (int64, error) {
	if levelDifference < 1 || levelDifference > 12 || hallMultiplierBP == 0 ||
		(endType == SpringEndType && levelDifference != 12) {
		return 0, ErrInvalidResult
	}

	perLevel := int64(5)
	switch {
	case levelDifference == 12 && endType == SpringEndType:
		perLevel = 40
	case levelDifference == 12:
		perLevel = 15
	case levelDifference >= 6:
		perLevel = 10
	}

	base := int64(levelDifference) * perLevel
	if base > math.MaxInt64/int64(hallMultiplierBP) {
		return 0, ErrInvalidResult
	}
	points := base * int64(hallMultiplierBP) / 10000
	if points == 0 {
		return 0, ErrInvalidResult
	}
	return points, nil
}

func RankForPoints(points int64) (string, error) {
	if points < 0 {
		return "", ErrInvalidResult
	}
	switch {
	case points < 1000:
		return "青铜", nil
	case points < 3000:
		return "白银", nil
	case points < 6000:
		return "黄金", nil
	case points < 10000:
		return "铂金", nil
	case points < 16000:
		return "钻石", nil
	case points < 24000:
		return "大师", nil
	case points < 40000:
		return "宗师", nil
	default:
		return "王者", nil
	}
}
