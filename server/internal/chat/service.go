package chat

import (
	"context"
	"errors"
	"strconv"
	"strings"
	"unicode/utf8"
)

var (
	ErrInvalidInput     = errors.New("invalid chat input")
	ErrNotFriends       = errors.New("private chat requires an accepted friendship")
	ErrRequestConflict  = errors.New("request ID was reused with a different message")
	ErrMessageNotFound  = errors.New("chat message not found")
)

const (
	defaultPageSize = 20
	maxPageSize     = 100
	maxPageOffset   = 1_000_000
	maxMessageRunes = 1000
)

type Page struct {
	Messages      []Message
	NextPageToken string
}

type Service struct {
	repository Repository
	publisher  Publisher
}

func NewService(repository Repository, publisher Publisher) (*Service, error) {
	if repository == nil {
		return nil, errors.New("chat repository is required")
	}
	return &Service{repository: repository, publisher: publisher}, nil
}

func (s *Service) SendPrivateMessage(
	ctx context.Context,
	senderID, recipientID, requestID, body string,
) (Message, error) {
	body = strings.TrimSpace(body)
	if !validID(senderID) || !validID(recipientID) || senderID == recipientID ||
		!validRequestID(requestID) || body == "" || !utf8.ValidString(body) ||
		utf8.RuneCountInString(body) > maxMessageRunes {
		return Message{}, ErrInvalidInput
	}
	message, err := s.repository.SendPrivateMessage(ctx, senderID, recipientID, requestID, body)
	if err != nil {
		return Message{}, err
	}
	if s.publisher != nil {
		s.publisher.PublishPrivateMessage(senderID, message)
		s.publisher.PublishPrivateMessage(recipientID, message)
	}
	return message, nil
}

func (s *Service) ListPrivateMessages(
	ctx context.Context,
	userID, peerID, pageToken string,
	pageSize uint32,
) (Page, error) {
	if !validID(userID) || !validID(peerID) || userID == peerID {
		return Page{}, ErrInvalidInput
	}
	offset, limit, err := pageWindow(pageToken, pageSize)
	if err != nil {
		return Page{}, err
	}
	messages, err := s.repository.ListPrivateMessages(ctx, userID, peerID, offset, limit+1)
	if err != nil {
		return Page{}, err
	}
	next := ""
	if uint32(len(messages)) > limit {
		messages = messages[:limit]
		next = strconv.FormatUint(uint64(offset+limit), 10)
	}
	return Page{Messages: messages, NextPageToken: next}, nil
}

func pageWindow(token string, requestedSize uint32) (uint32, uint32, error) {
	var offset uint64
	if token != "" {
		value, err := strconv.ParseUint(token, 10, 32)
		if err != nil {
			return 0, 0, ErrInvalidInput
		}
		offset = value
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

func validRequestID(value string) bool {
	if value == "" || len(value) > 128 || !utf8.ValidString(value) {
		return false
	}
	for _, char := range value {
		if char < 0x21 || char > 0x7e {
			return false
		}
	}
	return true
}
