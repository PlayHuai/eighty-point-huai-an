package miniprogram

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/auth"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/lobby"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/player"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
)

type AccessAuthenticator interface {
	AuthenticateAccess(context.Context, string) (string, error)
}

type WeChatIdentity interface {
	LoginWithWeChatOpenID(context.Context, string) (auth.Result, error)
	IsWeChatUser(context.Context, string) (bool, error)
}

type ProfileRepository interface {
	player.ProfileRepository
}

type WeChatCodeExchanger interface {
	CodeToOpenID(context.Context, string) (string, error)
}

type Handler struct {
	authenticator AccessAuthenticator
	identity      WeChatIdentity
	profiles      ProfileRepository
	rooms         *room.Manager
	exchanger     WeChatCodeExchanger

	createMu    sync.Mutex
	createdRoom map[string]roomEntry
}

type WeChatCodeExchange struct {
	AppID     string
	AppSecret string
	Endpoint  string
	Client    *http.Client
}

type wxSessionResponse struct {
	OpenID  string `json:"openid"`
	ErrCode int    `json:"errcode"`
	ErrMsg  string `json:"errmsg"`
}

type roomEntry struct {
	RoomID    string       `json:"roomId"`
	Name      string       `json:"name"`
	Status    room.Status  `json:"status"`
	Occupied  uint32       `json:"occupiedSeats"`
	Capacity  uint32       `json:"capacity"`
	Version   uint64       `json:"version"`
	Seat      uint32       `json:"seat,omitempty"`
	BaseScore int64        `json:"baseScore"`
	Members   []roomMember `json:"members,omitempty"`
}

type roomMember struct {
	UserID string `json:"userId"`
	Seat   uint32 `json:"seat"`
}

func NewHandler(
	authenticator AccessAuthenticator,
	identity WeChatIdentity,
	profiles ProfileRepository,
	rooms *room.Manager,
	exchanger WeChatCodeExchanger,
) (*Handler, error) {
	if authenticator == nil || identity == nil || profiles == nil || rooms == nil {
		return nil, errors.New("mini-program authentication, identity, profiles, and rooms are required")
	}
	return &Handler{
		authenticator: authenticator, identity: identity, profiles: profiles,
		rooms: rooms, exchanger: exchanger, createdRoom: make(map[string]roomEntry),
	}, nil
}

func NewWeChatCodeExchangerFromEnv() WeChatCodeExchanger {
	return &WeChatCodeExchange{
		AppID: os.Getenv("WECHAT_APP_ID"), AppSecret: os.Getenv("WECHAT_APP_SECRET"),
		Endpoint: "https://api.weixin.qq.com/sns/jscode2session",
		Client:   &http.Client{Timeout: 5 * time.Second},
	}
}

func (e *WeChatCodeExchange) CodeToOpenID(ctx context.Context, code string) (string, error) {
	if e == nil || e.AppID == "" || e.AppSecret == "" || e.Endpoint == "" {
		return "", errors.New("WeChat mini-program credentials are not configured")
	}
	if code == "" || len(code) > 256 || strings.ContainsAny(code, "\x00\r\n") {
		return "", errors.New("invalid WeChat login code")
	}
	endpoint, err := url.Parse(e.Endpoint)
	if err != nil || endpoint.Scheme != "https" || endpoint.Host == "" {
		return "", errors.New("invalid WeChat session endpoint")
	}
	query := endpoint.Query()
	query.Set("appid", e.AppID)
	query.Set("secret", e.AppSecret)
	query.Set("js_code", code)
	query.Set("grant_type", "authorization_code")
	endpoint.RawQuery = query.Encode()
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint.String(), nil)
	if err != nil {
		return "", fmt.Errorf("create WeChat session request: %w", err)
	}
	client := e.Client
	if client == nil {
		client = &http.Client{Timeout: 5 * time.Second}
	}
	response, err := client.Do(request)
	if err != nil {
		return "", fmt.Errorf("exchange WeChat login code: %w", err)
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		return "", fmt.Errorf("WeChat session endpoint returned HTTP %d", response.StatusCode)
	}
	var result wxSessionResponse
	if err := json.NewDecoder(io.LimitReader(response.Body, 1<<20)).Decode(&result); err != nil {
		return "", fmt.Errorf("decode WeChat session response: %w", err)
	}
	if result.ErrCode != 0 || result.OpenID == "" {
		return "", errors.New("WeChat rejected the login code")
	}
	return result.OpenID, nil
}

func (h *Handler) ServeHTTP(writer http.ResponseWriter, request *http.Request) {
	writer.Header().Set("Cache-Control", "no-store")
	switch request.URL.Path {
	case "/api/auth/wx-login":
		if request.Method != http.MethodPost {
			methodNotAllowed(writer)
			return
		}
		h.weChatLogin(writer, request)
	case "/api/lobby/halls":
		if request.Method != http.MethodGet {
			methodNotAllowed(writer)
			return
		}
		userID, ok := h.authorizedWeChatUser(writer, request)
		if !ok {
			return
		}
		writeJSON(writer, http.StatusOK, map[string]any{
			"halls":  []lobby.Hall{hallDefinition()},
			"userId": userID,
		})
	case "/api/lobby/rooms":
		if request.Method != http.MethodGet {
			methodNotAllowed(writer)
			return
		}
		userID, ok := h.authorizedWeChatUser(writer, request)
		if !ok {
			return
		}
		h.listRooms(writer, request, userID)
	case "/api/lobby/joinRoom":
		if request.Method != http.MethodPost {
			methodNotAllowed(writer)
			return
		}
		userID, ok := h.authorizedWeChatUser(writer, request)
		if !ok {
			return
		}
		h.joinRoom(writer, request, userID)
	case "/api/lobby/createRoom":
		if request.Method != http.MethodPost {
			methodNotAllowed(writer)
			return
		}
		userID, ok := h.authorizedWeChatUser(writer, request)
		if !ok {
			return
		}
		h.createRoom(writer, request, userID)
	default:
		http.NotFound(writer, request)
	}
}

func (h *Handler) weChatLogin(writer http.ResponseWriter, request *http.Request) {
	if h.exchanger == nil {
		writeError(writer, http.StatusServiceUnavailable, "WeChat login is not configured")
		return
	}
	var input struct {
		Code       string `json:"code"`
		ClientType string `json:"clientType"`
	}
	if !decodeJSON(writer, request, &input) || input.ClientType != "miniprogram" {
		writeError(writer, http.StatusBadRequest, "invalid WeChat login request")
		return
	}
	openID, err := h.exchanger.CodeToOpenID(request.Context(), input.Code)
	if err != nil {
		writeError(writer, http.StatusUnauthorized, "WeChat login failed")
		return
	}
	result, err := h.identity.LoginWithWeChatOpenID(request.Context(), openID)
	if err != nil {
		if errors.Is(err, auth.ErrInvalidInput) {
			writeError(writer, http.StatusBadRequest, "invalid WeChat identity")
		} else {
			writeError(writer, http.StatusInternalServerError, "WeChat login failed")
		}
		return
	}
	writeJSON(writer, http.StatusOK, map[string]string{
		"token": result.AccessToken, "userId": result.Profile.UserID,
	})
}

func (h *Handler) authorizedWeChatUser(writer http.ResponseWriter, request *http.Request) (string, bool) {
	values := request.Header.Values("Authorization")
	if len(values) != 1 {
		writeError(writer, http.StatusUnauthorized, "authentication required")
		return "", false
	}
	scheme, token, found := strings.Cut(values[0], " ")
	if !found || !strings.EqualFold(scheme, "Bearer") || token == "" ||
		strings.ContainsAny(token, " \t\r\n") {
		writeError(writer, http.StatusUnauthorized, "invalid authentication")
		return "", false
	}
	userID, err := h.authenticator.AuthenticateAccess(request.Context(), token)
	if err != nil || userID == "" {
		writeError(writer, http.StatusUnauthorized, "invalid or expired access token")
		return "", false
	}
	isWeChat, err := h.identity.IsWeChatUser(request.Context(), userID)
	if err != nil {
		writeError(writer, http.StatusInternalServerError, "could not determine account type")
		return "", false
	}
	if !isWeChat {
		writeError(writer, http.StatusForbidden, "entertainment hall is only available to WeChat accounts")
		return "", false
	}
	return userID, true
}

func (h *Handler) listRooms(writer http.ResponseWriter, request *http.Request, userID string) {
	if hallID := request.URL.Query().Get("hallId"); hallID != lobby.HallEntertainment {
		writeError(writer, http.StatusBadRequest, "only the entertainment hall is available")
		return
	}
	pageSize := uint64(20)
	if raw := request.URL.Query().Get("pageSize"); raw != "" {
		parsed, err := strconv.ParseUint(raw, 10, 32)
		if err != nil || parsed == 0 || parsed > 100 {
			writeError(writer, http.StatusBadRequest, "invalid page size")
			return
		}
		pageSize = parsed
	}
	profile, err := h.profiles.FindProfile(request.Context(), userID)
	if err != nil {
		writeError(writer, http.StatusInternalServerError, "could not load player profile")
		return
	}
	rooms, hasMore, err := h.rooms.ListRoomsPage(
		lobby.HallEntertainment, profile.Points, request.URL.Query().Get("pageToken"), uint32(pageSize),
	)
	if err != nil {
		writeError(writer, http.StatusInternalServerError, "could not list entertainment rooms")
		return
	}
	result := make([]roomEntry, 0, len(rooms))
	for _, summary := range rooms {
		result = append(result, roomEntry{
			RoomID: summary.ID, Name: summary.Name, Status: summary.Status,
			Occupied: summary.OccupiedSeats, Capacity: summary.Capacity, Version: summary.Version,
		})
	}
	nextPageToken := ""
	if hasMore && len(rooms) != 0 {
		nextPageToken = rooms[len(rooms)-1].ID
	}
	writeJSON(writer, http.StatusOK, map[string]any{
		"hallId": lobby.HallEntertainment, "rooms": result, "nextPageToken": nextPageToken,
	})
}

func (h *Handler) joinRoom(writer http.ResponseWriter, request *http.Request, userID string) {
	var input struct {
		RoomID          string `json:"roomId"`
		ExpectedVersion uint64 `json:"expectedVersion"`
	}
	if !decodeJSON(writer, request, &input) || input.RoomID == "" {
		writeError(writer, http.StatusBadRequest, "room ID is required")
		return
	}
	summary, err := h.rooms.GetSummary(input.RoomID)
	if err != nil || summary.HallID != lobby.HallEntertainment {
		writeError(writer, http.StatusNotFound, "entertainment room not found")
		return
	}
	if details, err := h.rooms.GetRoom(input.RoomID, userID); err == nil {
		writeJSON(writer, http.StatusOK, entryFromDetails(details, userID))
		return
	}
	profile, err := h.profiles.FindProfile(request.Context(), userID)
	if err != nil {
		writeError(writer, http.StatusInternalServerError, "could not load player profile")
		return
	}
	details, err := h.rooms.JoinRoom(
		input.RoomID, userID, profile.Points, "", input.ExpectedVersion,
	)
	if errors.Is(err, room.ErrAlreadyMember) {
		details, err = h.rooms.GetRoom(input.RoomID, userID)
	}
	if err != nil {
		writeError(writer, roomHTTPStatus(err), "could not join entertainment room")
		return
	}
	writeJSON(writer, http.StatusOK, entryFromDetails(details, userID))
}

func (h *Handler) createRoom(writer http.ResponseWriter, request *http.Request, userID string) {
	var input struct {
		RequestID string `json:"requestId"`
	}
	if !decodeJSON(writer, request, &input) || !validRequestID(input.RequestID) {
		writeError(writer, http.StatusBadRequest, "valid request ID is required")
		return
	}
	cacheKey := userID + ":" + input.RequestID
	h.createMu.Lock()
	defer h.createMu.Unlock()
	if previous, ok := h.createdRoom[cacheKey]; ok {
		writeJSON(writer, http.StatusOK, previous)
		return
	}
	if len(h.createdRoom) >= 4096 {
		writeError(writer, http.StatusTooManyRequests, "too many room creation requests")
		return
	}
	profile, err := h.profiles.FindProfile(request.Context(), userID)
	if err != nil {
		writeError(writer, http.StatusInternalServerError, "could not load player profile")
		return
	}
	details, err := h.rooms.CreateRoom(lobby.HallEntertainment, userID, profile.Points, room.Settings{
		Name: "娱乐房间",
	})
	if err != nil {
		writeError(writer, http.StatusInternalServerError, "could not create entertainment room")
		return
	}
	details, err = h.rooms.JoinRoom(details.Room.ID, userID, profile.Points, "", details.Version)
	if err != nil {
		writeError(writer, http.StatusInternalServerError, "could not enter created room")
		return
	}
	result := entryFromDetails(details, userID)
	h.createdRoom[cacheKey] = result
	writeJSON(writer, http.StatusOK, result)
}

func entryFromDetails(details room.Details, userID string) roomEntry {
	entry := roomEntry{
		RoomID: details.Room.ID, Name: details.Room.Name, Status: details.Room.Status,
		Occupied: details.Room.OccupiedSeats, Capacity: details.Room.Capacity,
		Version: details.Version, Members: make([]roomMember, 0, len(details.Members)),
	}
	for _, member := range details.Members {
		entry.Members = append(entry.Members, roomMember{UserID: member.UserID, Seat: member.Seat})
		if member.UserID == userID {
			entry.Seat = member.Seat
		}
	}
	return entry
}

func hallDefinition() lobby.Hall {
	hall, _ := lobby.FindHall(lobby.HallEntertainment)
	return hall
}

func validRequestID(value string) bool {
	if value == "" || len(value) > 128 {
		return false
	}
	for _, character := range value {
		if character < 0x21 || character > 0x7e {
			return false
		}
	}
	return true
}

func roomHTTPStatus(err error) int {
	switch {
	case errors.Is(err, room.ErrRoomNotFound):
		return http.StatusNotFound
	case errors.Is(err, room.ErrVersionConflict):
		return http.StatusConflict
	case errors.Is(err, room.ErrRoomFull), errors.Is(err, room.ErrRoomStarted),
		errors.Is(err, room.ErrRoomClosed), errors.Is(err, room.ErrRoomNotReady):
		return http.StatusConflict
	case errors.Is(err, room.ErrAdmissionDenied), errors.Is(err, room.ErrInvitationRequired):
		return http.StatusForbidden
	default:
		return http.StatusInternalServerError
	}
}

func decodeJSON(writer http.ResponseWriter, request *http.Request, destination any) bool {
	request.Body = http.MaxBytesReader(writer, request.Body, 1<<20)
	decoder := json.NewDecoder(request.Body)
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(destination); err != nil {
		writeError(writer, http.StatusBadRequest, "invalid JSON request")
		return false
	}
	var trailing any
	if err := decoder.Decode(&trailing); !errors.Is(err, io.EOF) {
		writeError(writer, http.StatusBadRequest, "request must contain one JSON object")
		return false
	}
	return true
}

func methodNotAllowed(writer http.ResponseWriter) {
	writeError(writer, http.StatusMethodNotAllowed, "method not allowed")
}

func writeError(writer http.ResponseWriter, statusCode int, message string) {
	writeJSON(writer, statusCode, map[string]string{"error": message})
}

func writeJSON(writer http.ResponseWriter, statusCode int, value any) {
	writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	writer.WriteHeader(statusCode)
	_ = json.NewEncoder(writer).Encode(value)
}
