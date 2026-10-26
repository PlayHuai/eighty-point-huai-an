package social

import (
	"context"
	"errors"
	"fmt"
	"strconv"
	"strings"
	"unicode/utf8"
)

const (
	defaultPageSize = 20
	maxPageSize     = 100
	maxPageOffset   = 1_000_000
)

type Page[T any] struct {
	Items         []T
	NextPageToken string
}

type Service struct {
	repository Repository
}

func NewService(repository Repository) (*Service, error) {
	if repository == nil {
		return nil, errors.New("social repository is required")
	}
	return &Service{repository: repository}, nil
}

func (s *Service) SearchPlayers(ctx context.Context, userID, query, pageToken string, pageSize uint32) (Page[Player], error) {
	query = strings.TrimSpace(query)
	if !validID(userID) || query == "" || !utf8.ValidString(query) || utf8.RuneCountInString(query) > 128 {
		return Page[Player]{}, ErrInvalidInput
	}
	offset, limit, err := pageWindow(pageToken, pageSize)
	if err != nil {
		return Page[Player]{}, err
	}
	players, err := s.repository.SearchPlayers(ctx, query, userID, offset, limit+1)
	if err != nil {
		return Page[Player]{}, err
	}
	var next string
	if uint32(len(players)) > limit {
		players = players[:limit]
		next = strconv.FormatUint(uint64(offset+limit), 10)
	}
	return Page[Player]{Items: players, NextPageToken: next}, nil
}

func (s *Service) SendFriendRequest(ctx context.Context, userID, targetUserID string) error {
	if !validID(userID) || !validID(targetUserID) || userID == targetUserID {
		return ErrInvalidInput
	}
	return s.repository.SendFriendRequest(ctx, userID, targetUserID)
}

func (s *Service) RespondFriendRequest(ctx context.Context, userID, requesterID string, accept bool) error {
	if !validID(userID) || !validID(requesterID) || userID == requesterID {
		return ErrInvalidInput
	}
	return s.repository.RespondFriendRequest(ctx, requesterID, userID, accept)
}

func (s *Service) ListFriends(ctx context.Context, userID, pageToken string, pageSize uint32) (Page[Friend], error) {
	if !validID(userID) {
		return Page[Friend]{}, ErrInvalidInput
	}
	offset, limit, err := pageWindow(pageToken, pageSize)
	if err != nil {
		return Page[Friend]{}, err
	}
	friends, err := s.repository.ListFriends(ctx, userID, offset, limit+1)
	if err != nil {
		return Page[Friend]{}, err
	}
	var next string
	if uint32(len(friends)) > limit {
		friends = friends[:limit]
		next = strconv.FormatUint(uint64(offset+limit), 10)
	}
	return Page[Friend]{Items: friends, NextPageToken: next}, nil
}

func (s *Service) RemoveFriend(ctx context.Context, userID, friendID string) error {
	if !validID(userID) || !validID(friendID) || userID == friendID {
		return ErrInvalidInput
	}
	return s.repository.RemoveFriend(ctx, userID, friendID)
}

func (s *Service) SendRoomInvite(ctx context.Context, userID, roomID, friendID string) error {
	if !validID(userID) || !validID(roomID) || !validID(friendID) || userID == friendID {
		return ErrInvalidInput
	}
	return s.repository.CreateRoomInvite(ctx, userID, roomID, friendID)
}

func pageWindow(token string, requestedSize uint32) (uint32, uint32, error) {
	var offset uint64
	if token != "" {
		parsed, err := strconv.ParseUint(token, 10, 32)
		if err != nil {
			return 0, 0, fmt.Errorf("%w: invalid page token", ErrInvalidInput)
		}
		offset = parsed
	}
	limit := requestedSize
	if limit == 0 {
		limit = defaultPageSize
	}
	if limit > maxPageSize || offset > maxPageOffset || offset+uint64(limit)+1 > uint64(^uint32(0)) {
		return 0, 0, ErrInvalidInput
	}
	return uint32(offset), limit, nil
}

func validID(value string) bool {
	return value != "" && len(value) <= 64 && utf8.ValidString(value)
}
