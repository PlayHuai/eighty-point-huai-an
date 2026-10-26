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

func (r *publicProfileRepositoryStub) GetPublicProfile(_ context.Context, userID string) (PublicProfile, error) {
	r.userID = userID
	return r.profile, r.err
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
