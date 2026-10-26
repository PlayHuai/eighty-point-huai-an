package player

import (
	"context"
	"errors"
	"strings"
	"unicode/utf8"
)

var (
	ErrInvalidProfile  = errors.New("invalid player profile")
	ErrProfileNotFound = errors.New("player profile not found")
)

type PublicProfileService struct {
	repository PublicProfileRepository
}

func NewPublicProfileService(repository PublicProfileRepository) (*PublicProfileService, error) {
	if repository == nil {
		return nil, errors.New("public profile repository is required")
	}
	return &PublicProfileService{repository: repository}, nil
}

func (s *PublicProfileService) Get(ctx context.Context, userID string) (PublicProfile, error) {
	if userID == "" || len(userID) > 64 || !utf8.ValidString(userID) {
		return PublicProfile{}, ErrInvalidProfile
	}
	return s.repository.GetPublicProfile(ctx, userID)
}

func (s *PublicProfileService) Update(ctx context.Context, userID, nickname, avatarURL string) (PublicProfile, error) {
	nickname = strings.TrimSpace(nickname)
	if userID == "" || len(userID) > 64 || !utf8.ValidString(userID) || nickname == "" || !utf8.ValidString(nickname) ||
		!utf8.ValidString(avatarURL) || utf8.RuneCountInString(nickname) > 64 ||
		utf8.RuneCountInString(avatarURL) > 512 {
		return PublicProfile{}, ErrInvalidProfile
	}
	return s.repository.UpdatePublicProfile(ctx, userID, nickname, avatarURL)
}
