package websocket

import (
	"strings"
	"testing"
	"time"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
)

func TestRoomObserverBroadcastsLobbyAndMemberState(t *testing.T) {
	hub := NewHub()
	manager := room.NewManager()
	hub.ObserveRooms(manager)
	member, err := hub.SubscribeWithFriendsAndHalls("member", nil, []string{"ordinary"})
	if err != nil {
		t.Fatal(err)
	}
	defer member.Close()
	unrelated, err := hub.SubscribeWithFriendsAndHalls("unrelated", nil, nil)
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
	lobbyEvent := assertEvent(member, "LOBBY_STATE_CHANGED", details.Room.ID)
	select {
	case event := <-unrelated.Events():
		t.Fatalf("ineligible user received lobby update: %+v", event)
	default:
	}
	if lobbyEvent.Type != "LOBBY_STATE_CHANGED" ||
		string(lobbyEvent.Payload) == "" ||
		strings.Contains(string(lobbyEvent.Payload), `"members"`) ||
		strings.Contains(string(lobbyEvent.Payload), `"owner_id"`) {
		t.Fatalf("lobby payload contains restricted room details: %+v", lobbyEvent)
	}

	if _, err := manager.JoinRoom(details.Room.ID, "member", 0, "", details.Version); err != nil {
		t.Fatal(err)
	}
	assertEvent(member, "ROOM_STATE_CHANGED", details.Room.ID)
	assertEvent(member, "LOBBY_STATE_CHANGED", details.Room.ID)
	select {
	case event := <-unrelated.Events():
		t.Fatalf("ineligible user received room state: %+v", event)
	default:
	}
}

func TestRoomObserverDoesNotBroadcastFriendRoomToLobby(t *testing.T) {
	hub := NewHub()
	manager := room.NewManager()
	hub.ObserveRooms(manager)
	member, _ := hub.SubscribeWithFriendsAndHalls("owner", nil, []string{"friend"})
	defer member.Close()
	details, err := manager.CreateRoom("friend", "owner", 0, room.Settings{Name: "private"})
	if err != nil {
		t.Fatal(err)
	}
	select {
	case event := <-member.Events():
		t.Fatalf("friend room was broadcast to lobby: %+v", event)
	default:
	}
	if _, err := manager.JoinRoom(details.Room.ID, "owner", 0, "", details.Version); err != nil {
		t.Fatal(err)
	}
	select {
	case event := <-member.Events():
		if event.Type != "ROOM_STATE_CHANGED" || event.RoomID != details.Room.ID {
			t.Fatalf("unexpected friend-room event: %+v", event)
		}
	default:
		t.Fatal("room member did not receive restricted room state")
	}
	select {
	case event := <-member.Events():
		t.Fatalf("friend room was broadcast to lobby: %+v", event)
	default:
	}
}
