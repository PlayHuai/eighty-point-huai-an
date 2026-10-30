package websocket

import (
	"context"
	"errors"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/lobby"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/player"
	xwebsocket "golang.org/x/net/websocket"
)

const (
	eventProtocol      = "huai.events.v1"
	authProtocolPrefix = "huai.auth."
)

type AccessAuthenticator interface {
	AuthenticateAccess(ctx context.Context, token string) (string, error)
}

type FriendResolver interface {
	ListFriendIDs(ctx context.Context, userID string) ([]string, error)
}

type LobbyProfileResolver interface {
	FindProfile(ctx context.Context, userID string) (player.Profile, error)
}

type LobbyAccountResolver interface {
	IsWeChatUser(ctx context.Context, userID string) (bool, error)
}

type requestContextKey struct{}

type connectionContext struct {
	userID       string
	subscription *Subscription
}

type Handler struct {
	hub            *Hub
	authenticator  AccessAuthenticator
	friends        FriendResolver
	profiles       LobbyProfileResolver
	accounts       LobbyAccountResolver
	allowedOrigins map[string]struct{}
}

func NewHandler(
	hub *Hub,
	authenticator AccessAuthenticator,
	allowedOrigins []string,
	friendResolvers ...FriendResolver,
) (*Handler, error) {
	if hub == nil || authenticator == nil {
		return nil, errors.New("event hub and access authenticator are required")
	}
	if len(friendResolvers) > 1 {
		return nil, errors.New("only one friend resolver is allowed")
	}
	origins := make(map[string]struct{}, len(allowedOrigins))
	for _, origin := range allowedOrigins {
		parsed, err := url.Parse(origin)
		if err != nil || parsed.Scheme == "" || parsed.Host == "" ||
			(parsed.Scheme != "https" && parsed.Scheme != "http") ||
			parsed.Path != "" || parsed.RawQuery != "" || parsed.Fragment != "" {
			return nil, errors.New("invalid WebSocket origin")
		}
		origins[parsed.Scheme+"://"+parsed.Host] = struct{}{}
	}
	handler := &Handler{hub: hub, authenticator: authenticator, allowedOrigins: origins}
	if len(friendResolvers) == 1 {
		handler.friends = friendResolvers[0]
	}
	return handler, nil
}

func NewHandlerWithLobbyProfiles(
	hub *Hub,
	authenticator AccessAuthenticator,
	allowedOrigins []string,
	friends FriendResolver,
	profiles LobbyProfileResolver,
	accounts LobbyAccountResolver,
) (*Handler, error) {
	if profiles == nil || accounts == nil {
		return nil, errors.New("lobby profile and account resolvers are required")
	}
	handler, err := NewHandler(hub, authenticator, allowedOrigins, friends)
	if err != nil {
		return nil, err
	}
	handler.profiles = profiles
	handler.accounts = accounts
	return handler, nil
}

func (h *Handler) ServeHTTP(writer http.ResponseWriter, request *http.Request) {
	if request.URL.RawQuery != "" {
		http.Error(writer, "query parameters are not accepted", http.StatusBadRequest)
		return
	}
	server := xwebsocket.Server{
		Handler:   h.serve,
		Handshake: h.handshake,
	}
	server.ServeHTTP(writer, request)
}

func (h *Handler) handshake(config *xwebsocket.Config, request *http.Request) error {
	if request.Method != http.MethodGet {
		return errors.New("WebSocket upgrade requires GET")
	}
	if origin := request.Header.Get("Origin"); origin != "" {
		parsed, err := url.Parse(origin)
		if err != nil || parsed.Scheme == "" || parsed.Host == "" {
			return errors.New("invalid origin")
		}
		if _, ok := h.allowedOrigins[parsed.Scheme+"://"+parsed.Host]; !ok {
			return errors.New("origin is not allowed")
		}
	}

	token, hasEventProtocol := accessTokenFromProtocols(request.Header.Values("Sec-WebSocket-Protocol"))
	if token == "" || !hasEventProtocol {
		return errors.New("authentication and event protocols are required")
	}
	ctx, cancel := context.WithTimeout(request.Context(), 5*time.Second)
	defer cancel()
	userID, err := h.authenticator.AuthenticateAccess(ctx, token)
	if err != nil || userID == "" {
		return errors.New("invalid or expired access token")
	}
	var friendIDs []string
	if h.friends != nil {
		friendIDs, err = h.friends.ListFriendIDs(ctx, userID)
		if err != nil {
			return errors.New("could not load friend connections")
		}
	}
	var hallIDs []string
	if h.profiles != nil {
		isWeChatUser, err := h.accounts.IsWeChatUser(ctx, userID)
		if err != nil {
			return errors.New("could not determine account type")
		}
		profile, err := h.profiles.FindProfile(ctx, userID)
		if err != nil {
			return errors.New("could not load player profile")
		}
		for _, hall := range lobby.Halls() {
			if (hall.ID == lobby.HallEntertainment) == isWeChatUser &&
				lobby.CanEnter(profile.Points, hall.ID) {
				hallIDs = append(hallIDs, hall.ID)
			}
		}
	}
	subscription, err := h.hub.SubscribeWithFriendsAndHalls(userID, friendIDs, hallIDs)
	if err != nil {
		return err
	}
	*request = *request.WithContext(context.WithValue(request.Context(), requestContextKey{}, connectionContext{
		userID: userID, subscription: subscription,
	}))
	config.Protocol = []string{eventProtocol}
	return nil
}

func accessTokenFromProtocols(values []string) (string, bool) {
	var token string
	hasEventProtocol := false
	for _, value := range values {
		for _, protocol := range strings.Split(value, ",") {
			protocol = strings.TrimSpace(protocol)
			switch {
			case protocol == eventProtocol:
				if hasEventProtocol {
					return "", false
				}
				hasEventProtocol = true
			case strings.HasPrefix(protocol, authProtocolPrefix):
				if token != "" {
					return "", false
				}
				token = strings.TrimPrefix(protocol, authProtocolPrefix)
				if token == "" || strings.ContainsAny(token, " \t\r\n,") {
					return "", false
				}
			}
		}
	}
	return token, hasEventProtocol
}

func (h *Handler) serve(connection *xwebsocket.Conn) {
	state, ok := connection.Request().Context().Value(requestContextKey{}).(connectionContext)
	if !ok || state.subscription == nil {
		_ = connection.Close()
		return
	}
	defer state.subscription.Close()
	connection.MaxPayloadBytes = 1024
	readDone := make(chan struct{})
	go func() {
		defer close(readDone)
		var payload []byte
		for {
			if err := xwebsocket.Message.Receive(connection, &payload); err != nil {
				return
			}
		}
	}()
	for {
		select {
		case event, open := <-state.subscription.Events():
			if !open {
				return
			}
			if err := connection.SetWriteDeadline(time.Now().Add(10 * time.Second)); err != nil {
				return
			}
			if err := xwebsocket.JSON.Send(connection, event); err != nil {
				return
			}
		case <-readDone:
			return
		}
	}
}
