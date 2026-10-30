package websocket

import (
	"encoding/json"
	"errors"
	"strconv"
	"sync"
	"sync/atomic"
	"time"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/chat"
)

const subscriberBufferSize = 32

type Event struct {
	Type         string          `json:"type"`
	Sequence     uint64          `json:"seq"`
	MessageID    string          `json:"message_id"`
	SenderUserID string          `json:"sender_user_id"`
	PeerUserID   string          `json:"peer_user_id"`
	RoomID       string          `json:"room_id,omitempty"`
	Body         string          `json:"body,omitempty"`
	CreatedAt    time.Time       `json:"created_at"`
	EntityID     string          `json:"entity_id,omitempty"`
	Version      uint64          `json:"version,omitempty"`
	Payload      json.RawMessage `json:"payload,omitempty"`
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
	sequence    atomic.Uint64
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
	event := Event{
		Type: "PRIVATE_MESSAGE_CREATED", MessageID: message.ID,
		SenderUserID: message.SenderID, PeerUserID: peerID, Body: message.Body,
		CreatedAt: message.CreatedAt,
	}
	h.publishUsers([]string{userID}, event)
}

func (h *Hub) PublishRoomMessage(userIDs []string, message chat.Message) {
	event := Event{
		Type: "ROOM_MESSAGE_CREATED", MessageID: message.ID, SenderUserID: message.SenderID,
		RoomID: message.RoomID, Body: message.Body,
		CreatedAt: message.CreatedAt,
	}
	h.publishUsers(userIDs, event)
}

func (h *Hub) PublishLobbyUpdate(entityID string, version uint64, payload json.RawMessage) {
	h.mu.Lock()
	userIDs := make([]string, 0, len(h.subscribers))
	for userID := range h.subscribers {
		userIDs = append(userIDs, userID)
	}
	h.mu.Unlock()
	h.publishUsers(userIDs, Event{
		Type: "LOBBY_STATE_CHANGED", EntityID: entityID, Version: version, Payload: payload,
	})
}

func (h *Hub) PublishRoomUpdate(userIDs []string, roomID string, version uint64, payload json.RawMessage) {
	h.publishUsers(userIDs, Event{
		Type: "ROOM_STATE_CHANGED", RoomID: roomID, Version: version, Payload: payload,
	})
}

func (h *Hub) PublishUserUpdate(userIDs []string, userID string, payload json.RawMessage) {
	h.publishUsers(userIDs, Event{
		Type: "FRIEND_STATE_CHANGED", EntityID: userID, Payload: payload,
	})
}

func (h *Hub) publishUsers(userIDs []string, event Event) {
	event.Sequence = h.sequence.Add(1)
	if event.Type == "ROOM_MESSAGE_CREATED" && event.MessageID == "" {
		event.MessageID = strconv.FormatUint(event.Sequence, 10)
	}
	h.mu.Lock()
	defer h.mu.Unlock()
	seen := make(map[string]struct{}, len(userIDs))
	for _, userID := range userIDs {
		if _, ok := seen[userID]; ok {
			continue
		}
		seen[userID] = struct{}{}
		for subscription := range h.subscribers[userID] {
			select {
			case subscription.events <- event:
			default:
			}
		}
	}
}
