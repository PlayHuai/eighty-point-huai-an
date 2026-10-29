package grpc

import (
	"context"
	"testing"

	"github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/lobby"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func TestJoinInvitedFriendRoomBypassesRankedAdmission(t *testing.T) {
	manager := room.NewManager()
	created, err := manager.CreateRoom(lobby.HallFriend, "owner", 0, room.Settings{Name: "friends"})
	if err != nil {
		t.Fatal(err)
	}
	_, err = manager.JoinRoom(created.Room.ID, "owner", 0, "", created.Version)
	if err != nil {
		t.Fatal(err)
	}
	if err := manager.InviteFriend(created.Room.ID, "owner", "friend"); err != nil {
		t.Fatal(err)
	}
	server := &roomServer{manager: manager}
	request := &huaiv1.JoinInvitedRoomRequest{RoomId: created.Room.ID, RequestId: "request-friend"}

	if _, err := server.JoinInvitedRoom(context.Background(), request); status.Code(err) != codes.Unauthenticated {
		t.Fatalf("unauthenticated JoinInvitedRoom error = %v, want Unauthenticated", err)
	}
	if _, err := server.JoinInvitedRoom(ctxWithUserID(context.Background(), "stranger"), request); status.Code(err) != codes.PermissionDenied {
		t.Fatalf("non-invitee JoinInvitedRoom error = %v, want PermissionDenied", err)
	}
	details, err := server.JoinInvitedRoom(ctxWithUserID(context.Background(), "friend"), request)
	if err != nil {
		t.Fatal(err)
	}
	if details.GetRoom().GetHallId() != lobby.HallFriend || details.GetRoom().GetOccupiedSeats() != 2 ||
		details.GetMembers()[1].GetUserId() != "friend" {
		t.Fatalf("JoinInvitedRoom response = %+v", details)
	}
	retry, err := server.JoinInvitedRoom(ctxWithUserID(context.Background(), "friend"), request)
	if err != nil || retry.GetVersion() != details.GetVersion() {
		t.Fatalf("idempotent invitation retry = %+v, %v", retry, err)
	}
}
