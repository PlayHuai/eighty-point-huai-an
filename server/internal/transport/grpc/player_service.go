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

func (s *playerServer) GetStatistics(ctx context.Context, _ *huaiv1.Empty) (*huaiv1.PlayerStatistics, error) {
	userID, ok := UserIDFromContext(ctx)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "authentication required")
	}
	return s.statistics(ctx, userID, userID)
}

func (s *playerServer) GetFriendStatistics(ctx context.Context, request *huaiv1.GetFriendStatisticsRequest) (*huaiv1.PlayerStatistics, error) {
	userID, ok := UserIDFromContext(ctx)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "authentication required")
	}
	return s.statistics(ctx, userID, request.GetUserId())
}

func (s *playerServer) statistics(ctx context.Context, viewerID, targetID string) (*huaiv1.PlayerStatistics, error) {
	statistics, err := s.service.GetStatistics(ctx, viewerID, targetID)
	if err != nil {
		return nil, playerReadError(err)
	}
	return &huaiv1.PlayerStatistics{
		TotalGames: statistics.TotalGames,
		Wins:       statistics.Wins,
		Losses:     statistics.Losses,
		Points:     statistics.Points,
		Rank:       statistics.Rank,
	}, nil
}

func (s *playerServer) ListRecentResults(ctx context.Context, request *huaiv1.PageRequest) (*huaiv1.ListRecentResultsResponse, error) {
	userID, ok := UserIDFromContext(ctx)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "authentication required")
	}
	return s.recentResults(ctx, userID, userID, request.GetPageToken(), request.GetPageSize())
}

func (s *playerServer) ListFriendRecentResults(ctx context.Context, request *huaiv1.ListFriendRecentResultsRequest) (*huaiv1.ListRecentResultsResponse, error) {
	userID, ok := UserIDFromContext(ctx)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "authentication required")
	}
	page := request.GetPage()
	return s.recentResults(ctx, userID, request.GetUserId(), page.GetPageToken(), page.GetPageSize())
}

func (s *playerServer) recentResults(ctx context.Context, viewerID, targetID, pageToken string, pageSize uint32) (*huaiv1.ListRecentResultsResponse, error) {
	results, nextPageToken, err := s.service.ListRecentResults(
		ctx, viewerID, targetID, pageToken, pageSize,
	)
	if err != nil {
		return nil, playerReadError(err)
	}
	response := &huaiv1.ListRecentResultsResponse{
		Page: &huaiv1.PageInfo{NextPageToken: nextPageToken},
	}
	for _, result := range results {
		response.Results = append(response.Results, &huaiv1.GameResult{
			GameSessionId: result.GameSessionID,
			Won:           result.Won,
			PointsDelta:   result.PointsDelta,
			EndedAt:       timestamppb.New(result.EndedAt),
		})
	}
	return response, nil
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

func playerReadError(err error) error {
	switch {
	case errors.Is(err, player.ErrInvalidProfile), errors.Is(err, player.ErrInvalidPage):
		return status.Error(codes.InvalidArgument, "invalid player query")
	case errors.Is(err, player.ErrFriendRequired):
		return status.Error(codes.PermissionDenied, "player statistics are visible to friends only")
	case errors.Is(err, player.ErrProfileNotFound):
		return status.Error(codes.NotFound, "player profile not found")
	default:
		return status.Error(codes.Internal, "player query failed")
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
