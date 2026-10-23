package coordinator

import (
	"context"
	"errors"
)

var ErrEventNotFound = errors.New("game event not found")

type GameState struct {
	SessionID string
	RoomID    string
	Status    string
	Version   uint64
	Snapshot  []byte
}

type GameEvent struct {
	SessionID string
	HandID    string
	Type      string
	Payload   []byte
	ActorID   string
	RequestID string
	Seq       uint64
}

type RecoveryState struct {
	GameState
	Events []GameEvent
}

type Repository interface {
	CommitGameUpdate(ctx context.Context, expectedVersion uint64, state GameState, event GameEvent) error
	LoadRecoveryState(ctx context.Context, sessionID string) (RecoveryState, error)
	FindGameEventByRequest(ctx context.Context, sessionID, requestID string) (GameEvent, error)
	LoadGameEventsAfter(ctx context.Context, sessionID string, seq uint64, limit uint32) ([]GameEvent, error)
}
