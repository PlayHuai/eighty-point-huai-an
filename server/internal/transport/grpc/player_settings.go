package grpc

import (
	"context"
	"errors"
	huaiv1 "github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/player"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (s *playerServer) GetSettings(ctx context.Context, _ *huaiv1.Empty) (*huaiv1.PlayerSettings, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	value, err := s.service.Settings(ctx, userID)
	if err != nil {
		return nil, playerProfileError(err)
	}
	return &huaiv1.PlayerSettings{ShowHandToSpectators: value.ShowHand, Version: value.Version}, nil
}
func (s *playerServer) UpdateSettings(ctx context.Context, request *huaiv1.UpdateSettingsRequest) (*huaiv1.PlayerSettings, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if !validUUID(request.GetRequestId()) {
		return nil, status.Error(codes.InvalidArgument, "request_id must be a UUID")
	}
	value, err := s.service.UpdateSettings(ctx, userID, request.GetShowHandToSpectators(), request.GetExpectedVersion(), request.GetRequestId())
	if errors.Is(err, player.ErrSettingsConflict) {
		return nil, status.Error(codes.Aborted, "settings version conflict")
	}
	if errors.Is(err, player.ErrSettingsRequest) {
		return nil, status.Error(codes.AlreadyExists, "settings request reused")
	}
	if err != nil {
		return nil, playerProfileError(err)
	}
	if s.settingsChanged != nil {
		s.settingsChanged(userID, value.ShowHand)
	}
	return &huaiv1.PlayerSettings{ShowHandToSpectators: value.ShowHand, Version: value.Version}, nil
}
