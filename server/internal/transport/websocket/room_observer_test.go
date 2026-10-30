package websocket

import (
	"testing"
	"time"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
)

func TestRoomObserverBroadcastsLobbyAndMemberState(t *testing.T) {
	hub := NewHub()
	manager := room.NewManager()
	hub.ObserveRooms(manager)
	member, err := hub.Subscribe("member")
	if err != nil {
		t.Fatal(err)
	}
	defer member.Close()
	unrelated, err := hub.Subscribe("unrelated")
	if err != nil {
		t.Fatal(err)
	}
	defer unrelated.Close()

	details, err := manager.CreateRoom("ordinary", "member", 0, room.Settings{Name: "table"})
	if err != nil {
		t.Fatal(err)
	}
	assertEvent := func(subscription *Subscription, wantType, wantRoomID string) Event {
		t.Helper()
		select {
		case event := <-subscription.Events():
			if event.Type != wantType || event.EntityID != wantRoomID && event.RoomID != wantRoomID {
				t.Fatalf("event = %+v, want type %q for room %q", event, wantType, wantRoomID)
			}
			return event
		case <-time.After(time.Second):
			t.Fatalf("no %s event for room %s", wantType, wantRoomID)
			return Event{}
		}
	}
	assertEvent(member, "LOBBY_STATE_CHANGED", details.Room.ID)
	assertEvent(unrelated, "LOBBY_STATE_CHANGED", details.Room.ID)

	if _, err := manager.JoinRoom(details.Room.ID, "member", 0, "", details.Version); err != nil {
		t.Fatal(err)
	}
	assertEvent(member, "ROOM_STATE_CHANGED", details.Room.ID)
	assertEvent(member, "LOBBY_STATE_CHANGED", details.Room.ID)
	assertEvent(unrelated, "LOBBY_STATE_CHANGED", details.Room.ID)
	select {
	case event := <-unrelated.Events():
		t.Fatalf("non-member received room state: %+v", event)
	default:
	}
}
