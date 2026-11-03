package player

import (
	"context"
	"errors"
)

var ErrSettingsConflict = errors.New("settings version conflict")
var ErrSettingsRequest = errors.New("settings request reused")

type Settings struct {
	ShowHand bool
	Version  uint64
}
type SettingsRepository interface {
	GetPlayerSettings(context.Context, string) (Settings, error)
	UpdatePlayerSettings(context.Context, string, bool, uint64, string) (Settings, error)
}

func (s *PublicProfileService) Settings(ctx context.Context, userID string) (Settings, error) {
	r, ok := s.repository.(SettingsRepository)
	if !ok {
		return Settings{}, errors.New("player settings repository unavailable")
	}
	return r.GetPlayerSettings(ctx, userID)
}
func (s *PublicProfileService) UpdateSettings(ctx context.Context, userID string, show bool, version uint64, requestID string) (Settings, error) {
	r, ok := s.repository.(SettingsRepository)
	if !ok {
		return Settings{}, errors.New("player settings repository unavailable")
	}
	return r.UpdatePlayerSettings(ctx, userID, show, version, requestID)
}
