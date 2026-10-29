package chat

import (
	"context"
	"time"
)

type Message struct {
	ID          string
	SenderID    string
	RecipientID string
	Body        string
	CreatedAt   time.Time
}

type Repository interface {
	SendPrivateMessage(ctx context.Context, senderID, recipientID, requestID, body string) (Message, error)
	ListPrivateMessages(ctx context.Context, userID, peerID string, offset, limit uint32) ([]Message, error)
}

type Publisher interface {
	PublishPrivateMessage(userID string, message Message)
}
