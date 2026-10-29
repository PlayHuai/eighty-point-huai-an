package websocket

import (
	"context"
	"errors"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/chat"
	xwebsocket "golang.org/x/net/websocket"
)

type testAuthenticator struct {
	userID string
}

func (a testAuthenticator) AuthenticateAccess(_ context.Context, token string) (string, error) {
	if token != "access-token" {
		return "", errors.New("invalid token")
	}
	return a.userID, nil
}

func TestHandlerAuthenticatesAndStreamsPrivateNotifications(t *testing.T) {
	hub := NewHub()
	handler, err := NewHandler(hub, testAuthenticator{userID: "recipient"}, []string{"https://client.example"})
	if err != nil {
		t.Fatal(err)
	}
	server := httptest.NewServer(handler)
	defer server.Close()

	config, err := xwebsocket.NewConfig(
		"ws"+strings.TrimPrefix(server.URL, "http"),
		"https://client.example",
	)
	if err != nil {
		t.Fatal(err)
	}
	config.Protocol = []string{eventProtocol, authProtocolPrefix + "access-token"}
	connection, err := xwebsocket.DialConfig(config)
	if err != nil {
		t.Fatalf("DialConfig() error = %v", err)
	}
	defer connection.Close()

	hub.PublishPrivateMessage("recipient", chat.Message{
		ID: "17", SenderID: "sender", RecipientID: "recipient",
		Body: "private body", CreatedAt: time.Unix(1, 0).UTC(),
	})
	var event Event
	if err := xwebsocket.JSON.Receive(connection, &event); err != nil {
		t.Fatalf("read event: %v", err)
	}
	if event.Type != "PRIVATE_MESSAGE_CREATED" || event.Sequence != 17 ||
		event.SenderUserID != "sender" || event.PeerUserID != "sender" {
		t.Fatalf("unexpected event: %+v", event)
	}
}

func TestHandlerRejectsInvalidAuthenticationAndOrigin(t *testing.T) {
	handler, err := NewHandler(NewHub(), testAuthenticator{userID: "recipient"}, []string{"https://client.example"})
	if err != nil {
		t.Fatal(err)
	}
	server := httptest.NewServer(handler)
	defer server.Close()

	for _, test := range []struct {
		name   string
		origin string
		token  string
	}{
		{name: "invalid token", origin: "https://client.example", token: "invalid"},
		{name: "untrusted origin", origin: "https://attacker.example", token: "access-token"},
	} {
		t.Run(test.name, func(t *testing.T) {
			config, err := xwebsocket.NewConfig(
				"ws"+strings.TrimPrefix(server.URL, "http"),
				test.origin,
			)
			if err != nil {
				t.Fatal(err)
			}
			config.Protocol = []string{eventProtocol, authProtocolPrefix + test.token}
			if connection, err := xwebsocket.DialConfig(config); err == nil {
				_ = connection.Close()
				t.Fatal("websocket connection succeeded for rejected credentials")
			}
		})
	}
}
