package grpc

import (
	"context"
	"testing"

	"github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/lobby"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/player"
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

func TestRoomGameTableMutationsEnforcePermissionsVersionsAndDeduplicate(t *testing.T) {
	manager := room.NewManager()
	created, err := manager.CreateRoom(lobby.HallOrdinary, "owner", 0, room.Settings{
		Name: "table", AllowSpectators: true,
	})
	if err != nil {
		t.Fatal(err)
	}
	details, err := manager.JoinRoom(created.Room.ID, "owner", 0, "", created.Version)
	if err != nil {
		t.Fatal(err)
	}
	details, err = manager.JoinSpectator(created.Room.ID, "spectator", 0, "", 1, details.Version)
	if err != nil {
		t.Fatal(err)
	}
	server := &roomServer{
		manager: manager,
		profiles: lobbyProfiles{
			profile: player.Profile{Points: 0},
		},
		requests: make(map[roomRequestKey]roomMutationResult),
	}
	ownerContext := ctxWithUserID(context.Background(), "owner")
	spectatorContext := ctxWithUserID(context.Background(), "spectator")
	foreignContext := ctxWithUserID(context.Background(), "stranger")

	opened, err := server.SetHandVisibility(ownerContext, &huaiv1.SpectatorViewRequest{
		RoomId: created.Room.ID, ShowHand: true, ExpectedVersion: details.Version,
		RequestId: "11111111-1111-4111-8111-111111111111",
	})
	if err != nil || !opened.GetMembers()[0].GetShowHand() {
		t.Fatalf("SetHandVisibility() = %+v, %v", opened, err)
	}
	retry, err := server.SetHandVisibility(ownerContext, &huaiv1.SpectatorViewRequest{
		RoomId: created.Room.ID, ShowHand: true, ExpectedVersion: details.Version,
		RequestId: "11111111-1111-4111-8111-111111111111",
	})
	if err != nil || retry.GetVersion() != opened.GetVersion() {
		t.Fatalf("idempotent visibility retry = %+v, %v", retry, err)
	}
	if _, err := server.SetSpectatorView(ownerContext, &huaiv1.SpectatorViewRequest{
		RoomId: created.Room.ID, ViewSeat: 4, ExpectedVersion: opened.GetVersion(),
		RequestId: "11111111-1111-4111-8111-111111111111",
	}); status.Code(err) != codes.AlreadyExists {
		t.Fatalf("request ID reuse error = %v, want AlreadyExists", err)
	}

	viewed, err := server.SetSpectatorView(spectatorContext, &huaiv1.SpectatorViewRequest{
		RoomId: created.Room.ID, ViewSeat: 4, ExpectedVersion: opened.GetVersion(),
		RequestId: "22222222-2222-4222-8222-222222222222",
	})
	if err != nil {
		t.Fatal(err)
	}
	var spectator *huaiv1.RoomMember
	for _, member := range viewed.GetMembers() {
		if member.GetUserId() == "spectator" {
			spectator = member
			break
		}
	}
	if spectator == nil || spectator.GetViewSeat() != 4 || spectator.GetTeam() != 2 {
		t.Fatalf("spectator member = %+v; want view seat 4/team 2", spectator)
	}
	if _, err := server.SetHandVisibility(spectatorContext, &huaiv1.SpectatorViewRequest{
		RoomId: created.Room.ID, ShowHand: true, ExpectedVersion: viewed.GetVersion(),
		RequestId: "33333333-3333-4333-8333-333333333333",
	}); status.Code(err) != codes.PermissionDenied {
		t.Fatalf("spectator visibility error = %v, want PermissionDenied", err)
	}
	if _, err := server.SetSpectatorView(ownerContext, &huaiv1.SpectatorViewRequest{
		RoomId: created.Room.ID, ViewSeat: 2, ExpectedVersion: viewed.GetVersion(),
		RequestId: "44444444-4444-4444-8444-444444444444",
	}); status.Code(err) != codes.PermissionDenied {
		t.Fatalf("player spectator-view error = %v, want PermissionDenied", err)
	}
	if _, err := server.SetHandVisibility(ownerContext, &huaiv1.SpectatorViewRequest{
		RoomId: created.Room.ID, ShowHand: false, ExpectedVersion: details.Version,
		RequestId: "55555555-5555-4555-8555-555555555555",
	}); status.Code(err) != codes.Aborted {
		t.Fatalf("stale room version error = %v, want Aborted", err)
	}
	if _, err := server.GetRoom(foreignContext, &huaiv1.RoomRequest{RoomId: created.Room.ID}); status.Code(err) != codes.PermissionDenied {
		t.Fatalf("foreign GetRoom error = %v, want PermissionDenied", err)
	}

	current, err := manager.GetRoom(created.Room.ID, "owner")
	if err != nil {
		t.Fatal(err)
	}
	for _, userID := range []string{"player-2", "player-3", "player-4"} {
		current, err = manager.JoinRoom(created.Room.ID, userID, 0, "", current.Version)
		if err != nil {
			t.Fatal(err)
		}
	}
	_, err = server.StartGame(ownerContext, &huaiv1.RoomRequest{
		RoomId: created.Room.ID, ExpectedVersion: current.Version,
		RequestId: "66666666-6666-4666-8666-666666666666",
	})
	if status.Code(err) != codes.FailedPrecondition {
		t.Fatalf("StartGame error = %v, want explicit engine-unavailable FailedPrecondition", err)
	}
	summary, err := manager.GetSummary(created.Room.ID)
	if err != nil || summary.Status != room.StatusWaiting {
		t.Fatalf("failed StartGame changed room state: summary=%+v err=%v", summary, err)
	}
}
