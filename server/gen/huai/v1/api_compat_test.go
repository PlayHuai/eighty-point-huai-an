package huaiv1

import (
	"bytes"
	"encoding/hex"
	"testing"

	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
)

func TestVersionedServiceContract(t *testing.T) {
	services := File_huai_v1_api_proto.Services()
	want := map[string][]string{
		"AuthService":   {"Register", "Login", "RefreshSession", "Logout", "ChangePassword"},
		"PlayerService": {"GetProfile", "UpdateProfile", "GetStatistics", "ListRecentResults"},
		"LobbyService":  {"ListHalls", "ListRooms", "CreateRoom", "JoinRoom", "LeaveRoom", "JoinByCode"},
		"RoomService":   {"GetRoom", "SitDown", "ChangeSeat", "StandUp", "InviteFriend", "SetSpectatorView", "SetHandVisibility", "StartGame"},
		"GameService":   {"SubmitAction", "GetGameSnapshot", "ListEventsAfter", "RequestReconnect"},
		"FriendService": {"SearchPlayers", "SendRequest", "RespondRequest", "ListFriends", "RemoveFriend", "SendRoomInvite", "ListFriendRequests", "ListRoomInvitations"},
		"ChatService":   {"SendRoomMessage", "ListRoomMessages", "SendPrivateMessage", "ListPrivateMessages"},
		"ConfigService": {"GetPublicConfig"},
	}
	if got := services.Len(); got != len(want) {
		t.Fatalf("service count = %d, want %d", got, len(want))
	}
	for serviceName, methodNames := range want {
		service := services.ByName(protoreflect.Name(serviceName))
		if service == nil {
			t.Errorf("%s is missing from huai.v1", serviceName)
			continue
		}
		if got := service.Methods().Len(); got != len(methodNames) {
			t.Errorf("%s method count = %d, want %d", serviceName, got, len(methodNames))
		}
		for _, methodName := range methodNames {
			if service.Methods().ByName(protoreflect.Name(methodName)) == nil {
				t.Errorf("%s.%s is missing", serviceName, methodName)
			}
		}
	}
}

func TestSubmitActionWireCompatibility(t *testing.T) {
	message := &SubmitActionRequest{
		GameSessionId:   "g",
		HandId:          "h",
		RequestId:       "r",
		ExpectedVersion: 7,
		Action: &GameAction{
			Payload: &GameAction_PlayCards{
				PlayCards: &PlayCardsAction{Cards: []string{"AS"}},
			},
		},
	}

	encoded, err := proto.Marshal(message)
	if err != nil {
		t.Fatalf("marshal SubmitActionRequest: %v", err)
	}

	const flutterWireFixture = "0a01671201681a017220072a062a040a024153"
	want, err := hex.DecodeString(flutterWireFixture)
	if err != nil {
		t.Fatal(err)
	}
	if !bytes.Equal(encoded, want) {
		t.Fatalf("wire encoding = %x, want %x", encoded, want)
	}

	decoded := new(SubmitActionRequest)
	if err := proto.Unmarshal(want, decoded); err != nil {
		t.Fatalf("unmarshal shared Flutter wire fixture: %v", err)
	}
	if !proto.Equal(message, decoded) {
		t.Fatalf("round trip = %v, want %v", decoded, message)
	}
}

func TestSubmitActionFieldNumbers(t *testing.T) {
	fields := (&SubmitActionRequest{}).ProtoReflect().Descriptor().Fields()
	for name, want := range map[string]protoreflect.FieldNumber{
		"game_session_id":  1,
		"hand_id":          2,
		"request_id":       3,
		"expected_version": 4,
		"action":           5,
	} {
		field := fields.ByName(protoreflect.Name(name))
		if field == nil {
			t.Errorf("SubmitActionRequest.%s is missing", name)
		} else if field.Number() != want {
			t.Errorf("SubmitActionRequest.%s field number = %d, want %d", name, field.Number(), want)
		}
	}
}

func TestRoomSummaryVersionFieldNumber(t *testing.T) {
	fields := (&RoomSummary{}).ProtoReflect().Descriptor().Fields()
	field := fields.ByName("version")
	if field == nil {
		t.Fatal("RoomSummary.version is missing")
	}
	if got, want := field.Number(), protoreflect.FieldNumber(8); got != want {
		t.Fatalf("RoomSummary.version field number = %d, want %d", got, want)
	}
}
