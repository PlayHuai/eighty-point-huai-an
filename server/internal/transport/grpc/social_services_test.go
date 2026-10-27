package grpc

import (
	"context"
	"testing"

	"github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/player"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/social"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type profileRepositoryStub struct {
	updatedUserID string
	nickname      string
	avatarURL     string
}

func (*profileRepositoryStub) GetPublicProfile(context.Context, string) (player.PublicProfile, error) {
	return player.PublicProfile{}, nil
}

func (r *profileRepositoryStub) UpdatePublicProfile(_ context.Context, userID, nickname, avatarURL string) (player.PublicProfile, error) {
	r.updatedUserID, r.nickname, r.avatarURL = userID, nickname, avatarURL
	return player.PublicProfile{UserID: userID, Nickname: nickname, AvatarURL: avatarURL}, nil
}

type socialRepositoryStub struct {
	senderID    string
	targetID    string
	listUserID  string
	requests    []social.PendingFriendRequest
	invitations []social.RoomInvitation
	err         error
}

func (*socialRepositoryStub) SearchPlayers(context.Context, string, string, uint32, uint32) ([]social.Player, error) {
	return nil, nil
}

func (r *socialRepositoryStub) SendFriendRequest(_ context.Context, senderID, targetID string) error {
	r.senderID, r.targetID = senderID, targetID
	return r.err
}

func (*socialRepositoryStub) RespondFriendRequest(context.Context, string, string, bool) error {
	return nil
}

func (r *socialRepositoryStub) ListFriendRequests(_ context.Context, userID string, _, _ uint32) ([]social.PendingFriendRequest, error) {
	r.listUserID = userID
	return r.requests, r.err
}

func (*socialRepositoryStub) ListFriends(context.Context, string, uint32, uint32) ([]social.Friend, error) {
	return nil, nil
}

func (*socialRepositoryStub) RemoveFriend(context.Context, string, string) error {
	return nil
}

func (*socialRepositoryStub) CreateRoomInvite(context.Context, string, string, string) error {
	return nil
}

func (r *socialRepositoryStub) ListRoomInvitations(_ context.Context, userID string, _, _ uint32) ([]social.RoomInvitation, error) {
	r.listUserID = userID
	return r.invitations, r.err
}

func TestPlayerAndFriendRPCsUseAuthenticatedIdentity(t *testing.T) {
	profiles := &profileRepositoryStub{}
	profileService, err := player.NewPublicProfileService(profiles)
	if err != nil {
		t.Fatal(err)
	}
	socialRepo := &socialRepositoryStub{}
	socialService, err := social.NewService(socialRepo)
	if err != nil {
		t.Fatal(err)
	}
	playerRPC := &playerServer{service: profileService}
	friendRPC := &friendServer{service: socialService}
	ctx := ctxWithUserID(context.Background(), "authenticated-user")

	profile, err := playerRPC.UpdateProfile(ctx, &huaiv1.UpdateProfileRequest{
		Nickname: "New name", AvatarUrl: "https://example.test/avatar.png",
	})
	if err != nil || profile.GetUserId() != "authenticated-user" ||
		profiles.updatedUserID != "authenticated-user" || profiles.nickname != "New name" {
		t.Fatalf("UpdateProfile() = %+v, %v; repository = %+v", profile, err, profiles)
	}

	if _, err := friendRPC.SendRequest(ctx, &huaiv1.FriendRequest{TargetUserId: "friend"}); err != nil ||
		socialRepo.senderID != "authenticated-user" || socialRepo.targetID != "friend" {
		t.Fatalf("SendRequest() error = %v; repository = %+v", err, socialRepo)
	}
	socialRepo.requests = []social.PendingFriendRequest{{Player: social.Player{UserID: "requester"}}}
	requests, err := friendRPC.ListFriendRequests(ctx, &huaiv1.PageRequest{})
	if err != nil || socialRepo.listUserID != "authenticated-user" || requests.GetRequests()[0].GetRequester().GetUserId() != "requester" {
		t.Fatalf("ListFriendRequests() = %+v, %v; repository = %+v", requests, err, socialRepo)
	}
	socialRepo.invitations = []social.RoomInvitation{{RoomID: "room", Inviter: social.Player{UserID: "inviter"}}}
	invitations, err := friendRPC.ListRoomInvitations(ctx, &huaiv1.PageRequest{})
	if err != nil || socialRepo.listUserID != "authenticated-user" ||
		invitations.GetInvitations()[0].GetRoomId() != "room" ||
		invitations.GetInvitations()[0].GetInviter().GetUserId() != "inviter" {
		t.Fatalf("ListRoomInvitations() = %+v, %v; repository = %+v", invitations, err, socialRepo)
	}
}

func TestPlayerAndFriendRPCsRejectMissingIdentity(t *testing.T) {
	profileRepository := &profileRepositoryStub{}
	profileService, err := player.NewPublicProfileService(profileRepository)
	if err != nil {
		t.Fatal(err)
	}
	socialService, err := social.NewService(&socialRepositoryStub{})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := (&playerServer{service: profileService}).UpdateProfile(
		context.Background(), &huaiv1.UpdateProfileRequest{Nickname: "Alice"}); status.Code(err) != codes.Unauthenticated {
		t.Fatalf("unauthenticated UpdateProfile error = %v", err)
	}
	if _, err := (&friendServer{service: socialService}).SendRequest(
		context.Background(), &huaiv1.FriendRequest{TargetUserId: "friend"}); status.Code(err) != codes.Unauthenticated {
		t.Fatalf("unauthenticated SendRequest error = %v", err)
	}
	if _, err := (&friendServer{service: socialService}).ListFriendRequests(
		context.Background(), &huaiv1.PageRequest{}); status.Code(err) != codes.Unauthenticated {
		t.Fatalf("unauthenticated ListFriendRequests error = %v", err)
	}
	if _, err := (&friendServer{service: socialService}).ListRoomInvitations(
		context.Background(), &huaiv1.PageRequest{}); status.Code(err) != codes.Unauthenticated {
		t.Fatalf("unauthenticated ListRoomInvitations error = %v", err)
	}
}

func TestEveryFriendRPCRejectsMissingIdentity(t *testing.T) {
	service, err := social.NewService(&socialRepositoryStub{})
	if err != nil {
		t.Fatal(err)
	}
	server := &friendServer{service: service}
	tests := []struct {
		name string
		call func(context.Context) error
	}{
		{"SearchPlayers", func(ctx context.Context) error {
			_, err := server.SearchPlayers(ctx, &huaiv1.SearchPlayersRequest{Query: "Alice"})
			return err
		}},
		{"SendRequest", func(ctx context.Context) error {
			_, err := server.SendRequest(ctx, &huaiv1.FriendRequest{TargetUserId: "friend"})
			return err
		}},
		{"RespondRequest", func(ctx context.Context) error {
			_, err := server.RespondRequest(ctx, &huaiv1.RespondFriendRequest{RequesterUserId: "friend"})
			return err
		}},
		{"ListFriends", func(ctx context.Context) error {
			_, err := server.ListFriends(ctx, &huaiv1.PageRequest{})
			return err
		}},
		{"ListFriendRequests", func(ctx context.Context) error {
			_, err := server.ListFriendRequests(ctx, &huaiv1.PageRequest{})
			return err
		}},
		{"RemoveFriend", func(ctx context.Context) error {
			_, err := server.RemoveFriend(ctx, &huaiv1.FriendRequest{TargetUserId: "friend"})
			return err
		}},
		{"SendRoomInvite", func(ctx context.Context) error {
			_, err := server.SendRoomInvite(ctx, &huaiv1.SendRoomInviteRequest{RoomId: "room", FriendId: "friend"})
			return err
		}},
		{"ListRoomInvitations", func(ctx context.Context) error {
			_, err := server.ListRoomInvitations(ctx, &huaiv1.PageRequest{})
			return err
		}},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if err := test.call(context.Background()); status.Code(err) != codes.Unauthenticated {
				t.Fatalf("RPC error = %v, want Unauthenticated", err)
			}
		})
	}
}

func TestFriendRPCMapsDomainErrors(t *testing.T) {
	repository := &socialRepositoryStub{err: social.ErrAlreadyFriends}
	service, err := social.NewService(repository)
	if err != nil {
		t.Fatal(err)
	}
	_, err = (&friendServer{service: service}).SendRequest(
		ctxWithUserID(context.Background(), "caller"),
		&huaiv1.FriendRequest{TargetUserId: "friend"},
	)
	if status.Code(err) != codes.AlreadyExists {
		t.Fatalf("SendRequest error = %v, want AlreadyExists", err)
	}
}
