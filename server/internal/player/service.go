package player

import (
	"context"
	"errors"
	"strconv"
	"strings"
	"unicode/utf8"
)

var (
	ErrInvalidProfile  = errors.New("invalid player profile")
	ErrProfileNotFound = errors.New("player profile not found")
	ErrFriendRequired  = errors.New("friend relationship required")
	ErrInvalidPage     = errors.New("invalid results page")
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

func (s *PublicProfileService) GetStatistics(ctx context.Context, viewerID, targetID string) (Statistics, error) {
	targetID, err := s.authorizedTarget(ctx, viewerID, targetID)
	if err != nil {
		return Statistics{}, err
	}
	repository, ok := s.repository.(StatisticsRepository)
	if !ok {
		return Statistics{}, errors.New("player statistics repository is unavailable")
	}
	return repository.GetStatistics(ctx, targetID)
}

func (s *PublicProfileService) ListRecentResults(
	ctx context.Context,
	viewerID, targetID, pageToken string,
	pageSize uint32,
) ([]RecentResult, string, error) {
	targetID, err := s.authorizedTarget(ctx, viewerID, targetID)
	if err != nil {
		return nil, "", err
	}
	offset, limit, err := resultPageWindow(pageToken, pageSize)
	if err != nil {
		return nil, "", err
	}
	repository, ok := s.repository.(StatisticsRepository)
	if !ok {
		return nil, "", errors.New("player results repository is unavailable")
	}
	results, err := repository.ListRecentResults(ctx, targetID, offset, limit+1)
	if err != nil {
		return nil, "", err
	}
	next := ""
	if uint32(len(results)) > limit {
		results = results[:limit]
		next = strconv.FormatUint(uint64(offset+limit), 10)
	}
	return results, next, nil
}

func (s *PublicProfileService) authorizedTarget(ctx context.Context, viewerID, targetID string) (string, error) {
	if viewerID == "" || len(viewerID) > 64 || !utf8.ValidString(viewerID) {
		return "", ErrInvalidProfile
	}
	if targetID == "" {
		targetID = viewerID
	}
	if targetID == "" || len(targetID) > 64 || !utf8.ValidString(targetID) {
		return "", ErrInvalidProfile
	}
	if targetID == viewerID {
		return targetID, nil
	}
	repository, ok := s.repository.(StatisticsRepository)
	if !ok {
		return "", errors.New("player statistics repository is unavailable")
	}
	friends, err := repository.AreFriends(ctx, viewerID, targetID)
	if err != nil {
		return "", err
	}
	if !friends {
		return "", ErrFriendRequired
	}
	return targetID, nil
}

func resultPageWindow(token string, requestedSize uint32) (uint32, uint32, error) {
	var offset uint64
	if token != "" {
		value, err := strconv.ParseUint(token, 10, 32)
		if err != nil {
			return 0, 0, ErrInvalidPage
		}
		offset = value
	}
	limit := requestedSize
	if limit == 0 {
		limit = 20
	}
	if limit > 100 || offset > 1_000_000 || offset+uint64(limit)+1 > uint64(^uint32(0)) {
		return 0, 0, ErrInvalidPage
	}
	return uint32(offset), limit, nil
}
