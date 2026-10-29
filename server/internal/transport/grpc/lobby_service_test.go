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
