package grpc

import (
	"context"
	"encoding/hex"
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

type lobbyServer struct {
	huaiv1.UnimplementedLobbyServiceServer
	rooms        *room.Manager
	profiles     lobbyProfileRepository
	identity     weChatIdentityResolver
	requestMu    sync.Mutex
	createdRooms map[roomRequestKey]createRoomResult
	leftRooms    map[roomRequestKey]leaveRoomRequest
}

type weChatIdentityResolver interface {
	IsWeChatUser(context.Context, string) (bool, error)
}

type roomRequestKey struct {
	userID    string
	requestID string
}

type createRoomRequest struct {
	hallID          string
	name            string
	allowSpectators bool
	minimumPoints   int64
}

type createRoomResult struct {
	request createRoomRequest
	room    room.Summary
}

type leaveRoomRequest struct {
	roomID          string
	expectedVersion uint64
}

type lobbyProfileRepository interface {
	player.ProfileRepository
	GetPublicProfiles(ctx context.Context, userIDs []string) (map[string]player.PublicProfile, error)
}

func RegisterLobbyService(
	server grpcgo.ServiceRegistrar,
	rooms *room.Manager,
	profiles lobbyProfileRepository,
	identities ...weChatIdentityResolver,
) error {
	if server == nil || rooms == nil || profiles == nil {
		return errors.New("gRPC registrar, room manager, and player profiles are required")
	}
	service := &lobbyServer{rooms: rooms, profiles: profiles}
	if len(identities) > 1 {
		return errors.New("only one WeChat identity resolver is allowed")
	}
	if len(identities) == 1 {
		service.identity = identities[0]
	}
	huaiv1.RegisterLobbyServiceServer(server, service)
	return nil
}

func (s *lobbyServer) ListHalls(ctx context.Context, _ *huaiv1.Empty) (*huaiv1.ListHallsResponse, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	wechatUser, err := s.isWeChatUser(ctx, userID)
	if err != nil {
		return nil, status.Error(codes.Internal, "could not determine account type")
	}
	response := &huaiv1.ListHallsResponse{}
	for _, hall := range lobby.Halls() {
		if (hall.ID == lobby.HallEntertainment) != wechatUser {
			continue
		}
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
	if err := s.authorizeHall(ctx, userID, request.GetHallId()); err != nil {
		return nil, err
	}
	afterRoomID, pageSize, err := roomPageWindow(
		request.GetPage().GetPageToken(),
		request.GetPage().GetPageSize(),
	)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "invalid room page")
	}
	profile, err := s.profiles.FindProfile(ctx, userID)
	if err != nil {
		return nil, status.Error(codes.Internal, "could not load player profile")
	}
	hallID := request.GetHallId()
	rooms, hasMore, err := s.rooms.ListRoomsPage(hallID, profile.Points, afterRoomID, pageSize)
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

	ownerIDs := make([]string, 0, len(rooms))
	seenOwners := make(map[string]struct{}, len(rooms))
	for _, summary := range rooms {
		if _, seen := seenOwners[summary.OwnerID]; seen {
			continue
		}
		seenOwners[summary.OwnerID] = struct{}{}
		ownerIDs = append(ownerIDs, summary.OwnerID)
	}
	owners, err := s.profiles.GetPublicProfiles(ctx, ownerIDs)
	if err != nil {
		return nil, status.Error(codes.Internal, "could not load room owners")
	}
	response := &huaiv1.ListRoomsResponse{
		Page: &huaiv1.PageInfo{},
	}
	for _, summary := range rooms {
		owner := &huaiv1.UserProfile{UserId: summary.OwnerID}
		if profile, exists := owners[summary.OwnerID]; exists {
			owner.Nickname = profile.Nickname
			owner.AvatarUrl = profile.AvatarURL
			owner.CreatedAt = timestamppb.New(profile.CreatedAt)
		}
		response.Rooms = append(response.Rooms, roomSummaryMessage(summary, owner))
	}
	if hasMore && len(rooms) != 0 {
		response.Page.NextPageToken = rooms[len(rooms)-1].ID
	}
	return response, nil
}

func (s *lobbyServer) CreateRoom(
	ctx context.Context,
	request *huaiv1.CreateRoomRequest,
) (*huaiv1.RoomSummary, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := s.authorizeHall(ctx, userID, request.GetHallId()); err != nil {
		return nil, err
	}
	requestID := request.GetRequestId()
	if !validLobbyRequestID(requestID) {
		return nil, status.Error(codes.InvalidArgument, "valid request ID is required")
	}
	requestData := createRoomRequest{
		hallID: request.GetHallId(), name: request.GetName(),
		allowSpectators: request.GetAllowSpectators(), minimumPoints: request.GetMinimumPoints(),
	}
	key := roomRequestKey{userID: userID, requestID: requestID}
	s.requestMu.Lock()
	defer s.requestMu.Unlock()
	if s.createdRooms == nil {
		s.createdRooms = make(map[roomRequestKey]createRoomResult)
	}
	if previous, ok := s.createdRooms[key]; ok {
		if previous.request != requestData ||
			!s.rooms.MatchesRoomPassword(previous.room.ID, request.GetPassword()) {
			return nil, status.Error(codes.AlreadyExists, "request ID was reused with different room settings")
		}
		return roomSummaryMessage(previous.room, &huaiv1.UserProfile{UserId: userID}), nil
	}
	profile, err := s.profiles.FindProfile(ctx, userID)
	if err != nil {
		return nil, status.Error(codes.Internal, "could not load player profile")
	}
	details, err := s.rooms.CreateRoom(requestData.hallID, userID, profile.Points, room.Settings{
		Name: requestData.name, Password: request.GetPassword(),
		AllowSpectators: requestData.allowSpectators, MinimumPoints: requestData.minimumPoints,
	})
	if err != nil {
		return nil, roomOperationError(err)
	}
	s.createdRooms[key] = createRoomResult{request: requestData, room: details.Room}
	return roomSummaryMessage(details.Room, &huaiv1.UserProfile{UserId: userID}), nil
}

func (s *lobbyServer) JoinRoom(
	ctx context.Context,
	request *huaiv1.RoomRequest,
) (*huaiv1.RoomSummary, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	summary, err := s.rooms.GetSummary(request.GetRoomId())
	if err != nil {
		return nil, roomOperationError(err)
	}
	if err := s.authorizeHall(ctx, userID, summary.HallID); err != nil {
		return nil, err
	}
	profile, err := s.profiles.FindProfile(ctx, userID)
	if err != nil {
		return nil, status.Error(codes.Internal, "could not load player profile")
	}
	details, err := s.rooms.JoinRoom(
		request.GetRoomId(), userID, profile.Points, "", request.GetExpectedVersion(),
	)
	if err != nil {
		return nil, roomOperationError(err)
	}
	return roomSummaryMessage(details.Room, &huaiv1.UserProfile{UserId: details.Room.OwnerID}), nil
}

func (s *lobbyServer) LeaveRoom(
	ctx context.Context,
	request *huaiv1.RoomRequest,
) (*huaiv1.Empty, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	requestID := request.GetRequestId()
	if !validLobbyRequestID(requestID) {
		return nil, status.Error(codes.InvalidArgument, "valid request ID is required")
	}
	key := roomRequestKey{userID: userID, requestID: requestID}
	requestData := leaveRoomRequest{
		roomID: request.GetRoomId(), expectedVersion: request.GetExpectedVersion(),
	}
	s.requestMu.Lock()
	defer s.requestMu.Unlock()
	if s.leftRooms == nil {
		s.leftRooms = make(map[roomRequestKey]leaveRoomRequest)
	}
	if previous, ok := s.leftRooms[key]; ok {
		if previous != requestData {
			return nil, status.Error(codes.AlreadyExists, "request ID was reused with different room settings")
		}
		return &huaiv1.Empty{}, nil
	}
	if _, err := s.rooms.LeaveRoom(request.GetRoomId(), userID, request.GetExpectedVersion()); err != nil {
		return nil, roomOperationError(err)
	}
	s.leftRooms[key] = requestData
	return &huaiv1.Empty{}, nil
}

func (s *lobbyServer) JoinByCode(
	ctx context.Context,
	request *huaiv1.JoinByCodeRequest,
) (*huaiv1.RoomSummary, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	profile, err := s.profiles.FindProfile(ctx, userID)
	if err != nil {
		return nil, status.Error(codes.Internal, "could not load player profile")
	}
	summary, err := s.rooms.GetSummary(request.GetRoomCode())
	if err != nil {
		return nil, roomOperationError(err)
	}
	if err := s.authorizeHall(ctx, userID, summary.HallID); err != nil {
		return nil, err
	}
	details, err := s.rooms.JoinRoom(
		summary.ID, userID, profile.Points, request.GetPassword(), summary.Version,
	)
	if err != nil {
		return nil, roomOperationError(err)
	}
	return roomSummaryMessage(details.Room, &huaiv1.UserProfile{UserId: details.Room.OwnerID}), nil
}

func (s *lobbyServer) isWeChatUser(ctx context.Context, userID string) (bool, error) {
	if s.identity == nil {
		return false, nil
	}
	return s.identity.IsWeChatUser(ctx, userID)
}

func (s *lobbyServer) authorizeHall(ctx context.Context, userID, hallID string) error {
	if _, err := lobby.FindHall(hallID); err != nil {
		return status.Error(codes.InvalidArgument, "unknown hall")
	}
	wechatUser, err := s.isWeChatUser(ctx, userID)
	if err != nil {
		return status.Error(codes.Internal, "could not determine account type")
	}
	if (hallID == lobby.HallEntertainment) != wechatUser {
		return status.Error(codes.PermissionDenied, "hall is unavailable for this account")
	}
	return nil
}

func roomOperationError(err error) error {
	switch {
	case errors.Is(err, lobby.ErrUnknownHall), errors.Is(err, room.ErrInvalidInput):
		return status.Error(codes.InvalidArgument, "invalid room request")
	case errors.Is(err, room.ErrRoomNotFound):
		return status.Error(codes.NotFound, "room not found")
	case errors.Is(err, room.ErrVersionConflict):
		return status.Error(codes.Aborted, "room state changed")
	case errors.Is(err, room.ErrNotMember), errors.Is(err, room.ErrInvitationRequired),
		errors.Is(err, room.ErrAdmissionDenied), errors.Is(err, room.ErrInvalidPassword):
		return status.Error(codes.PermissionDenied, "room access denied")
	case errors.Is(err, room.ErrAlreadyMember):
		return status.Error(codes.AlreadyExists, "already a room member")
	case errors.Is(err, room.ErrRoomFull), errors.Is(err, room.ErrRoomStarted),
		errors.Is(err, room.ErrRoomClosed), errors.Is(err, room.ErrRoomNotReady):
		return status.Error(codes.FailedPrecondition, "room is not available")
	default:
		return status.Error(codes.Internal, "room operation failed")
	}
}

func roomSummaryMessage(summary room.Summary, owner *huaiv1.UserProfile) *huaiv1.RoomSummary {
	return &huaiv1.RoomSummary{
		RoomId: summary.ID, HallId: summary.HallID, Name: summary.Name,
		Status: roomStatusMessage(summary.Status), OccupiedSeats: summary.OccupiedSeats,
		Capacity: summary.Capacity, HasPassword: summary.HasPassword, Version: summary.Version,
		Owner: owner, AllowSpectators: summary.AllowSpectators, MinimumPoints: summary.MinimumPoints,
	}
}

func roomPageWindow(token string, requestedSize uint32) (string, uint32, error) {
	if token != "" {
		decoded, err := hex.DecodeString(token)
		if err != nil || len(decoded) != 16 || hex.EncodeToString(decoded) != token {
			return "", 0, errors.New("invalid room page cursor")
		}
	}
	if requestedSize == 0 {
		requestedSize = 20
	}
	if requestedSize > 100 {
		return "", 0, errors.New("room page is out of range")
	}
	return token, requestedSize, nil
}

func validLobbyRequestID(value string) bool {
	if value == "" || len(value) > 128 {
		return false
	}
	for _, char := range value {
		if char < 0x21 || char > 0x7e {
			return false
		}
	}
	return true
}

var _ huaiv1.LobbyServiceServer = (*lobbyServer)(nil)
