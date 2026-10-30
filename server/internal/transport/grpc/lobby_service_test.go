package grpc

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/lobby"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/player"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
	grpcgo "google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type lobbyProfiles struct {
	profile    player.Profile
	public     map[string]player.PublicProfile
	err        error
	batchCalls *int
	batchIDs   *[]string
	findCalls  *int
}

func (p lobbyProfiles) FindProfile(context.Context, string) (player.Profile, error) {
	if p.findCalls != nil {
		*p.findCalls = *p.findCalls + 1
	}
	return p.profile, p.err
}

func (p lobbyProfiles) SaveProfile(context.Context, player.Profile) error { return nil }

func (p lobbyProfiles) GetPublicProfile(_ context.Context, userID string) (player.PublicProfile, error) {
	profile, ok := p.public[userID]
	if !ok {
		return player.PublicProfile{}, player.ErrProfileNotFound
	}
	return profile, nil
}

func (p lobbyProfiles) GetPublicProfiles(_ context.Context, userIDs []string) (map[string]player.PublicProfile, error) {
	if p.batchCalls != nil {
		*p.batchCalls = *p.batchCalls + 1
	}
	if p.batchIDs != nil {
		*p.batchIDs = append(*p.batchIDs, userIDs...)
	}
	profiles := make(map[string]player.PublicProfile, len(userIDs))
	for _, userID := range userIDs {
		if profile, exists := p.public[userID]; exists {
			profiles[userID] = profile
		}
	}
	return profiles, nil
}

func (p lobbyProfiles) UpdatePublicProfile(context.Context, string, string, string) (player.PublicProfile, error) {
	return player.PublicProfile{}, errors.New("not implemented")
}

func TestListHallsRequiresAuthenticationAndReturnsConfiguredHalls(t *testing.T) {
	server := &lobbyServer{rooms: room.NewManager(), profiles: lobbyProfiles{}}
	if _, err := server.ListHalls(context.Background(), &huaiv1.Empty{}); status.Code(err) != codes.Unauthenticated {
		t.Fatalf("unauthenticated ListHalls error = %v", err)
	}
	response, err := server.ListHalls(ctxWithUserID(context.Background(), "player"), &huaiv1.Empty{})
	if err != nil || len(response.GetHalls()) != len(lobby.Halls()) {
		t.Fatalf("ListHalls() = %+v, %v", response, err)
	}
	if response.GetHalls()[0].GetHallId() != lobby.HallOrdinary {
		t.Fatalf("first hall = %+v", response.GetHalls()[0])
	}
}

func TestListRoomsAppliesAdmissionAndPaginates(t *testing.T) {
	manager := room.NewManager()
	for _, ownerID := range []string{"owner-one", "owner-two"} {
		if _, err := manager.CreateRoom(lobby.HallOrdinary, ownerID, 500, room.Settings{Name: ownerID}); err != nil {
			t.Fatal(err)
		}
	}
	profiles := lobbyProfiles{
		profile: player.Profile{UserID: "viewer", Points: 500},
		public: map[string]player.PublicProfile{
			"owner-one": {UserID: "owner-one", Nickname: "One", CreatedAt: time.Unix(1, 0)},
			"owner-two": {UserID: "owner-two", Nickname: "Two", CreatedAt: time.Unix(2, 0)},
		},
	}
	server := &lobbyServer{rooms: manager, profiles: profiles}
	ctx := ctxWithUserID(context.Background(), "viewer")

	first, err := server.ListRooms(ctx, &huaiv1.ListRoomsRequest{
		HallId: lobby.HallOrdinary, Page: &huaiv1.PageRequest{PageSize: 1},
	})
	if err != nil || len(first.GetRooms()) != 1 || first.GetPage().GetNextPageToken() == "" {
		t.Fatalf("first ListRooms() = %+v, %v", first, err)
	}
	if _, err := manager.Close(
		first.GetRooms()[0].GetRoomId(),
		first.GetRooms()[0].GetOwner().GetUserId(),
		first.GetRooms()[0].GetVersion(),
	); err != nil {
		t.Fatalf("Close(first page room): %v", err)
	}
	second, err := server.ListRooms(ctx, &huaiv1.ListRoomsRequest{
		HallId: lobby.HallOrdinary,
		Page:   &huaiv1.PageRequest{PageSize: 1, PageToken: first.GetPage().GetNextPageToken()},
	})
	if err != nil || len(second.GetRooms()) != 1 || second.GetPage().GetNextPageToken() != "" ||
		first.GetRooms()[0].GetRoomId() == second.GetRooms()[0].GetRoomId() {
		t.Fatalf("second ListRooms() = %+v, %v", second, err)
	}
	if first.GetRooms()[0].GetOwner().GetNickname() == "" || second.GetRooms()[0].GetOwner().GetNickname() == "" {
		t.Fatalf("room owner profiles were not returned: first=%+v second=%+v", first, second)
	}

	server.profiles = lobbyProfiles{profile: player.Profile{UserID: "viewer", Points: 0}}
	if _, err := server.ListRooms(ctx, &huaiv1.ListRoomsRequest{HallId: lobby.HallAdvanced}); status.Code(err) != codes.PermissionDenied {
		t.Fatalf("under-ranked ListRooms error = %v", err)
	}
}

func TestListRoomsLoadsDistinctOwnerProfilesInOneBatch(t *testing.T) {
	manager := room.NewManager()
	for i := 0; i < 3; i++ {
		if _, err := manager.CreateRoom(lobby.HallOrdinary, "owner", 500, room.Settings{Name: "room"}); err != nil {
			t.Fatal(err)
		}
	}
	calls := 0
	var requestedIDs []string
	server := &lobbyServer{
		rooms: manager,
		profiles: lobbyProfiles{
			profile:    player.Profile{UserID: "viewer", Points: 500},
			public:     map[string]player.PublicProfile{"owner": {UserID: "owner", Nickname: "Owner"}},
			batchCalls: &calls,
			batchIDs:   &requestedIDs,
		},
	}
	response, err := server.ListRooms(ctxWithUserID(context.Background(), "viewer"), &huaiv1.ListRoomsRequest{
		HallId: lobby.HallOrdinary, Page: &huaiv1.PageRequest{PageSize: 10},
	})
	if err != nil || len(response.GetRooms()) != 3 {
		t.Fatalf("ListRooms() = %+v, %v", response, err)
	}
	if calls != 1 || len(requestedIDs) != 1 || requestedIDs[0] != "owner" {
		t.Fatalf("owner profile batch calls=%d IDs=%v, want one call for one distinct owner", calls, requestedIDs)
	}
}

func TestListRoomsRejectsPrivateHallAndInvalidPages(t *testing.T) {
	findCalls := 0
	server := &lobbyServer{
		rooms: room.NewManager(),
		profiles: lobbyProfiles{
			profile:   player.Profile{UserID: "viewer", Points: 50_000},
			findCalls: &findCalls,
		},
	}
	ctx := ctxWithUserID(context.Background(), "viewer")
	if _, err := server.ListRooms(ctx, &huaiv1.ListRoomsRequest{HallId: lobby.HallFriend}); status.Code(err) != codes.FailedPrecondition {
		t.Fatalf("friend hall ListRooms error = %v", err)
	}
	if _, err := server.ListRooms(ctx, &huaiv1.ListRoomsRequest{
		HallId: lobby.HallOrdinary, Page: &huaiv1.PageRequest{PageSize: 101},
	}); status.Code(err) != codes.InvalidArgument {
		t.Fatalf("oversized page ListRooms error = %v", err)
	}
	findCalls = 0
	if _, err := server.ListRooms(ctx, &huaiv1.ListRoomsRequest{
		HallId: lobby.HallOrdinary, Page: &huaiv1.PageRequest{PageToken: "invalid"},
	}); status.Code(err) != codes.InvalidArgument || findCalls != 0 {
		t.Fatalf("invalid cursor error=%v profile lookups=%d, want InvalidArgument without lookup", err, findCalls)
	}
}

func TestRoomManagementRPCsCreateJoinLeaveAndJoinByCode(t *testing.T) {
	server := &lobbyServer{
		rooms: room.NewManager(),
		profiles: lobbyProfiles{
			profile: player.Profile{Points: 500},
		},
	}
	ownerCtx := ctxWithUserID(context.Background(), "owner")
	created, err := server.CreateRoom(ownerCtx, &huaiv1.CreateRoomRequest{
		HallId:    lobby.HallOrdinary,
		Name:      "room",
		RequestId: "create-room",
	})
	if err != nil || created.GetVersion() != 1 || created.GetOwner().GetUserId() != "owner" {
		t.Fatalf("CreateRoom() = %+v, %v", created, err)
	}

	joined, err := server.JoinRoom(ownerCtx, &huaiv1.RoomRequest{
		RoomId: created.GetRoomId(), ExpectedVersion: created.GetVersion(),
	})
	if err != nil || joined.GetOccupiedSeats() != 1 || joined.GetVersion() != 2 {
		t.Fatalf("JoinRoom() = %+v, %v", joined, err)
	}
	if _, err := server.JoinRoom(ctxWithUserID(context.Background(), "stale"), &huaiv1.RoomRequest{
		RoomId: created.GetRoomId(), ExpectedVersion: created.GetVersion(),
	}); status.Code(err) != codes.Aborted {
		t.Fatalf("stale JoinRoom() error = %v, want Aborted", err)
	}

	joinedByCode, err := server.JoinByCode(
		ctxWithUserID(context.Background(), "guest"),
		&huaiv1.JoinByCodeRequest{RoomCode: created.GetRoomId()},
	)
	if err != nil || joinedByCode.GetOccupiedSeats() != 2 || joinedByCode.GetVersion() != 3 {
		t.Fatalf("JoinByCode() = %+v, %v", joinedByCode, err)
	}
	if _, err := server.LeaveRoom(ownerCtx, &huaiv1.RoomRequest{
		RoomId: created.GetRoomId(), RequestId: "leave-room",
		ExpectedVersion: joinedByCode.GetVersion(),
	}); err != nil {
		t.Fatalf("LeaveRoom() error = %v", err)
	}
	if _, err := server.LeaveRoom(ownerCtx, &huaiv1.RoomRequest{
		RoomId: created.GetRoomId(), RequestId: "leave-room",
		ExpectedVersion: joinedByCode.GetVersion(),
	}); err != nil {
		t.Fatalf("retry LeaveRoom() error = %v", err)
	}
	if _, err := server.LeaveRoom(ownerCtx, &huaiv1.RoomRequest{
		RoomId: "other-room", RequestId: "leave-room",
		ExpectedVersion: joinedByCode.GetVersion(),
	}); status.Code(err) != codes.AlreadyExists {
		t.Fatalf("conflicting LeaveRoom() error = %v", err)
	}
}

func TestCreateRoomIsIdempotentByUserAndRequestID(t *testing.T) {
	server := &lobbyServer{
		rooms:    room.NewManager(),
		profiles: lobbyProfiles{profile: player.Profile{Points: 500}},
	}
	ctx := ctxWithUserID(context.Background(), "owner")
	request := &huaiv1.CreateRoomRequest{
		HallId: lobby.HallOrdinary, Name: "room", Password: "secret", RequestId: "create-once",
	}
	first, err := server.CreateRoom(ctx, request)
	if err != nil {
		t.Fatalf("CreateRoom() error = %v", err)
	}
	retry, err := server.CreateRoom(ctx, request)
	if err != nil || retry.GetRoomId() != first.GetRoomId() {
		t.Fatalf("identical CreateRoom retry = %+v, %v; want room %q", retry, err, first.GetRoomId())
	}
	conflictingPassword := *request
	conflictingPassword.Password = "different"
	if _, err := server.CreateRoom(ctx, &conflictingPassword); status.Code(err) != codes.AlreadyExists {
		t.Fatalf("conflicting CreateRoom password error = %v", err)
	}
	conflicting := *request
	conflicting.Name = "different room"
	if _, err := server.CreateRoom(ctx, &conflicting); status.Code(err) != codes.AlreadyExists {
		t.Fatalf("conflicting CreateRoom retry error = %v", err)
	}
	if _, err := server.CreateRoom(ctx, &huaiv1.CreateRoomRequest{
		HallId: lobby.HallOrdinary, Name: "missing request ID",
	}); status.Code(err) != codes.InvalidArgument {
		t.Fatalf("missing request ID error = %v", err)
	}
}

func TestRegisterLobbyServiceRequiresDependencies(t *testing.T) {
	if err := RegisterLobbyService(nil, room.NewManager(), lobbyProfiles{}); err == nil {
		t.Fatal("RegisterLobbyService accepted a nil registrar")
	}
	if err := RegisterLobbyService(grpcgo.NewServer(), nil, lobbyProfiles{}); err == nil {
		t.Fatal("RegisterLobbyService accepted a nil room manager")
	}
	if err := RegisterLobbyService(grpcgo.NewServer(), room.NewManager(), nil); err == nil {
		t.Fatal("RegisterLobbyService accepted nil profiles")
	}
}
