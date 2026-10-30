package miniprogram

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/auth"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/lobby"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/player"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
)

type testIdentity struct {
	loginResult auth.Result
	wechatUsers map[string]bool
	openID      string
	loginCalls  int
}

func (i *testIdentity) LoginWithWeChatOpenID(_ context.Context, openID string) (auth.Result, error) {
	i.openID = openID
	i.loginCalls++
	i.loginResult.Profile = auth.Profile{UserID: "wechat-player", Nickname: "微信用户"}
	return i.loginResult, nil
}

func (i *testIdentity) IsWeChatUser(_ context.Context, userID string) (bool, error) {
	return i.wechatUsers[userID], nil
}

type testAuthenticator struct{}

func (testAuthenticator) AuthenticateAccess(_ context.Context, token string) (string, error) {
	switch token {
	case "wechat-token":
		return "wechat-player", nil
	case "regular-token":
		return "regular-player", nil
	default:
		return "", auth.ErrUnauthenticated
	}
}

type testProfiles struct{}

func (testProfiles) FindProfile(_ context.Context, userID string) (player.Profile, error) {
	return player.Profile{UserID: userID, Rank: "青铜"}, nil
}

func (testProfiles) SaveProfile(context.Context, player.Profile) error { return nil }

type testCodeExchanger struct {
	openID string
	err    error
	code   string
}

func (e *testCodeExchanger) CodeToOpenID(_ context.Context, code string) (string, error) {
	e.code = code
	return e.openID, e.err
}

func testHandler(t *testing.T, rooms *room.Manager, identity *testIdentity, exchanger WeChatCodeExchanger) *Handler {
	t.Helper()
	handler, err := NewHandler(testAuthenticator{}, identity, testProfiles{}, rooms, exchanger)
	if err != nil {
		t.Fatal(err)
	}
	return handler
}

func TestWeChatLoginExchangesCodeWithoutProfileData(t *testing.T) {
	identity := &testIdentity{loginResult: auth.Result{
		AccessToken: "access-token",
		Profile:     auth.Profile{UserID: "wechat-player", Nickname: "微信用户"},
	}}
	exchanger := &testCodeExchanger{openID: "trusted-open-id"}
	handler := testHandler(t, room.NewManager(), identity, exchanger)
	request := httptest.NewRequest(http.MethodPost, "/api/auth/wx-login",
		stringsReader(`{"code":"temporary-code","clientType":"miniprogram"}`))
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)
	var body map[string]any
	if err := json.Unmarshal(response.Body.Bytes(), &body); err != nil {
		t.Fatal(err)
	}
	if response.Code != http.StatusOK || exchanger.code != "temporary-code" ||
		identity.openID != "trusted-open-id" || identity.loginCalls != 1 ||
		body["token"] != "access-token" || body["userId"] != "wechat-player" {
		t.Fatalf("login response=%v status=%d exchanger=%+v identity=%+v",
			body, response.Code, exchanger, identity)
	}
	if _, exists := body["openid"]; exists {
		t.Fatal("login response exposed the WeChat OpenID")
	}
	if _, exists := body["avatar"]; exists {
		t.Fatal("login response exposed profile fields")
	}
}

func TestEntertainmentHallEndpointsAreWeChatOnlyAndFiltered(t *testing.T) {
	rooms := room.NewManager()
	entertainment, err := rooms.CreateRoom(lobby.HallEntertainment, "wechat-player", 0, room.Settings{Name: "娱乐房"})
	if err != nil {
		t.Fatal(err)
	}
	ordinary, err := rooms.CreateRoom(lobby.HallOrdinary, "regular-player", 0, room.Settings{Name: "普通房"})
	if err != nil {
		t.Fatal(err)
	}
	identity := &testIdentity{wechatUsers: map[string]bool{"wechat-player": true}}
	handler := testHandler(t, rooms, identity, nil)

	hallsRequest := authenticatedRequest(http.MethodGet, "/api/lobby/halls", "", "wechat-token")
	hallsResponse := httptest.NewRecorder()
	handler.ServeHTTP(hallsResponse, hallsRequest)
	var halls struct {
		Halls []struct {
			HallID string `json:"hallId"`
			Name   string `json:"name"`
		} `json:"halls"`
	}
	if err := json.Unmarshal(hallsResponse.Body.Bytes(), &halls); err != nil {
		t.Fatal(err)
	}
	if hallsResponse.Code != http.StatusOK || len(halls.Halls) != 1 ||
		halls.Halls[0].HallID != lobby.HallEntertainment {
		t.Fatalf("WeChat halls = %+v, status %d", halls, hallsResponse.Code)
	}

	listRequest := authenticatedRequest(http.MethodGet,
		"/api/lobby/rooms?hallId=entertainment", "", "wechat-token")
	listResponse := httptest.NewRecorder()
	handler.ServeHTTP(listResponse, listRequest)
	var listed struct {
		HallID string      `json:"hallId"`
		Rooms  []roomEntry `json:"rooms"`
	}
	if err := json.Unmarshal(listResponse.Body.Bytes(), &listed); err != nil {
		t.Fatal(err)
	}
	if listResponse.Code != http.StatusOK || listed.HallID != lobby.HallEntertainment ||
		len(listed.Rooms) != 1 || listed.Rooms[0].RoomID != entertainment.Room.ID {
		t.Fatalf("WeChat room list = %+v, status %d", listed, listResponse.Code)
	}

	regularRequest := authenticatedRequest(http.MethodGet, "/api/lobby/halls", "", "regular-token")
	regularResponse := httptest.NewRecorder()
	handler.ServeHTTP(regularResponse, regularRequest)
	if regularResponse.Code != http.StatusForbidden {
		t.Fatalf("regular account status = %d, want forbidden", regularResponse.Code)
	}

	joinRequest := authenticatedRequest(http.MethodPost, "/api/lobby/joinRoom",
		`{"roomId":"`+ordinary.Room.ID+`","expectedVersion":1}`, "wechat-token")
	joinResponse := httptest.NewRecorder()
	handler.ServeHTTP(joinResponse, joinRequest)
	if joinResponse.Code != http.StatusNotFound {
		t.Fatalf("joining non-entertainment room status = %d, want not found", joinResponse.Code)
	}

	joinRequest = authenticatedRequest(http.MethodPost, "/api/lobby/joinRoom",
		`{"roomId":"`+entertainment.Room.ID+`","expectedVersion":1}`, "wechat-token")
	joinResponse = httptest.NewRecorder()
	handler.ServeHTTP(joinResponse, joinRequest)
	var joined roomEntry
	if err := json.Unmarshal(joinResponse.Body.Bytes(), &joined); err != nil {
		t.Fatal(err)
	}
	if joinResponse.Code != http.StatusOK || joined.Seat == 0 || joined.RoomID != entertainment.Room.ID {
		t.Fatalf("joining entertainment room = %+v, status %d", joined, joinResponse.Code)
	}
}

func TestCreateEntertainmentRoomReplaysRequestID(t *testing.T) {
	rooms := room.NewManager()
	identity := &testIdentity{wechatUsers: map[string]bool{"wechat-player": true}}
	handler := testHandler(t, rooms, identity, nil)
	var first roomEntry
	for index := 0; index < 2; index++ {
		request := authenticatedRequest(http.MethodPost, "/api/lobby/createRoom",
			`{"requestId":"create-once"}`, "wechat-token")
		response := httptest.NewRecorder()
		handler.ServeHTTP(response, request)
		if err := json.Unmarshal(response.Body.Bytes(), &first); err != nil {
			t.Fatal(err)
		}
		if response.Code != http.StatusOK || first.Seat == 0 {
			t.Fatalf("create room response=%+v status=%d", first, response.Code)
		}
	}
	listed, err := rooms.ListRooms(lobby.HallEntertainment, 0)
	if err != nil || len(listed) != 1 || listed[0].ID != first.RoomID {
		t.Fatalf("created rooms = %+v, %v; want one room %q", listed, err, first.RoomID)
	}
}

func TestWeChatCodeExchangeUsesServerCredentialsAndValidatesResponse(t *testing.T) {
	server := httptest.NewTLSServer(http.HandlerFunc(func(writer http.ResponseWriter, request *http.Request) {
		values := request.URL.Query()
		if values.Get("appid") != "test-app" || values.Get("secret") != "server-secret" ||
			values.Get("js_code") != "wx-code" || values.Get("grant_type") != "authorization_code" {
			t.Errorf("unexpected WeChat exchange query: %v", values)
		}
		_, _ = writer.Write([]byte(`{"openid":"verified-open-id","session_key":"not-forwarded"}`))
	}))
	defer server.Close()
	exchanger := &WeChatCodeExchange{
		AppID: "test-app", AppSecret: "server-secret", Endpoint: server.URL, Client: server.Client(),
	}
	openID, err := exchanger.CodeToOpenID(context.Background(), "wx-code")
	if err != nil || openID != "verified-open-id" {
		t.Fatalf("CodeToOpenID() = %q, %v", openID, err)
	}

	exchanger.Endpoint = "http://" + strings.TrimPrefix(server.URL, "https://")
	if _, err := exchanger.CodeToOpenID(context.Background(), "wx-code"); err == nil {
		t.Fatal("insecure WeChat endpoint was accepted")
	}
	if _, err := exchanger.CodeToOpenID(context.Background(), "bad\ncode"); err == nil {
		t.Fatal("invalid WeChat code was accepted")
	}
}

func authenticatedRequest(method, path, body, token string) *http.Request {
	request := httptest.NewRequest(method, path, stringsReader(body))
	request.Header.Set("Authorization", "Bearer "+token)
	return request
}

func stringsReader(value string) *strings.Reader {
	return strings.NewReader(value)
}
