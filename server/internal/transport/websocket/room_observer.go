package websocket

import (
	"encoding/json"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
)

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
		h.PublishLobbyUpdate(details.Room.ID, details.Version, payload)
	})
}
