package websocket

import (
	"errors"
	"strconv"
	"sync"
	"time"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/chat"
)

const subscriberBufferSize = 32

type Event struct {
	Type         string    `json:"type"`
	Sequence     uint64    `json:"seq"`
	MessageID    string    `json:"message_id"`
	SenderUserID string    `json:"sender_user_id"`
	PeerUserID   string    `json:"peer_user_id"`
	CreatedAt    time.Time `json:"created_at"`
}

type Subscription struct {
	hub    *Hub
	userID string
	events chan Event
	once   sync.Once
}

type Hub struct {
	mu          sync.Mutex
	subscribers map[string]map[*Subscription]struct{}
}

func NewHub() *Hub {
	return &Hub{subscribers: make(map[string]map[*Subscription]struct{})}
}

func (h *Hub) Subscribe(userID string) (*Subscription, error) {
	if userID == "" {
		return nil, errors.New("user ID is required")
	}
	subscription := &Subscription{
		hub: h, userID: userID, events: make(chan Event, subscriberBufferSize),
	}
	h.mu.Lock()
	if h.subscribers[userID] == nil {
		h.subscribers[userID] = make(map[*Subscription]struct{})
	}
	h.subscribers[userID][subscription] = struct{}{}
	h.mu.Unlock()
	return subscription, nil
}

func (s *Subscription) Events() <-chan Event {
	return s.events
}

func (s *Subscription) Close() {
	s.once.Do(func() {
		s.hub.mu.Lock()
		delete(s.hub.subscribers[s.userID], s)
		if len(s.hub.subscribers[s.userID]) == 0 {
			delete(s.hub.subscribers, s.userID)
		}
		close(s.events)
		s.hub.mu.Unlock()
	})
}

func (h *Hub) PublishPrivateMessage(userID string, message chat.Message) {
	peerID := ""
	switch userID {
	case message.SenderID:
		peerID = message.RecipientID
	case message.RecipientID:
		peerID = message.SenderID
	default:
		return
	}
	sequence, _ := strconv.ParseUint(message.ID, 10, 64)
	event := Event{
		Type: "PRIVATE_MESSAGE_CREATED", Sequence: sequence, MessageID: message.ID,
		SenderUserID: message.SenderID, PeerUserID: peerID, CreatedAt: message.CreatedAt,
	}
	h.mu.Lock()
	defer h.mu.Unlock()
	for subscription := range h.subscribers[userID] {
		select {
		case subscription.events <- event:
		default:
		}
	}
}
