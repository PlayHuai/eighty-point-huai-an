package grpc

import (
	"context"
	"testing"

	huaiv1 "github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/runtime"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
)

func TestSpectatorSnapshotUsesSelectedSeatAndShowHandPermission(t *testing.T) {
	rooms := room.NewManager()
	created, err := rooms.CreateRoom("ordinary", "player-1", 0, room.Settings{
		Name: "table", AllowSpectators: true,
	})
	if err != nil {
		t.Fatal(err)
	}
	details, err := rooms.JoinRoom(created.Room.ID, "player-1", 0, "", created.Version)
	if err != nil {
		t.Fatal(err)
	}
	for _, userID := range []string{"player-2", "player-3", "player-4"} {
		details, err = rooms.JoinRoom(created.Room.ID, userID, 0, "", details.Version)
		if err != nil {
			t.Fatal(err)
		}
	}
	for _, member := range details.Members {
		if member.UserID == "player-2" && member.Seat != 2 {
			t.Fatalf("player-2 seat = %d, want 2", member.Seat)
		}
	}
	details, err = rooms.SetHandVisibility(created.Room.ID, "player-2", true, details.Version)
	if err != nil {
		t.Fatal(err)
	}
	details, err = rooms.JoinSpectator(
		created.Room.ID, "spectator", 0, "", 2, details.Version,
	)
	if err != nil {
		t.Fatal(err)
	}
	sessions := runtime.NewRepository(nil)
	started, err := StartGameSession(rooms, sessions, details)
	if err != nil {
		t.Fatal(err)
	}
	state, err := sessions.Load(started.GameSessionID)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := sessions.Submit(started.GameSessionID, "player-1", runtime.Action{
		Seat: 0, Kind: runtime.Pass, RequestID: "spectator-pass",
		ExpectedVersion: state.Version,
	}); err != nil {
		t.Fatal(err)
	}

	service := &gameServer{rooms: rooms, sessions: sessions}
	open, err := service.snapshotForMember(started, "spectator")
	if err != nil {
		t.Fatal(err)
	}
	if open.GetViewSeat() != 2 || len(open.GetVisibleHand()) != 25 ||
		open.GetVisibleHandCount() != 25 || len(open.GetAvailableActions()) != 0 {
		t.Fatalf("open spectator view = %+v", open)
	}

	current, err := rooms.GetRoom(created.Room.ID, "spectator")
	if err != nil {
		t.Fatal(err)
	}
	current, err = rooms.SetHandVisibility(created.Room.ID, "player-2", false, current.Version)
	if err != nil {
		t.Fatal(err)
	}
	closed, err := service.snapshotForMember(current, "spectator")
	if err != nil {
		t.Fatal(err)
	}
	if closed.GetViewSeat() != 2 || len(closed.GetVisibleHand()) != 0 ||
		closed.GetVisibleHandCount() != 25 || len(closed.GetAvailableActions()) != 0 {
		t.Fatalf("closed spectator view = %+v", closed)
	}
}

func TestSnapshotMessageProjectsBottomScoreCounterAndUniqueActions(t *testing.T) {
	view := runtime.Snapshot{
		ID: "session", Seat: 0, BottomOwner: 2, CounterKind: engine.CounterSmallJoker,
		Players:       [4]string{"one", "two", "three", "four"},
		Hand:          []engine.Card{cardForSnapshot(engine.Clubs, engine.RankThree)},
		SuggestedPlay: []engine.Card{cardForSnapshot(engine.Clubs, engine.RankThree)},
		HandCounts:    [4]int{1}, DefenderPoints: 25,
		Result: &runtime.Result{DefenderScore: 100},
		Actions: []runtime.AvailableAction{
			{Kind: runtime.Declare}, {Kind: runtime.Declare}, {Kind: runtime.CounterTrump},
		},
	}
	player := snapshotMessage(view, room.Member{Role: room.RolePlayer, Seat: 1}, true)
	if player.GetCurrentCounter() != uint32(engine.CounterSmallJoker) ||
		player.GetCapturedPoints() != 100 || len(player.GetAvailableActions()) != 2 ||
		len(player.GetSuggestedPlay()) != 1 {
		t.Fatalf("player snapshot projection = %+v", player)
	}

	view.BottomPublic = true
	view.Bottom = []engine.Card{cardForSnapshot(engine.Hearts, engine.RankFive)}
	spectator := snapshotMessage(view, room.Member{
		Role: room.RoleSpectator, ViewSeat: 3,
	}, false)
	if !spectator.GetBottomPublic() || len(spectator.GetBottomCards()) != 1 ||
		spectator.GetBottomOwnerUserId() != "three" ||
		len(spectator.GetAvailableActions()) != 0 || len(spectator.GetSuggestedPlay()) != 0 {
		t.Fatalf("spectator snapshot projection = %+v", spectator)
	}
}

func cardForSnapshot(suit engine.Suit, rank engine.Rank) engine.Card {
	return engine.Card{Suit: suit, Rank: rank}
}

func TestPracticeGameStartsSnapshotsAndAdvancesRobots(t *testing.T) {
	rooms := room.NewManager()
	created, err := rooms.CreatePracticeRoom("owner", "Player")
	if err != nil {
		t.Fatal(err)
	}
	sessions := runtime.NewRepository(nil)
	started, err := StartGameSession(rooms, sessions, created)
	if err != nil {
		t.Fatal(err)
	}
	if started.Room.Status != room.StatusPlaying || started.GameSessionID != created.Room.ID {
		t.Fatalf("practice game did not start: %+v", started)
	}

	service := &gameServer{rooms: rooms, sessions: sessions}
	ctx := ctxWithUserID(context.Background(), "owner")
	snapshot, err := service.GetGameSnapshot(ctx, &huaiv1.GameSnapshotRequest{
		GameSessionId: started.GameSessionID,
	})
	if err != nil {
		t.Fatal(err)
	}
	if len(snapshot.VisibleHand) != 25 || len(snapshot.BottomCards) != 0 ||
		snapshot.VisibleHandCount != 25 || snapshot.CurrentTurnUserId != "owner" {
		t.Fatalf("player snapshot exposed the wrong state: %+v", snapshot)
	}

	action := &huaiv1.GameAction{Payload: &huaiv1.GameAction_Pass{
		Pass: &huaiv1.PassAction{},
	}}
	for _, value := range snapshot.VisibleHand {
		card, parseErr := parseCard(value)
		if parseErr != nil {
			t.Fatal(parseErr)
		}
		if card.Rank == engine.RankTwo {
			action = &huaiv1.GameAction{Payload: &huaiv1.GameAction_DeclareTrump{
				DeclareTrump: &huaiv1.DeclareTrumpAction{
					Suit: card.Suit.String(), Cards: []string{value},
				},
			}}
			break
		}
	}

	response, err := service.SubmitAction(ctx, &huaiv1.SubmitActionRequest{
		GameSessionId: started.GameSessionID, HandId: snapshot.HandId,
		RequestId:       "11111111-1111-4111-8111-111111111111",
		ExpectedVersion: snapshot.StateVersion, Action: action,
	})
	if err != nil {
		t.Fatal(err)
	}
	if !response.Accepted || response.StateVersion <= snapshot.StateVersion {
		t.Fatalf("action was not accepted/versioned: %+v", response)
	}
	updated, err := service.GetGameSnapshot(ctx, &huaiv1.GameSnapshotRequest{
		GameSessionId: started.GameSessionID,
	})
	if err != nil {
		t.Fatal(err)
	}
	if updated.StateVersion != response.StateVersion ||
		len(updated.VisibleHand) != 33 {
		t.Fatalf("unexpected updated snapshot: %+v", updated)
	}
}

func TestPracticeRobotProgressionSurvivesCancelledSubmitContext(t *testing.T) {
	rooms := room.NewManager()
	created, err := rooms.CreatePracticeRoom("owner", "Player")
	if err != nil {
		t.Fatal(err)
	}
	sessions := runtime.NewRepository(nil)
	started, err := StartGameSession(rooms, sessions, created)
	if err != nil {
		t.Fatal(err)
	}
	service := &gameServer{rooms: rooms, sessions: sessions}
	snapshot, err := service.GetGameSnapshot(ctxWithUserID(context.Background(), "owner"),
		&huaiv1.GameSnapshotRequest{GameSessionId: started.GameSessionID})
	if err != nil {
		t.Fatal(err)
	}
	ctx, cancel := context.WithCancel(ctxWithUserID(context.Background(), "owner"))
	cancel()
	response, err := service.SubmitAction(ctx, &huaiv1.SubmitActionRequest{
		GameSessionId: started.GameSessionID, HandId: snapshot.HandId,
		RequestId:       "22222222-2222-4222-8222-222222222222",
		ExpectedVersion: snapshot.StateVersion,
		Action: &huaiv1.GameAction{Payload: &huaiv1.GameAction_Pass{
			Pass: &huaiv1.PassAction{},
		}},
	})
	if err != nil || !response.GetAccepted() {
		t.Fatalf("cancelled SubmitAction() = %+v, %v", response, err)
	}
	updated, err := service.GetGameSnapshot(ctxWithUserID(context.Background(), "owner"),
		&huaiv1.GameSnapshotRequest{GameSessionId: started.GameSessionID})
	if err != nil {
		t.Fatal(err)
	}
	if updated.GetPhase() != string(runtime.Bury) || len(updated.GetVisibleHand()) != 33 {
		t.Fatalf("robot progression stopped after cancelled request: %+v", updated)
	}
}
