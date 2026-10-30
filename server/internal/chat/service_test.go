package chat

import (
	"context"
	"errors"
	"fmt"
	"reflect"
	"testing"
	"time"
)

type testRepository struct {
	messages []Message
	sent     []Message
	sendErr  error
	hidden   []string
	reports  []string
}

func (r *testRepository) SendPrivateMessage(
	_ context.Context,
	senderID, recipientID, requestID, body string,
) (Message, error) {
	if r.sendErr != nil {
		return Message{}, r.sendErr
	}
	message := Message{
		ID: fmt.Sprintf("%d", len(r.sent)+1), SenderID: senderID,
		RecipientID: recipientID, Body: body, CreatedAt: time.Unix(1, 0).UTC(),
	}
	r.sent = append(r.sent, message)
	return message, nil
}

func (r *testRepository) ListPrivateMessages(
	_ context.Context,
	_, _ string,
	offset, limit uint32,
) ([]Message, error) {
	end := offset + limit
	if end > uint32(len(r.messages)) {
		end = uint32(len(r.messages))
	}
	if offset > uint32(len(r.messages)) {
		offset = uint32(len(r.messages))
	}
	return append([]Message(nil), r.messages[offset:end]...), nil
}

func (r *testRepository) HidePrivateMessage(_ context.Context, userID, messageID string) error {
	r.hidden = append(r.hidden, userID+":"+messageID)
	return nil
}

func (r *testRepository) ReportPrivateMessage(_ context.Context, userID, messageID, _ string) error {
	r.reports = append(r.reports, userID+":"+messageID)
	return nil
}

type testPublisher struct {
	users     []string
	messages  []Message
	roomUsers []string
}

func (p *testPublisher) PublishPrivateMessage(userID string, message Message) {
	p.users = append(p.users, userID)
	p.messages = append(p.messages, message)
}

func (p *testPublisher) PublishRoomMessage(userIDs []string, message Message) {
	p.roomUsers = append(p.roomUsers, userIDs...)
	p.messages = append(p.messages, message)
}

type testRoomAccess struct {
	members []string
	err     error
	calls   *int
}

func (r testRoomAccess) RoomMemberIDs(context.Context, string, string) ([]string, error) {
	if r.calls != nil {
		*r.calls++
	}
	return r.members, r.err
}

func TestSendPrivateMessageValidatesAndPublishesForBothParticipants(t *testing.T) {
	repository := &testRepository{}
	publisher := &testPublisher{}
	service, err := NewService(repository, publisher)
	if err != nil {
		t.Fatal(err)
	}

	message, err := service.SendPrivateMessage(context.Background(), "sender", "recipient", "request-1", "  hello  ")
	if err != nil {
		t.Fatalf("SendPrivateMessage() error = %v", err)
	}
	if message.Body != "hello" || len(repository.sent) != 1 {
		t.Fatalf("saved message = %+v, calls = %d", message, len(repository.sent))
	}
	if !reflect.DeepEqual(publisher.users, []string{"sender", "recipient"}) ||
		len(publisher.messages) != 2 || publisher.messages[0].ID != message.ID {
		t.Fatalf("published users = %v, messages = %+v", publisher.users, publisher.messages)
	}
}

func TestSendPrivateMessageRejectsInvalidInputBeforeRepository(t *testing.T) {
	repository := &testRepository{}
	service, err := NewService(repository, nil)
	if err != nil {
		t.Fatal(err)
	}
	tests := []struct {
		name      string
		sender    string
		recipient string
		requestID string
		body      string
	}{
		{name: "empty request ID", sender: "sender", recipient: "recipient", body: "hello"},
		{name: "same participant", sender: "same", recipient: "same", requestID: "req", body: "hello"},
		{name: "empty message", sender: "sender", recipient: "recipient", requestID: "req"},
		{name: "long message", sender: "sender", recipient: "recipient", requestID: "req", body: string(make([]byte, maxMessageRunes+1))},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			_, err := service.SendPrivateMessage(
				context.Background(), test.sender, test.recipient, test.requestID, test.body,
			)
			if !errors.Is(err, ErrInvalidInput) {
				t.Fatalf("SendPrivateMessage() error = %v, want ErrInvalidInput", err)
			}
		})
	}
	if len(repository.sent) != 0 {
		t.Fatalf("invalid requests reached repository: %+v", repository.sent)
	}
}

func TestSendPrivateMessageDoesNotPublishOnRepositoryError(t *testing.T) {
	repository := &testRepository{sendErr: ErrNotFriends}
	publisher := &testPublisher{}
	service, err := NewService(repository, publisher)
	if err != nil {
		t.Fatal(err)
	}
	_, err = service.SendPrivateMessage(context.Background(), "sender", "recipient", "req", "hello")
	if !errors.Is(err, ErrNotFriends) {
		t.Fatalf("SendPrivateMessage() error = %v, want ErrNotFriends", err)
	}
	if len(publisher.users) != 0 {
		t.Fatalf("published unauthorized message: %v", publisher.users)
	}
}

func TestListPrivateMessagesPaginates(t *testing.T) {
	repository := &testRepository{
		messages: []Message{{ID: "1"}, {ID: "2"}, {ID: "3"}},
	}
	service, err := NewService(repository, nil)
	if err != nil {
		t.Fatal(err)
	}
	page, err := service.ListPrivateMessages(context.Background(), "user", "peer", "", 2)
	if err != nil {
		t.Fatalf("ListPrivateMessages() error = %v", err)
	}
	if len(page.Messages) != 2 || page.NextPageToken != "2" {
		t.Fatalf("first page = %+v", page)
	}
	nextPage, err := service.ListPrivateMessages(context.Background(), "user", "peer", page.NextPageToken, 2)
	if err != nil {
		t.Fatalf("ListPrivateMessages(next) error = %v", err)
	}
	if len(nextPage.Messages) != 1 || nextPage.Messages[0].ID != "3" || nextPage.NextPageToken != "" {
		t.Fatalf("second page = %+v", nextPage)
	}
	if _, err := service.ListPrivateMessages(context.Background(), "user", "peer", "not-a-number", 2); !errors.Is(err, ErrInvalidInput) {
		t.Fatalf("invalid page token error = %v", err)
	}
}

func TestRoomMessagesOnlyPublishToCurrentRoomMembers(t *testing.T) {
	publisher := &testPublisher{}
	service, err := NewServiceWithRoomAccess(&testRepository{}, publisher, testRoomAccess{
		members: []string{"sender", "member"},
	})
	if err != nil {
		t.Fatal(err)
	}
	message, err := service.SendRoomMessage(context.Background(), "sender", "room", "request", " hello ")
	if err != nil {
		t.Fatalf("SendRoomMessage() error = %v", err)
	}
	if message.Body != "hello" || message.RoomID != "room" ||
		!reflect.DeepEqual(publisher.roomUsers, []string{"sender", "member"}) {
		t.Fatalf("message = %+v, recipients = %v", message, publisher.roomUsers)
	}
}

func TestRoomMessageRequiresCurrentMembership(t *testing.T) {
	publisher := &testPublisher{}
	service, err := NewServiceWithRoomAccess(&testRepository{}, publisher, testRoomAccess{
		err: ErrNotRoomMember,
	})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := service.SendRoomMessage(context.Background(), "sender", "room", "request", "hello"); !errors.Is(err, ErrNotRoomMember) {
		t.Fatalf("SendRoomMessage() error = %v, want ErrNotRoomMember", err)
	}
	if len(publisher.messages) != 0 {
		t.Fatalf("unauthorized message was published: %+v", publisher.messages)
	}
}

func TestRoomMessageRetriesAreIdempotentAndRejectConflictingBodies(t *testing.T) {
	publisher := &testPublisher{}
	calls := 0
	members := []string{"sender", "original-member"}
	service, err := NewServiceWithRoomAccess(&testRepository{}, publisher, testRoomAccess{
		members: members, calls: &calls,
	})
	if err != nil {
		t.Fatal(err)
	}

	first, err := service.SendRoomMessage(context.Background(), "sender", "room", "request", "hello")
	if err != nil {
		t.Fatalf("SendRoomMessage() error = %v", err)
	}
	members[1] = "later-member"
	retry, err := service.SendRoomMessage(context.Background(), "sender", "room", "request", " hello ")
	if err != nil || retry.ID != first.ID || retry.CreatedAt != first.CreatedAt {
		t.Fatalf("identical retry = %+v, %v; want original message %+v", retry, err, first)
	}
	if _, err := service.SendRoomMessage(context.Background(), "sender", "room", "request", "different"); !errors.Is(err, ErrRequestConflict) {
		t.Fatalf("conflicting retry error = %v, want ErrRequestConflict", err)
	}
	if calls != 1 || !reflect.DeepEqual(publisher.roomUsers, []string{"sender", "original-member"}) ||
		len(publisher.messages) != 1 {
		t.Fatalf("room access calls=%d recipients=%v messages=%+v", calls, publisher.roomUsers, publisher.messages)
	}
}

func TestPrivateMessageHideAndReportValidateAndDelegate(t *testing.T) {
	repository := &testRepository{}
	service, err := NewService(repository, nil)
	if err != nil {
		t.Fatal(err)
	}
	if err := service.HidePrivateMessage(context.Background(), "user", "42"); err != nil {
		t.Fatalf("HidePrivateMessage() error = %v", err)
	}
	if err := service.ReportPrivateMessage(context.Background(), "user", "42", "  abuse  "); err != nil {
		t.Fatalf("ReportPrivateMessage() error = %v", err)
	}
	if !reflect.DeepEqual(repository.hidden, []string{"user:42"}) ||
		!reflect.DeepEqual(repository.reports, []string{"user:42"}) {
		t.Fatalf("hide/report calls = %v / %v", repository.hidden, repository.reports)
	}
	for _, invalidID := range []string{"0", "-1", "18446744073709551616"} {
		if err := service.HidePrivateMessage(context.Background(), "user", invalidID); !errors.Is(err, ErrInvalidInput) {
			t.Errorf("HidePrivateMessage(%q) error = %v, want ErrInvalidInput", invalidID, err)
		}
	}
}
