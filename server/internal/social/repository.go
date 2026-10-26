package social

import (
	"context"
	"errors"
	"time"
)

var (
	ErrInvalidInput         = errors.New("invalid social request")
	ErrPlayerNotFound       = errors.New("player not found")
	ErrFriendRequestExists  = errors.New("friend request already exists")
	ErrFriendRequestMissing = errors.New("friend request not found")
	ErrAlreadyFriends       = errors.New("players are already friends")
	ErrNotFriends           = errors.New("players are not friends")
	ErrRoomUnavailable      = errors.New("room is unavailable")
)

type Player struct {
	UserID    string
	Nickname  string
	AvatarURL string
	CreatedAt time.Time
}

type Friend struct {
	Player
	FriendsSince time.Time
}

type PendingFriendRequest struct {
	Player
	RequestedAt time.Time
}

type RoomInvitation struct {
	Inviter   Player
	RoomID    string
	InvitedAt time.Time
}

type Repository interface {
	SearchPlayers(ctx context.Context, query, excludedUserID string, offset, limit uint32) ([]Player, error)
	SendFriendRequest(ctx context.Context, userID, targetUserID string) error
	RespondFriendRequest(ctx context.Context, requesterID, recipientID string, accept bool) error
	ListFriendRequests(ctx context.Context, userID string, offset, limit uint32) ([]PendingFriendRequest, error)
	ListFriends(ctx context.Context, userID string, offset, limit uint32) ([]Friend, error)
	RemoveFriend(ctx context.Context, userID, friendID string) error
	CreateRoomInvite(ctx context.Context, userID, roomID, friendID string) error
	ListRoomInvitations(ctx context.Context, userID string, offset, limit uint32) ([]RoomInvitation, error)
}
