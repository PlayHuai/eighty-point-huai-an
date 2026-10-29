package player

import (
	"context"
	"errors"
	"strings"
	"testing"
	"time"
)

type publicProfileRepositoryStub struct {
	profile  PublicProfile
	userID   string
	nickname string
	avatar   string
	err      error
}

type statisticsRepositoryStub struct {
	publicProfileRepositoryStub
	friends   bool
	statistics Statistics
	results    []RecentResult
	targetID   string
	offset     uint32
	limit      uint32
}

func (r *statisticsRepositoryStub) AreFriends(_ context.Context, _, targetID string) (bool, error) {
	r.targetID = targetID
	return r.friends, nil
}

func (r *statisticsRepositoryStub) GetStatistics(_ context.Context, userID string) (Statistics, error) {
	r.targetID = userID
	return r.statistics, nil
}

func (r *statisticsRepositoryStub) ListRecentResults(_ context.Context, userID string, offset, limit uint32) ([]RecentResult, error) {
	r.targetID, r.offset, r.limit = userID, offset, limit
	return r.results, nil
}

func (r *publicProfileRepositoryStub) GetPublicProfile(_ context.Context, userID string) (PublicProfile, error) {
	r.userID = userID
	return r.profile, r.err
}

func TestPublicProfileServiceStatisticsAreLimitedToFriends(t *testing.T) {
	repository := &statisticsRepositoryStub{
		friends: true,
		statistics: Statistics{
			TotalGames: 12, Wins: 7, Losses: 5, Points: 900, Rank: "青铜",
		},
		results: []RecentResult{
			{GameSessionID: "game-1", Won: true, PointsDelta: 25},
			{GameSessionID: "game-2", Won: false, PointsDelta: -25},
		},
	}
	service, err := NewPublicProfileService(repository)
	if err != nil {
		t.Fatal(err)
	}

	stats, err := service.GetStatistics(context.Background(), "viewer", "friend")
	if err != nil || stats != repository.statistics || repository.targetID != "friend" {
		t.Fatalf("GetStatistics() = %+v, %v; repository = %+v", stats, err, repository)
	}
	results, next, err := service.ListRecentResults(context.Background(), "viewer", "friend", "5", 1)
	if err != nil || len(results) != 1 || results[0].GameSessionID != "game-1" ||
		next != "6" || repository.targetID != "friend" || repository.offset != 5 || repository.limit != 2 {
		t.Fatalf("ListRecentResults() = %+v, %q, %v; repository = %+v", results, next, err, repository)
	}
}

func TestPublicProfileServiceRejectsNonFriendStatisticsAndInvalidPages(t *testing.T) {
	repository := &statisticsRepositoryStub{}
	service, err := NewPublicProfileService(repository)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := service.GetStatistics(context.Background(), "viewer", "stranger"); !errors.Is(err, ErrFriendRequired) {
		t.Fatalf("GetStatistics() error = %v, want ErrFriendRequired", err)
	}
	if _, _, err := service.ListRecentResults(context.Background(), "viewer", "viewer", "invalid", 10); !errors.Is(err, ErrInvalidPage) {
		t.Fatalf("ListRecentResults() error = %v, want ErrInvalidPage", err)
	}
}

func (r *publicProfileRepositoryStub) UpdatePublicProfile(_ context.Context, userID, nickname, avatarURL string) (PublicProfile, error) {
	r.userID, r.nickname, r.avatar = userID, nickname, avatarURL
	return r.profile, r.err
}

func TestPublicProfileService(t *testing.T) {
	want := PublicProfile{
		UserID: "player-1", Nickname: "Alice", AvatarURL: "https://example.test/avatar.png",
		CreatedAt: time.Date(2026, 1, 2, 3, 4, 5, 0, time.UTC),
	}
	repository := &publicProfileRepositoryStub{profile: want}
	service, err := NewPublicProfileService(repository)
	if err != nil {
		t.Fatal(err)
	}

	got, err := service.Get(context.Background(), "player-1")
	if err != nil || got != want || repository.userID != "player-1" {
		t.Fatalf("Get() = %+v, %v; repository user = %q", got, err, repository.userID)
	}

	got, err = service.Update(context.Background(), "player-1", " Alice ", want.AvatarURL)
	if err != nil || got != want || repository.userID != "player-1" ||
		repository.nickname != "Alice" || repository.avatar != want.AvatarURL {
		t.Fatalf("Update() = %+v, %v; repository = %+v", got, err, repository)
	}
}

func TestPublicProfileServiceRejectsInvalidInputAndPropagatesErrors(t *testing.T) {
	repository := &publicProfileRepositoryStub{}
	service, err := NewPublicProfileService(repository)
	if err != nil {
		t.Fatal(err)
	}
	for _, input := range []struct {
		userID, nickname, avatar string
	}{
		{"", "Alice", ""},
		{"player-1", " ", ""},
		{"player-1", strings.Repeat("a", 65), ""},
		{"player-1", "Alice", string(make([]rune, 513))},
	} {
		if _, err := service.Update(context.Background(), input.userID, input.nickname, input.avatar); !errors.Is(err, ErrInvalidProfile) {
			t.Errorf("Update(%q, %q) error = %v, want ErrInvalidProfile", input.userID, input.nickname, err)
		}
	}
	if _, err := service.Get(context.Background(), ""); !errors.Is(err, ErrInvalidProfile) {
		t.Fatalf("Get with empty identity error = %v, want ErrInvalidProfile", err)
	}

	repository.err = ErrProfileNotFound
	if _, err := service.Get(context.Background(), "missing"); !errors.Is(err, ErrProfileNotFound) {
		t.Fatalf("Get error = %v, want ErrProfileNotFound", err)
	}
}
