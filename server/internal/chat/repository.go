package chat

import (
	"context"
	"time"
)

type Message struct {
	ID          string
	RoomID      string
	SenderID    string
	RecipientID string
	Body        string
	CreatedAt   time.Time
}

type Repository interface {
	SendPrivateMessage(ctx context.Context, senderID, recipientID, requestID, body string) (Message, error)
	ListPrivateMessages(ctx context.Context, userID, peerID string, offset, limit uint32) ([]Message, error)
	HidePrivateMessage(ctx context.Context, userID, messageID string) error
	ReportPrivateMessage(ctx context.Context, userID, messageID, reason string) error
}

type Publisher interface {
	PublishPrivateMessage(userID string, message Message)
	PublishRoomMessage(userIDs []string, message Message)
}

type RoomAccess interface {
	RoomMemberIDs(ctx context.Context, roomID, userID string) ([]string, error)
}
