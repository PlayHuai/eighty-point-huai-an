package grpc

import (
	"context"
	"errors"

	"github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
	grpcgo "google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type roomServer struct {
	huaiv1.UnimplementedRoomServiceServer
	manager *room.Manager
}

func RegisterRoomService(server grpcgo.ServiceRegistrar, manager *room.Manager) error {
	if server == nil || manager == nil {
		return errors.New("gRPC registrar and room manager are required")
	}
	huaiv1.RegisterRoomServiceServer(server, &roomServer{manager: manager})
	return nil
}

func (s *roomServer) JoinInvitedRoom(ctx context.Context, request *huaiv1.JoinInvitedRoomRequest) (*huaiv1.RoomDetails, error) {
	userID, ok := UserIDFromContext(ctx)
	if !ok {
		return nil, status.Error(codes.Unauthenticated, "authentication required")
	}
	details, err := s.manager.JoinInvitedFriendRoom(
		request.GetRoomId(), userID, "", request.GetRequestId(), 0,
	)
	if err != nil {
		switch {
		case errors.Is(err, room.ErrInvitationRequired), errors.Is(err, room.ErrOwnerRequired):
			return nil, status.Error(codes.PermissionDenied, "friend room invitation required")
		case errors.Is(err, room.ErrInvitationRequestConflict):
			return nil, status.Error(codes.AlreadyExists, "request ID was already used")
		case errors.Is(err, room.ErrVersionConflict):
			return nil, status.Error(codes.Aborted, "room state changed")
		case errors.Is(err, room.ErrRoomNotFound):
			return nil, status.Error(codes.NotFound, "room not found")
		case errors.Is(err, room.ErrRoomFull), errors.Is(err, room.ErrRoomStarted), errors.Is(err, room.ErrRoomClosed):
			return nil, status.Error(codes.FailedPrecondition, "friend room is no longer joinable")
		case errors.Is(err, room.ErrInvalidInput):
			return nil, status.Error(codes.InvalidArgument, "invalid room request")
		default:
			return nil, status.Error(codes.Internal, "could not join friend room")
		}
	}
	return roomDetailsMessage(details), nil
}

func roomDetailsMessage(details room.Details) *huaiv1.RoomDetails {
	summary := details.Room
	response := &huaiv1.RoomDetails{
		Room: &huaiv1.RoomSummary{
			RoomId:          summary.ID,
			HallId:          summary.HallID,
			Name:            summary.Name,
			Status:          roomStatusMessage(summary.Status),
			OccupiedSeats:   summary.OccupiedSeats,
			Capacity:        summary.Capacity,
			HasPassword:     summary.HasPassword,
			Version:         summary.Version,
			Owner:           &huaiv1.UserProfile{UserId: summary.OwnerID},
			AllowSpectators: summary.AllowSpectators,
			MinimumPoints:   summary.MinimumPoints,
		},
		Version: details.Version,
	}
	for _, member := range details.Members {
		role := huaiv1.RoomMemberRole_ROOM_MEMBER_ROLE_PLAYER
		if member.Role == room.RoleSpectator {
			role = huaiv1.RoomMemberRole_ROOM_MEMBER_ROLE_SPECTATOR
		}
		response.Members = append(response.Members, &huaiv1.RoomMember{
			UserId: member.UserID,
			Role:   role,
			SeatNo: member.Seat,
		})
	}
	return response
}

func roomStatusMessage(value room.Status) huaiv1.RoomStatus {
	switch value {
	case room.StatusWaiting:
		return huaiv1.RoomStatus_ROOM_STATUS_WAITING
	case room.StatusPlaying:
		return huaiv1.RoomStatus_ROOM_STATUS_PLAYING
	case room.StatusClosed:
		return huaiv1.RoomStatus_ROOM_STATUS_CLOSED
	default:
		return huaiv1.RoomStatus_ROOM_STATUS_UNSPECIFIED
	}
}

var _ huaiv1.RoomServiceServer = (*roomServer)(nil)
