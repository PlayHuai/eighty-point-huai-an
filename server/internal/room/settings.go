package room

import (
	"context"
	"time"
)

func (m *Manager) SetVisibilityReader(reader func(context.Context, string) (bool, error)) {
	m.visibilityReader = reader
}
func (m *Manager) ApplyHandVisibility(userID string, visible bool) {
	m.mu.RLock()
	states := make([]*roomState, 0, len(m.rooms))
	for _, s := range m.rooms {
		states = append(states, s)
	}
	m.mu.RUnlock()
	for _, s := range states {
		s.mu.Lock()
		member, ok := s.members[userID]
		if !ok || member.Role != RolePlayer || member.ShowHand == visible {
			s.mu.Unlock()
			continue
		}
		member.ShowHand = visible
		s.members[userID] = member
		s.version++
		details := snapshotLocked(s)
		s.mu.Unlock()
		m.notifyRoom(details)
	}
}
func (m *Manager) resolveVisibility(details Details) (Details, error) {
	if m.visibilityReader == nil {
		return details, nil
	}
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	for i, member := range details.Members {
		if member.IsRobot || member.Role != RolePlayer {
			continue
		}
		show, err := m.visibilityReader(ctx, member.UserID)
		if err != nil {
			return Details{}, err
		}
		details.Members[i].ShowHand = show
	}
	return details, nil
}
func (m *Manager) SetWaitingLeaveHandler(handler func(Details, string) error) {
	m.waitingLeave = handler
}
