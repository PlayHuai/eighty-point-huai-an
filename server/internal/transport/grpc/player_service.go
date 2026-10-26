package grpc

import (
	"context"
	"errors"

	"github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/player"
	grpcgo "google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type playerServer struct {
	huaiv1.UnimplementedPlayerServiceServer
	service *player.PublicProfileService
}

func RegisterPlayerService(server grpcgo.ServiceRegistrar, service *player.PublicProfileService) error {
	if server == nil || service == nil {
		return errors.New("gRPC registrar and player service are required")
	}
	huaiv1.RegisterPlayerServiceServer(server, &playerServer{service: service})
	return nil
}

func (s *playerServer) GetProfile(ctx context.Context, request *huaiv1.GetProfileRequest) (*huaiv1.UserProfile, error) {
	if _, ok := UserIDFromContext(ctx); !ok {
		return nil, status.Error(codes.Unauthenticated, "authentication required")
	}
	profile, err := s.service.Get(ctx, request.GetUserId())
	if err != nil {
		return nil, playerProfileError(err)
	}
	return publicUserProfile(profile), nil
}

func (s *playerServer) UpdateProfile(ctx context.Context, request *huaiv1.UpdateProfileRequest) (*huaiv1.UserProfile, error) {
	userID, ok := UserIDFromContext(ctx)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "authentication required")
	}
	profile, err := s.service.Update(ctx, userID, request.GetNickname(), request.GetAvatarUrl())
	if err != nil {
		return nil, playerProfileError(err)
	}
	return publicUserProfile(profile), nil
}

func publicUserProfile(profile player.PublicProfile) *huaiv1.UserProfile {
	var createdAt *timestamppb.Timestamp
	if !profile.CreatedAt.IsZero() {
		createdAt = timestamppb.New(profile.CreatedAt)
	}
	return &huaiv1.UserProfile{
		UserId: profile.UserID, Nickname: profile.Nickname,
		AvatarUrl: profile.AvatarURL, CreatedAt: createdAt,
	}
}

func playerProfileError(err error) error {
	switch {
	case errors.Is(err, player.ErrInvalidProfile):
		return status.Error(codes.InvalidArgument, "invalid profile")
	case errors.Is(err, player.ErrProfileNotFound):
		return status.Error(codes.NotFound, "player profile not found")
	default:
		return status.Error(codes.Internal, "player profile operation failed")
	}
}

var _ huaiv1.PlayerServiceServer = (*playerServer)(nil)
