package grpc

import (
	"context"
	"testing"
	"time"

	huaiv1 "github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/runtime"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func TestRoomTimingDefaultsValidationAndRetryIdentity(t *testing.T) {
	server := &lobbyServer{rooms: room.NewManager(), profiles: lobbyProfiles{}}
	ctx := ctxWithUserID(context.Background(), "owner")
	request := &huaiv1.CreateRoomRequest{HallId: "ordinary", Name: "paced", RequestId: "11111111-1111-4111-8111-111111111111"}
	created, err := server.CreateRoom(ctx, request)
	if err != nil {
		t.Fatal(err)
	}
	if created.DealIntervalMs != 200 || created.CounterWindowMs != 10000 {
		t.Fatal("wrong timing defaults")
	}
	deal, counter := uint32(125), uint32(12500)
	request.RequestId = "22222222-2222-4222-8222-222222222222"
	request.DealIntervalMs, request.CounterWindowMs = &deal, &counter
	created, err = server.CreateRoom(ctx, request)
	if err != nil || created.GetDealIntervalMs() != 125 || created.GetCounterWindowMs() != 12500 {
		t.Fatalf("%+v %v", created, err)
	}
	repeated, err := server.CreateRoom(ctx, request)
	if err != nil || repeated.RoomId != created.RoomId {
		t.Fatal("identical retry changed room")
	}
	deal = 126
	if _, err := server.CreateRoom(ctx, request); status.Code(err) != codes.AlreadyExists {
		t.Fatalf("changed timing reused request ID: %v", err)
	}
	deal = 0
	request.RequestId = "33333333-3333-4333-8333-333333333333"
	if _, err := server.CreateRoom(ctx, request); status.Code(err) != codes.InvalidArgument {
		t.Fatalf("zero interval accepted: %v", err)
	}
	deal, counter = 200, 0
	if _, err := server.CreateRoom(ctx, request); status.Code(err) != codes.InvalidArgument {
		t.Fatalf("zero window accepted: %v", err)
	}
}

func TestSnapshotProjectsAuthoritativeTrickAndServerClock(t *testing.T) {
	view := runtime.Snapshot{
		ID: "game", Phase: runtime.Playing, HandNumber: 2, Turn: 1, Dealer: 0,
		Players: [4]string{"a", "b", "c", "d"}, Deadline: time.Now().UTC().Add(3 * time.Second),
		Completed: []runtime.Trick{{Winner: 1, CapturedPoints: 25, Plays: []runtime.Played{{Seat: 1}}}},
	}
	message := snapshotMessage(view, room.Member{Role: room.RolePlayer, Seat: 1}, true)
	if message.ServerTime == nil {
		t.Fatal("server clock missing")
	}
	if message.LastTrick == nil || message.LastTrick.WinnerSeat != 2 || message.LastTrick.CapturedPoints != 25 ||
		message.LastTrick.RoundNo != 2 || message.LastTrick.TrickNo != 1 ||
		message.CurrentTurnUserId != "b" || message.ActionDeadline == nil {
		t.Fatalf("snapshot: %+v", message)
	}
	view.Phase = runtime.Dealing
	message = snapshotMessage(view, room.Member{Role: room.RolePlayer, Seat: 1}, true)
	if message.CurrentTurnUserId != "" || message.ActionDeadline != nil {
		t.Fatal("dealing exposed an actionable turn")
	}
	view.CompletedBaseline = 1
	if snapshotMessage(view, room.Member{}, true).LastTrick != nil {
		t.Fatal("synthetic setup emitted a completed trick")
	}
	view.Completed = append(view.Completed, runtime.Trick{Winner: 3})
	if snapshotMessage(view, room.Member{}, true).LastTrick.TrickNo != 1 {
		t.Fatal("synthetic setup double-counted tricks")
	}
}
