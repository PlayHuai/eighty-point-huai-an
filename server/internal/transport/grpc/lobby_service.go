package grpc

import (
	"context"
	"errors"
	"strconv"

	"github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/lobby"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/player"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
	grpcgo "google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type lobbyServer struct {
	huaiv1.UnimplementedLobbyServiceServer
	rooms    *room.Manager
	profiles lobbyProfileRepository
}

type lobbyProfileRepository interface {
	player.ProfileRepository
	player.PublicProfileRepository
}

func RegisterLobbyService(
	server grpcgo.ServiceRegistrar,
	rooms *room.Manager,
	profiles lobbyProfileRepository,
) error {
	if server == nil || rooms == nil || profiles == nil {
		return errors.New("gRPC registrar, room manager, and player profiles are required")
	}
	huaiv1.RegisterLobbyServiceServer(server, &lobbyServer{rooms: rooms, profiles: profiles})
	return nil
}

func (s *lobbyServer) ListHalls(ctx context.Context, _ *huaiv1.Empty) (*huaiv1.ListHallsResponse, error) {
	if _, err := authenticatedUserID(ctx); err != nil {
		return nil, err
	}
	response := &huaiv1.ListHallsResponse{}
	for _, hall := range lobby.Halls() {
		response.Halls = append(response.Halls, &huaiv1.Hall{
			HallId: hall.ID, Name: hall.Name, MinimumPoints: hall.MinimumPoints,
			MaximumPoints: hall.MaximumPoints, MultiplierBasisPoints: hall.MultiplierBasisPoints,
		})
	}
	return response, nil
}

func (s *lobbyServer) ListRooms(
	ctx context.Context,
	request *huaiv1.ListRoomsRequest,
) (*huaiv1.ListRoomsResponse, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	profile, err := s.profiles.FindProfile(ctx, userID)
	if err != nil {
		return nil, status.Error(codes.Internal, "could not load player profile")
	}
	hallID := request.GetHallId()
	rooms, err := s.rooms.ListRooms(hallID, profile.Points)
	if err != nil {
		switch {
		case errors.Is(err, lobby.ErrUnknownHall):
			return nil, status.Error(codes.InvalidArgument, "unknown hall")
		case errors.Is(err, room.ErrAdmissionDenied):
			return nil, status.Error(codes.PermissionDenied, "hall admission denied")
		case errors.Is(err, room.ErrInvitationRequired):
			return nil, status.Error(codes.FailedPrecondition, "friend rooms are invitation-only")
		default:
			return nil, status.Error(codes.Internal, "could not list rooms")
		}
	}
	offset, limit, err := roomPageWindow(request.GetPage().GetPageToken(), request.GetPage().GetPageSize())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "invalid room page")
	}
	start := min(offset, uint64(len(rooms)))
	end := min(start+limit, uint64(len(rooms)))
	response := &huaiv1.ListRoomsResponse{
		Page: &huaiv1.PageInfo{},
	}
	for _, summary := range rooms[int(start):int(end)] {
		owner := &huaiv1.UserProfile{UserId: summary.OwnerID}
		if profile, profileErr := s.profiles.GetPublicProfile(ctx, summary.OwnerID); profileErr == nil {
			owner.Nickname = profile.Nickname
			owner.AvatarUrl = profile.AvatarURL
			owner.CreatedAt = timestamppb.New(profile.CreatedAt)
		} else if !errors.Is(profileErr, player.ErrProfileNotFound) {
			return nil, status.Error(codes.Internal, "could not load room owner")
		}
		response.Rooms = append(response.Rooms, roomSummaryMessage(summary, owner))
	}
	if end < uint64(len(rooms)) {
		response.Page.NextPageToken = strconv.FormatUint(end, 10)
	}
	return response, nil
}

func roomSummaryMessage(summary room.Summary, owner *huaiv1.UserProfile) *huaiv1.RoomSummary {
	return &huaiv1.RoomSummary{
		RoomId: summary.ID, HallId: summary.HallID, Name: summary.Name,
		Status: roomStatusMessage(summary.Status), OccupiedSeats: summary.OccupiedSeats,
		Capacity: summary.Capacity, HasPassword: summary.HasPassword, Version: summary.Version,
		Owner: owner, AllowSpectators: summary.AllowSpectators, MinimumPoints: summary.MinimumPoints,
	}
}

func roomPageWindow(token string, requestedSize uint32) (uint64, uint64, error) {
	var offset uint64
	if token != "" {
		value, err := strconv.ParseUint(token, 10, 32)
		if err != nil {
			return 0, 0, err
		}
		offset = value
	}
	limit := uint64(requestedSize)
	if limit == 0 {
		limit = 20
	}
	if limit > 100 || offset > 1_000_000 {
		return 0, 0, errors.New("room page is out of range")
	}
	return offset, limit, nil
}

var _ huaiv1.LobbyServiceServer = (*lobbyServer)(nil)
