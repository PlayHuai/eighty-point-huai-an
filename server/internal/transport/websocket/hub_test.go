package websocket

import (
	"strconv"
	"testing"
	"time"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/chat"
)

func TestHubPublishesPrivateNotificationOnlyToParticipants(t *testing.T) {
	hub := NewHub()
	sender, err := hub.Subscribe("sender")
	if err != nil {
		t.Fatal(err)
	}
	defer sender.Close()
	recipient, err := hub.Subscribe("recipient")
	if err != nil {
		t.Fatal(err)
	}
	defer recipient.Close()
	unrelated, err := hub.Subscribe("unrelated")
	if err != nil {
		t.Fatal(err)
	}
	defer unrelated.Close()

	message := chat.Message{
		ID: "42", SenderID: "sender", RecipientID: "recipient",
		Body: "private body", CreatedAt: time.Unix(1, 0).UTC(),
	}
	hub.PublishPrivateMessage("sender", message)
	hub.PublishPrivateMessage("recipient", message)

	for _, test := range []struct {
		subscription *Subscription
		peerID       string
	}{
		{subscription: sender, peerID: "recipient"},
		{subscription: recipient, peerID: "sender"},
	} {
		select {
		case event := <-test.subscription.Events():
			if event.Type != "PRIVATE_MESSAGE_CREATED" || event.Sequence == 0 ||
				event.MessageID != message.ID || event.PeerUserID != test.peerID ||
				event.SenderUserID != message.SenderID || event.Body != message.Body {
				t.Fatalf("unexpected private event: %+v", event)
			}
		case <-time.After(time.Second):
			t.Fatal("participant did not receive notification")
		}
	}
	select {
	case event := <-unrelated.Events():
		t.Fatalf("unrelated user received private event: %+v", event)
	default:
	}
}

func TestHubPublishesRoomMessagesOnlyToProvidedMembers(t *testing.T) {
	hub := NewHub()
	member, _ := hub.Subscribe("member")
	defer member.Close()
	spectator, _ := hub.Subscribe("spectator")
	defer spectator.Close()
	outside, _ := hub.Subscribe("outside")
	defer outside.Close()

	hub.PublishRoomMessage([]string{"member", "spectator", "member"}, chat.Message{
		ID: "request-1", RoomID: "room-1", SenderID: "member",
		Body: "hello room", CreatedAt: time.Unix(1, 0).UTC(),
	})
	for _, subscription := range []*Subscription{member, spectator} {
		select {
		case event := <-subscription.Events():
			if event.Type != "ROOM_MESSAGE_CREATED" || event.RoomID != "room-1" ||
				event.MessageID != "request-1" || event.Body != "hello room" {
				t.Fatalf("unexpected room event: %+v", event)
			}
		case <-time.After(time.Second):
			t.Fatal("room member did not receive message")
		}
	}
	select {
	case event := <-outside.Events():
		t.Fatalf("non-member received room event: %+v", event)
	default:
	}
}

func TestHubBroadcastsLobbyUpdatesToConnectedUsers(t *testing.T) {
	hub := NewHub()
	first, _ := hub.SubscribeWithFriendsAndHalls("first", nil, []string{"ordinary"})
	defer first.Close()
	second, _ := hub.SubscribeWithFriendsAndHalls("second", nil, []string{"ordinary"})
	defer second.Close()
	hub.PublishLobbyUpdate("ordinary", "room-1", 3, []byte(`{"status":"WAITING"}`))
	for _, subscription := range []*Subscription{first, second} {
		select {
		case event := <-subscription.Events():
			if event.Type != "LOBBY_STATE_CHANGED" || event.EntityID != "room-1" ||
				event.Version != 3 || string(event.Payload) != `{"status":"WAITING"}` {
				t.Fatalf("unexpected lobby event: %+v", event)
			}
		case <-time.After(time.Second):
			t.Fatal("connected user did not receive lobby update")
		}
	}
}

func TestHubPublishesOnlineAndOfflineOnlyToFriends(t *testing.T) {
	hub := NewHub()
	friend, err := hub.SubscribeWithFriends("friend", []string{"user"})
	if err != nil {
		t.Fatal(err)
	}
	defer friend.Close()
	unrelated, err := hub.Subscribe("unrelated")
	if err != nil {
		t.Fatal(err)
	}
	defer unrelated.Close()

	user, err := hub.SubscribeWithFriends("user", []string{"friend"})
	if err != nil {
		t.Fatal(err)
	}
	assertPresence := func(wantOnline bool) {
		t.Helper()
		select {
		case event := <-friend.Events():
			if event.Type != "FRIEND_STATE_CHANGED" || event.EntityID != "user" ||
				string(event.Payload) != `{"online":`+strconv.FormatBool(wantOnline)+`}` {
				t.Fatalf("unexpected presence event: %+v", event)
			}
		case <-time.After(time.Second):
			t.Fatal("friend did not receive presence update")
		}
	}
	assertPresence(true)
	select {
	case event := <-unrelated.Events():
		t.Fatalf("unrelated user received presence: %+v", event)
	default:
	}
	user.Close()
	assertPresence(false)
}

func TestHubUpdatesFriendWatchersWhenFriendshipChanges(t *testing.T) {
	hub := NewHub()
	friend, _ := hub.Subscribe("friend")
	defer friend.Close()
	user, _ := hub.Subscribe("user")
	hub.SetFriendship("user", "friend", true)
	user.Close()
	select {
	case event := <-friend.Events():
		if string(event.Payload) != `{"online":false}` {
			t.Fatalf("friend state = %+v, want offline update", event)
		}
	case <-time.After(time.Second):
		t.Fatal("new friend did not receive subsequent presence update")
	}

	user, _ = hub.SubscribeWithFriends("user", []string{"friend"})
	select {
	case event := <-friend.Events():
		if string(event.Payload) != `{"online":true}` {
			t.Fatalf("friend state = %+v, want online update", event)
		}
	case <-time.After(time.Second):
		t.Fatal("friend did not receive subsequent online update")
	}
	hub.SetFriendship("user", "friend", false)
	user.Close()
	select {
	case event := <-friend.Events():
		t.Fatalf("removed friend received presence update: %+v", event)
	default:
	}
}

func TestHubSubscriptionCloseIsIdempotent(t *testing.T) {
	hub := NewHub()
	subscription, err := hub.Subscribe("user")
	if err != nil {
		t.Fatal(err)
	}
	subscription.Close()
	subscription.Close()
	hub.PublishPrivateMessage("user", chat.Message{
		ID: "1", SenderID: "user", RecipientID: "peer",
	})
	if _, open := <-subscription.Events(); open {
		t.Fatal("closed subscription remained open")
	}
}

func TestAccessTokenProtocolRequiresExactlyOneCredential(t *testing.T) {
	tests := []struct {
		name      string
		protocols []string
		wantToken string
		wantEvent bool
	}{
		{name: "valid", protocols: []string{"huai.events.v1, huai.auth.secret"}, wantToken: "secret", wantEvent: true},
		{name: "missing event", protocols: []string{"huai.auth.secret"}, wantToken: "secret"},
		{name: "missing token", protocols: []string{"huai.events.v1"}, wantEvent: true},
		{name: "duplicate token", protocols: []string{"huai.auth.first,huai.auth.second", "huai.events.v1"}},
		{name: "empty token", protocols: []string{"huai.auth.", "huai.events.v1"}},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			token, event := accessTokenFromProtocols(test.protocols)
			if token != test.wantToken || event != test.wantEvent {
				t.Fatalf("accessTokenFromProtocols() = (%q, %t), want (%q, %t)",
					token, event, test.wantToken, test.wantEvent)
			}
		})
	}
}
