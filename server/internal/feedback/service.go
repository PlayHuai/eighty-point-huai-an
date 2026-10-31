package feedback

import (
	"context"
	"errors"
	"regexp"
	"strings"
	"unicode/utf8"
)

var (
	ErrInvalidInput    = errors.New("invalid feedback")
	ErrRequestConflict = errors.New("feedback request ID already used with different content")
	requestIDPattern   = regexp.MustCompile(`^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$`)
)

type Repository interface {
	SaveFeedback(ctx context.Context, userID, requestID, kind, body string) error
}

type Service struct {
	repository Repository
}

func NewService(repository Repository) (*Service, error) {
	if repository == nil {
		return nil, errors.New("feedback repository is required")
	}
	return &Service{repository: repository}, nil
}

func (s *Service) Submit(ctx context.Context, userID, requestID, kind, body string) error {
	body = strings.TrimSpace(body)
	if userID == "" || !requestIDPattern.MatchString(requestID) ||
		(kind != "bug" && kind != "suggestion") ||
		body == "" || !utf8.ValidString(body) || utf8.RuneCountInString(body) > 2000 {
		return ErrInvalidInput
	}
	return s.repository.SaveFeedback(ctx, userID, strings.ToLower(requestID), kind, body)
}
