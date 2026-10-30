package websocket

import (
	"encoding/json"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/lobby"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
)

type lobbyRoomSummary struct {
	ID              string      `json:"id"`
	HallID          string      `json:"hall_id"`
	Name            string      `json:"name"`
	Status          room.Status `json:"status"`
	OccupiedSeats   uint32      `json:"occupied_seats"`
	Capacity        uint32      `json:"capacity"`
	HasPassword     bool        `json:"has_password"`
	Version         uint64      `json:"version"`
	AllowSpectators bool        `json:"allow_spectators"`
	MinimumPoints   int64       `json:"minimum_points"`
}

func (h *Hub) ObserveRooms(manager *room.Manager) {
	if manager == nil {
		return
	}
	manager.SetObserver(func(details room.Details) {
		payload, err := json.Marshal(struct {
			Room    room.Summary  `json:"room"`
			Members []room.Member `json:"members"`
		}{Room: details.Room, Members: details.Members})
		if err != nil {
			return
		}
		memberIDs := make([]string, 0, len(details.Members))
		for _, member := range details.Members {
			memberIDs = append(memberIDs, member.UserID)
		}
		h.PublishRoomUpdate(memberIDs, details.Room.ID, details.Version, payload)
		if details.Room.HallID == lobby.HallFriend {
			return
		}
		lobbyPayload, err := json.Marshal(struct {
			Room lobbyRoomSummary `json:"room"`
		}{Room: lobbyRoomSummary{
			ID: details.Room.ID, HallID: details.Room.HallID, Name: details.Room.Name,
			Status: details.Room.Status, OccupiedSeats: details.Room.OccupiedSeats,
			Capacity: details.Room.Capacity, HasPassword: details.Room.HasPassword,
			Version:         details.Version,
			AllowSpectators: details.Room.AllowSpectators, MinimumPoints: details.Room.MinimumPoints,
		}})
		if err != nil {
			return
		}
		h.PublishLobbyUpdate(details.Room.HallID, details.Room.ID, details.Version, lobbyPayload)
	})
}
