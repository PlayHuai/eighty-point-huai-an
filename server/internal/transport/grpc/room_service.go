package grpc

import (
	"context"
	"errors"
	"sync"

	"github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/lobby"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/player"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
	grpcgo "google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type roomServer struct {
	huaiv1.UnimplementedRoomServiceServer
	manager     *room.Manager
	profiles    roomProfileRepository
	requestMu   sync.Mutex
	requests    map[roomRequestKey]roomMutationResult
	requestFIFO []roomRequestKey
}

type roomProfileRepository interface {
	player.ProfileRepository
	GetPublicProfiles(context.Context, []string) (map[string]player.PublicProfile, error)
}

type roomMutationSignature struct {
	roomID          string
	userID          string
	operation       string
	expectedVersion uint64
	seat            uint32
	visible         bool
}

type roomMutationResult struct {
	signature roomMutationSignature
	details   room.Details
}

func RegisterRoomService(
	server grpcgo.ServiceRegistrar,
	manager *room.Manager,
	profiles ...roomProfileRepository,
) error {
	if server == nil || manager == nil {
		return errors.New("gRPC registrar and room manager are required")
	}
	if len(profiles) > 1 {
		return errors.New("only one room profile repository is allowed")
	}
	service := &roomServer{manager: manager, requests: make(map[roomRequestKey]roomMutationResult)}
	if len(profiles) == 1 {
		service.profiles = profiles[0]
	}
	huaiv1.RegisterRoomServiceServer(server, service)
	return nil
}

func (s *roomServer) GetRoom(ctx context.Context, request *huaiv1.RoomRequest) (*huaiv1.RoomDetails, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	details, err := s.manager.GetRoom(request.GetRoomId(), userID)
	if err != nil {
		return nil, roomServiceError(err)
	}
	return s.detailsMessage(ctx, details)
}

func (s *roomServer) JoinInvitedRoom(ctx context.Context, request *huaiv1.JoinInvitedRoomRequest) (*huaiv1.RoomDetails, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	details, err := s.manager.JoinInvitedFriendRoom(
		request.GetRoomId(), userID, "", request.GetRequestId(), 0,
	)
	if err != nil {
		return nil, roomServiceError(err)
	}
	return s.detailsMessage(ctx, details)
}

func (s *roomServer) SitDown(ctx context.Context, request *huaiv1.SeatRequest) (*huaiv1.RoomDetails, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if !validUUID(request.GetRequestId()) {
		return nil, status.Error(codes.InvalidArgument, "request_id must be a UUID")
	}
	summary, err := s.manager.GetSummary(request.GetRoomId())
	if err != nil {
		return nil, roomServiceError(err)
	}
	var points int64
	if summary.HallID != lobby.HallFriend {
		if s.profiles == nil {
			return nil, status.Error(codes.FailedPrecondition, "room profile repository is unavailable")
		}
		profile, profileErr := s.profiles.FindProfile(ctx, userID)
		if profileErr != nil {
			return nil, status.Error(codes.Internal, "could not load player profile")
		}
		points = profile.Points
	}
	signature := roomMutationSignature{
		roomID: request.GetRoomId(), userID: userID, operation: "sit_down",
		expectedVersion: request.GetExpectedVersion(), seat: request.GetSeatNo(),
	}
	details, err := s.mutate(signature, request.GetRequestId(), func() (room.Details, error) {
		return s.manager.SitDown(request.GetRoomId(), userID, request.GetSeatNo(), points, request.GetExpectedVersion())
	})
	if err != nil {
		return nil, roomServiceError(err)
	}
	return s.detailsMessage(ctx, details)
}

func (s *roomServer) ChangeSeat(ctx context.Context, request *huaiv1.SeatRequest) (*huaiv1.RoomDetails, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if !validUUID(request.GetRequestId()) {
		return nil, status.Error(codes.InvalidArgument, "request_id must be a UUID")
	}
	signature := roomMutationSignature{
		roomID: request.GetRoomId(), userID: userID, operation: "change_seat",
		expectedVersion: request.GetExpectedVersion(), seat: request.GetSeatNo(),
	}
	details, err := s.mutate(signature, request.GetRequestId(), func() (room.Details, error) {
		return s.manager.ChangeSeat(request.GetRoomId(), userID, request.GetSeatNo(), request.GetExpectedVersion())
	})
	if err != nil {
		return nil, roomServiceError(err)
	}
	return s.detailsMessage(ctx, details)
}

func (s *roomServer) StandUp(ctx context.Context, request *huaiv1.RoomRequest) (*huaiv1.RoomDetails, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if !validUUID(request.GetRequestId()) {
		return nil, status.Error(codes.InvalidArgument, "request_id must be a UUID")
	}
	signature := roomMutationSignature{
		roomID: request.GetRoomId(), userID: userID, operation: "stand_up",
		expectedVersion: request.GetExpectedVersion(),
	}
	details, err := s.mutate(signature, request.GetRequestId(), func() (room.Details, error) {
		return s.manager.StandUp(request.GetRoomId(), userID, request.GetExpectedVersion())
	})
	if err != nil {
		return nil, roomServiceError(err)
	}
	return s.detailsMessage(ctx, details)
}

func (s *roomServer) SetSpectatorView(
	ctx context.Context,
	request *huaiv1.SpectatorViewRequest,
) (*huaiv1.RoomDetails, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if !validUUID(request.GetRequestId()) {
		return nil, status.Error(codes.InvalidArgument, "request_id must be a UUID")
	}
	signature := roomMutationSignature{
		roomID: request.GetRoomId(), userID: userID, operation: "spectator_view",
		expectedVersion: request.GetExpectedVersion(), seat: request.GetViewSeat(),
	}
	details, err := s.mutate(signature, request.GetRequestId(), func() (room.Details, error) {
		return s.manager.SetSpectatorView(request.GetRoomId(), userID, request.GetViewSeat(), request.GetExpectedVersion())
	})
	if err != nil {
		return nil, roomServiceError(err)
	}
	return s.detailsMessage(ctx, details)
}

func (s *roomServer) SetHandVisibility(
	ctx context.Context,
	request *huaiv1.SpectatorViewRequest,
) (*huaiv1.RoomDetails, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if !validUUID(request.GetRequestId()) {
		return nil, status.Error(codes.InvalidArgument, "request_id must be a UUID")
	}
	signature := roomMutationSignature{
		roomID: request.GetRoomId(), userID: userID, operation: "hand_visibility",
		expectedVersion: request.GetExpectedVersion(), visible: request.GetShowHand(),
	}
	details, err := s.mutate(signature, request.GetRequestId(), func() (room.Details, error) {
		return s.manager.SetHandVisibility(request.GetRoomId(), userID, request.GetShowHand(), request.GetExpectedVersion())
	})
	if err != nil {
		return nil, roomServiceError(err)
	}
	return s.detailsMessage(ctx, details)
}

func (s *roomServer) StartGame(ctx context.Context, request *huaiv1.RoomRequest) (*huaiv1.GameSnapshot, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if !validUUID(request.GetRequestId()) {
		return nil, status.Error(codes.InvalidArgument, "request_id must be a UUID")
	}
	details, err := s.manager.GetRoom(request.GetRoomId(), userID)
	if err != nil {
		return nil, roomServiceError(err)
	}
	if details.Room.OwnerID != userID {
		return nil, status.Error(codes.PermissionDenied, "only the room owner can start the game")
	}
	if details.Room.Status != room.StatusWaiting || details.Room.OccupiedSeats != 4 {
		return nil, status.Error(codes.FailedPrecondition, "room requires four seated players")
	}
	return nil, status.Error(codes.FailedPrecondition, "authoritative game rules engine is not configured")
}

func (s *roomServer) mutate(
	signature roomMutationSignature,
	requestID string,
	run func() (room.Details, error),
) (room.Details, error) {
	if !validUUID(requestID) {
		return room.Details{}, room.ErrInvalidInput
	}
	key := roomRequestKey{userID: signature.userID, requestID: requestID}
	s.requestMu.Lock()
	defer s.requestMu.Unlock()
	if previous, exists := s.requests[key]; exists {
		if previous.signature != signature {
			return room.Details{}, room.ErrInvitationRequestConflict
		}
		return cloneRoomDetails(previous.details), nil
	}
	details, err := run()
	if err != nil {
		return room.Details{}, err
	}
	s.requests[key] = roomMutationResult{signature: signature, details: cloneRoomDetails(details)}
	s.requestFIFO = append(s.requestFIFO, key)
	if len(s.requestFIFO) > 10000 {
		oldest := s.requestFIFO[0]
		s.requestFIFO = s.requestFIFO[1:]
		delete(s.requests, oldest)
	}
	return details, nil
}

func cloneRoomDetails(details room.Details) room.Details {
	details.Members = append([]room.Member(nil), details.Members...)
	return details
}

func (s *roomServer) detailsMessage(ctx context.Context, details room.Details) (*huaiv1.RoomDetails, error) {
	message := roomDetailsMessage(details)
	if s.profiles == nil || len(details.Members) == 0 {
		return message, nil
	}
	userIDs := make([]string, 0, len(details.Members))
	for _, member := range details.Members {
		userIDs = append(userIDs, member.UserID)
	}
	profiles, err := s.profiles.GetPublicProfiles(ctx, userIDs)
	if err != nil {
		return nil, status.Error(codes.Internal, "could not load room member profiles")
	}
	for _, member := range message.Members {
		profile, exists := profiles[member.GetUserId()]
		if !exists {
			continue
		}
		member.Profile = &huaiv1.UserProfile{
			UserId: profile.UserID, Nickname: profile.Nickname, AvatarUrl: profile.AvatarURL,
			CreatedAt: timestamppb.New(profile.CreatedAt),
		}
	}
	return message, nil
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
		Version: details.Version, GameSessionId: details.GameSessionID,
	}
	for _, member := range details.Members {
		role := huaiv1.RoomMemberRole_ROOM_MEMBER_ROLE_PLAYER
		teamSeat := member.Seat
		if member.Role == room.RoleSpectator {
			role = huaiv1.RoomMemberRole_ROOM_MEMBER_ROLE_SPECTATOR
			teamSeat = member.ViewSeat
		}
		response.Members = append(response.Members, &huaiv1.RoomMember{
			UserId: member.UserID, Role: role, SeatNo: member.Seat,
			ShowHand: member.ShowHand, ViewSeat: member.ViewSeat, Team: teamForSeat(teamSeat),
		})
	}
	return response
}

func roomServiceError(err error) error {
	switch {
	case errors.Is(err, room.ErrInvitationRequired), errors.Is(err, room.ErrOwnerRequired),
		errors.Is(err, room.ErrNotMember):
		return status.Error(codes.PermissionDenied, "room permission denied")
	case errors.Is(err, room.ErrInvitationRequestConflict):
		return status.Error(codes.AlreadyExists, "request ID was already used")
	case errors.Is(err, room.ErrVersionConflict):
		return status.Error(codes.Aborted, "room state changed")
	case errors.Is(err, room.ErrRoomNotFound):
		return status.Error(codes.NotFound, "room not found")
	case errors.Is(err, room.ErrRoomFull), errors.Is(err, room.ErrAlreadyMember),
		errors.Is(err, room.ErrSeatUnavailable):
		return status.Error(codes.AlreadyExists, "room seat is unavailable")
	case errors.Is(err, room.ErrRoomStarted), errors.Is(err, room.ErrRoomClosed),
		errors.Is(err, room.ErrRoomNotReady), errors.Is(err, room.ErrSpectatorsDisabled):
		return status.Error(codes.FailedPrecondition, "room state does not allow this operation")
	case errors.Is(err, room.ErrInvalidInput):
		return status.Error(codes.InvalidArgument, "invalid room request")
	case errors.Is(err, room.ErrAdmissionDenied):
		return status.Error(codes.PermissionDenied, "room admission denied")
	case errors.Is(err, room.ErrInvalidPassword):
		return status.Error(codes.PermissionDenied, "invalid room password")
	default:
		return status.Error(codes.Internal, "could not process room request")
	}
}

func teamForSeat(seat uint32) uint32 {
	if seat == 0 || seat > 4 {
		return 0
	}
	if seat%2 == 1 {
		return 1
	}
	return 2
}

func validUUID(value string) bool {
	if len(value) != 36 || value[8] != '-' || value[13] != '-' || value[18] != '-' || value[23] != '-' {
		return false
	}
	for index, char := range value {
		if index == 8 || index == 13 || index == 18 || index == 23 {
			continue
		}
		if !((char >= '0' && char <= '9') || (char >= 'a' && char <= 'f') || (char >= 'A' && char <= 'F')) {
			return false
		}
	}
	return true
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
