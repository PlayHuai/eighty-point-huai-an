package coordinator

import "context"

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
}

type RecoveryState struct {
	GameState
	Events []GameEvent
}

type Repository interface {
	CommitGameUpdate(ctx context.Context, expectedVersion uint64, state GameState, event GameEvent) error
	LoadRecoveryState(ctx context.Context, sessionID string) (RecoveryState, error)
}
