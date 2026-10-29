package websocket

import (
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
			if event.Type != "PRIVATE_MESSAGE_CREATED" || event.Sequence != 42 ||
				event.MessageID != message.ID || event.PeerUserID != test.peerID ||
				event.SenderUserID != message.SenderID {
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
