package grpc

import (
	"context"
	"errors"

	"github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/social"
	grpcgo "google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type friendServer struct {
	huaiv1.UnimplementedFriendServiceServer
	service  *social.Service
	presence friendPresence
}

type friendPresence interface {
	IsOnline(userID string) bool
	PublishUserUpdate(userIDs []string, userID string, payload []byte)
}

func RegisterFriendService(
	server grpcgo.ServiceRegistrar,
	service *social.Service,
	presenceProviders ...friendPresence,
) error {
	if server == nil || service == nil {
		return errors.New("gRPC registrar and friend service are required")
	}
	if len(presenceProviders) > 1 {
		return errors.New("only one presence publisher is allowed")
	}
	handler := &friendServer{service: service}
	if len(presenceProviders) == 1 {
		handler.presence = presenceProviders[0]
	}
	huaiv1.RegisterFriendServiceServer(server, handler)
	return nil
}

func (s *friendServer) SearchPlayers(ctx context.Context, request *huaiv1.SearchPlayersRequest) (*huaiv1.SearchPlayersResponse, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	page, err := s.service.SearchPlayers(ctx, userID, request.GetQuery(), request.GetPage().GetPageToken(), request.GetPage().GetPageSize())
	if err != nil {
		return nil, socialError(err)
	}
	response := &huaiv1.SearchPlayersResponse{Page: &huaiv1.PageInfo{NextPageToken: page.NextPageToken}}
	for _, player := range page.Items {
		response.Players = append(response.Players, &huaiv1.UserProfile{
			UserId: player.UserID, Nickname: player.Nickname, AvatarUrl: player.AvatarURL,
			CreatedAt: timestamppb.New(player.CreatedAt),
		})
	}
	return response, nil
}

func (s *friendServer) SendRequest(ctx context.Context, request *huaiv1.FriendRequest) (*huaiv1.Empty, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := s.service.SendFriendRequest(ctx, userID, request.GetTargetUserId()); err != nil {
		return nil, socialError(err)
	}
	s.publishFriendChange(userID, request.GetTargetUserId(), "friend_request")
	return &huaiv1.Empty{}, nil
}

func (s *friendServer) RespondRequest(ctx context.Context, request *huaiv1.RespondFriendRequest) (*huaiv1.Empty, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := s.service.RespondFriendRequest(ctx, userID, request.GetRequesterUserId(), request.GetAccept()); err != nil {
		return nil, socialError(err)
	}
	if request.GetAccept() {
		s.updatePresenceFriendship(userID, request.GetRequesterUserId(), true)
	}
	s.publishFriendChange(userID, request.GetRequesterUserId(), "friend_request")
	return &huaiv1.Empty{}, nil
}

func (s *friendServer) ListFriends(ctx context.Context, request *huaiv1.PageRequest) (*huaiv1.ListFriendsResponse, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	page, err := s.service.ListFriends(ctx, userID, request.GetPageToken(), request.GetPageSize())
	if err != nil {
		return nil, socialError(err)
	}
	response := &huaiv1.ListFriendsResponse{Page: &huaiv1.PageInfo{NextPageToken: page.NextPageToken}}
	for _, friend := range page.Items {
		online := s.presence != nil && s.presence.IsOnline(friend.UserID)
		response.Friends = append(response.Friends, &huaiv1.Friend{
			Profile: &huaiv1.UserProfile{
				UserId: friend.UserID, Nickname: friend.Nickname, AvatarUrl: friend.AvatarURL,
				CreatedAt: timestamppb.New(friend.CreatedAt),
			},
			FriendsSince: timestamppb.New(friend.FriendsSince),
			Online:       online,
		})
	}
	return response, nil
}

func (s *friendServer) ListFriendRequests(ctx context.Context, request *huaiv1.PageRequest) (*huaiv1.ListFriendRequestsResponse, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	page, err := s.service.ListFriendRequests(ctx, userID, request.GetPageToken(), request.GetPageSize())
	if err != nil {
		return nil, socialError(err)
	}
	response := &huaiv1.ListFriendRequestsResponse{Page: &huaiv1.PageInfo{NextPageToken: page.NextPageToken}}
	for _, item := range page.Items {
		response.Requests = append(response.Requests, &huaiv1.PendingFriendRequest{
			Requester: &huaiv1.UserProfile{
				UserId: item.UserID, Nickname: item.Nickname, AvatarUrl: item.AvatarURL,
				CreatedAt: timestamppb.New(item.CreatedAt),
			},
			RequestedAt: timestamppb.New(item.RequestedAt),
		})
	}
	return response, nil
}

func (s *friendServer) RemoveFriend(ctx context.Context, request *huaiv1.FriendRequest) (*huaiv1.Empty, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := s.service.RemoveFriend(ctx, userID, request.GetTargetUserId()); err != nil {
		return nil, socialError(err)
	}
	s.updatePresenceFriendship(userID, request.GetTargetUserId(), false)
	s.publishFriendChange(userID, request.GetTargetUserId(), "friend_list")
	return &huaiv1.Empty{}, nil
}

func (s *friendServer) SendRoomInvite(ctx context.Context, request *huaiv1.SendRoomInviteRequest) (*huaiv1.Empty, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := s.service.SendRoomInvite(ctx, userID, request.GetRoomId(), request.GetFriendId()); err != nil {
		return nil, socialError(err)
	}
	s.publishFriendChange(userID, request.GetFriendId(), "room_invite")
	return &huaiv1.Empty{}, nil
}

func (s *friendServer) ListRoomInvitations(ctx context.Context, request *huaiv1.PageRequest) (*huaiv1.ListRoomInvitationsResponse, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	page, err := s.service.ListRoomInvitations(ctx, userID, request.GetPageToken(), request.GetPageSize())
	if err != nil {
		return nil, socialError(err)
	}
	response := &huaiv1.ListRoomInvitationsResponse{Page: &huaiv1.PageInfo{NextPageToken: page.NextPageToken}}
	for _, invitation := range page.Items {
		response.Invitations = append(response.Invitations, &huaiv1.RoomInvitation{
			Inviter: &huaiv1.UserProfile{
				UserId: invitation.Inviter.UserID, Nickname: invitation.Inviter.Nickname,
				AvatarUrl: invitation.Inviter.AvatarURL, CreatedAt: timestamppb.New(invitation.Inviter.CreatedAt),
			},
			RoomId: invitation.RoomID, InvitedAt: timestamppb.New(invitation.InvitedAt),
		})
	}
	return response, nil
}

func authenticatedUserID(ctx context.Context) (string, error) {
	userID, ok := UserIDFromContext(ctx)
	if !ok {
		return "", status.Error(codes.Unauthenticated, "authentication required")
	}
	return userID, nil
}

func (s *friendServer) publishFriendChange(firstUserID, secondUserID, kind string) {
	if s.presence == nil {
		return
	}
	s.presence.PublishUserUpdate(
		[]string{firstUserID, secondUserID},
		secondUserID,
		[]byte(`{"kind":"`+kind+`"}`),
	)
}

func (s *friendServer) updatePresenceFriendship(firstUserID, secondUserID string, friends bool) {
	if presence, ok := s.presence.(interface {
		SetFriendship(string, string, bool)
	}); ok {
		presence.SetFriendship(firstUserID, secondUserID, friends)
	}
}

func socialError(err error) error {
	switch {
	case errors.Is(err, social.ErrInvalidInput):
		return status.Error(codes.InvalidArgument, "invalid social request")
	case errors.Is(err, social.ErrPlayerNotFound), errors.Is(err, social.ErrFriendRequestMissing):
		return status.Error(codes.NotFound, "player or friend request not found")
	case errors.Is(err, social.ErrFriendRequestExists), errors.Is(err, social.ErrAlreadyFriends):
		return status.Error(codes.AlreadyExists, "friend request or relationship already exists")
	case errors.Is(err, social.ErrNotFriends):
		return status.Error(codes.FailedPrecondition, "players are not friends")
	case errors.Is(err, social.ErrRoomUnavailable):
		return status.Error(codes.FailedPrecondition, "room invitation is not allowed")
	default:
		return status.Error(codes.Internal, "social operation failed")
	}
}

var _ huaiv1.FriendServiceServer = (*friendServer)(nil)
