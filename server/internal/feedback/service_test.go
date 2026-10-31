package feedback

import (
	"context"
	"errors"
	"strings"
	"testing"
)

type repositoryStub struct {
	userID, requestID, kind, body string
	calls                         int
	err                           error
}

func (r *repositoryStub) SaveFeedback(_ context.Context, userID, requestID, kind, body string) error {
	r.userID, r.requestID, r.kind, r.body = userID, requestID, kind, body
	r.calls++
	return r.err
}

func TestSubmitValidatesAndNormalizesFeedback(t *testing.T) {
	const id = "ABCDEF00-0000-4000-8000-000000000001"
	for _, kind := range []string{"bug", "suggestion"} {
		repo := &repositoryStub{}
		service, err := NewService(repo)
		if err != nil {
			t.Fatal(err)
		}
		if err := service.Submit(context.Background(), "player", id, kind, "  测试反馈  "); err != nil {
			t.Fatal(err)
		}
		if repo.userID != "player" || repo.requestID != strings.ToLower(id) || repo.kind != kind || repo.body != "测试反馈" {
			t.Fatalf("unexpected stored feedback: %+v", repo)
		}
		if err := service.Submit(context.Background(), "player", id, kind, strings.Repeat("测", 2000)); err != nil {
			t.Fatalf("2000 characters must be accepted: %v", err)
		}
	}
	for _, input := range []struct{ user, request, kind, body string }{
		{"", id, "bug", "body"},
		{"player", "", "bug", "body"},
		{"player", "not-a-uuid", "bug", "body"},
		{"player", id, "", "body"},
		{"player", id, "other", "body"},
		{"player", id, "bug", " \n\t"},
		{"player", id, "bug", strings.Repeat("测", 2001)},
		{"player", id, "bug", string([]byte{0xff})},
	} {
		repo := &repositoryStub{}
		service, _ := NewService(repo)
		err := service.Submit(context.Background(), input.user, input.request, input.kind, input.body)
		if !errors.Is(err, ErrInvalidInput) || repo.calls != 0 {
			t.Fatalf("invalid feedback reached repository: %+v, %v", input, err)
		}
	}
}

func TestSubmitPropagatesRepositoryError(t *testing.T) {
	repo := &repositoryStub{err: ErrRequestConflict}
	service, _ := NewService(repo)
	if err := service.Submit(context.Background(), "player", "00000000-0000-4000-8000-000000000001", "bug", "body"); !errors.Is(err, ErrRequestConflict) {
		t.Fatalf("expected request conflict, got %v", err)
	}
}
