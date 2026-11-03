package grpc

import (
	"context"
	"fmt"
	"testing"
	"time"

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
	state = finishTestDeal(t, sessions, state.ID)
	if _, err := sessions.Submit(started.GameSessionID, "player-1", runtime.Action{
		Seat: 0, Kind: runtime.SetAutoplay, Accept: true, RequestID: "spectator-autoplay",
		ExpectedVersion: state.Version,
	}); err != nil {
		t.Fatal(err)
	}

	service := &gameServer{rooms: rooms, sessions: sessions}
	replayed, err := service.ListEventsAfter(ctxWithUserID(context.Background(), "spectator"),
		&huaiv1.ListEventsAfterRequest{GameSessionId: started.GameSessionID, LastSeenSeq: state.Version})
	if err != nil || len(replayed.GetEvents()) != 1 || replayed.GetLatestSeq() != state.Version+1 {
		t.Fatalf("replayed events = %+v, %v", replayed, err)
	}
	if replayed.Events[0].Payload != nil || replayed.Events[0].Seq != state.Version+1 {
		t.Fatal("public replay must contain ordered metadata without private cards")
	}
	reconnected, err := service.RequestReconnect(ctxWithUserID(context.Background(), "player-1"),
		&huaiv1.RequestReconnectRequest{GameSessionId: started.GameSessionID, LastSeenSeq: state.Version})
	if err != nil || len(reconnected.GetEvents()) != 1 ||
		reconnected.GetSnapshot().GetSeq() != state.Version+1 {
		t.Fatalf("reconnect = %+v, %v", reconnected, err)
	}
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
	sessions := runtime.NewRepository(func([]engine.Card) {})
	started, err := StartGameSession(rooms, sessions, created)
	if err != nil {
		t.Fatal(err)
	}
	if started.Room.Status != room.StatusPlaying || started.GameSessionID != created.Room.ID {
		t.Fatalf("practice game did not start: %+v", started)
	}

	service := &gameServer{rooms: rooms, sessions: sessions}
	ctx := ctxWithUserID(context.Background(), "owner")
	finishTestDeal(t, sessions, started.GameSessionID)
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
	expectedHand := 25
	if action.GetDeclareTrump() != nil {
		expectedHand = 33
	}
	if updated.StateVersion != response.StateVersion ||
		len(updated.VisibleHand) != expectedHand {
		t.Fatalf("unexpected updated snapshot: %+v", updated)
	}
}

func TestPracticeRobotProgressionSurvivesCancelledSubmitContext(t *testing.T) {
	rooms := room.NewManager()
	created, err := rooms.CreatePracticeRoom("owner", "Player")
	if err != nil {
		t.Fatal(err)
	}
	sessions := runtime.NewRepository(func([]engine.Card) {})
	started, err := StartGameSession(rooms, sessions, created)
	if err != nil {
		t.Fatal(err)
	}
	service := &gameServer{rooms: rooms, sessions: sessions}
	finishTestDeal(t, sessions, started.GameSessionID)
	snapshot, err := service.GetGameSnapshot(ctxWithUserID(context.Background(), "owner"),
		&huaiv1.GameSnapshotRequest{GameSessionId: started.GameSessionID})
	if err != nil {
		t.Fatal(err)
	}
	_, err = service.SubmitAction(ctxWithUserID(context.Background(), "owner"), &huaiv1.SubmitActionRequest{
		GameSessionId: started.GameSessionID, HandId: snapshot.HandId, RequestId: "33333333-3333-4333-8333-333333333333", ExpectedVersion: snapshot.StateVersion,
		Action: &huaiv1.GameAction{Payload: &huaiv1.GameAction_DeclareTrump{DeclareTrump: &huaiv1.DeclareTrumpAction{Suit: "clubs", Cards: []string{"clubs:2:0"}}}},
	})
	if err != nil {
		t.Fatal(err)
	}
	snapshot, err = service.GetGameSnapshot(ctxWithUserID(context.Background(), "owner"), &huaiv1.GameSnapshotRequest{GameSessionId: started.GameSessionID})
	if err != nil {
		t.Fatal(err)
	}
	buryAction := &huaiv1.GameAction{Payload: &huaiv1.GameAction_BuryCards{BuryCards: &huaiv1.BuryCardsAction{Cards: append([]string(nil), snapshot.VisibleHand[:8]...)}}}
	ctx, cancel := context.WithCancel(ctxWithUserID(context.Background(), "owner"))
	cancel()
	response, err := service.SubmitAction(ctx, &huaiv1.SubmitActionRequest{
		GameSessionId: started.GameSessionID, HandId: snapshot.HandId,
		RequestId:       "22222222-2222-4222-8222-222222222222",
		ExpectedVersion: snapshot.StateVersion,
		Action:          buryAction,
	})
	if err != nil || !response.GetAccepted() {
		t.Fatalf("cancelled SubmitAction() = %+v, %v", response, err)
	}
	state, err := sessions.Load(started.GameSessionID)
	if err != nil {
		t.Fatal(err)
	}
	if state.Turn != 1 || len(sessions.Due(time.Now())) != 0 {
		t.Fatal("robot advanced synchronously")
	}
	for count := 0; count < 32 && state.Players[state.Turn] != "owner"; count++ {
		service.advanceDue(state.Deadline)
		state, err = sessions.Load(started.GameSessionID)
		if err != nil {
			t.Fatal(err)
		}
	}
	updated, err := service.GetGameSnapshot(ctxWithUserID(context.Background(), "owner"),
		&huaiv1.GameSnapshotRequest{GameSessionId: started.GameSessionID})
	if err != nil {
		t.Fatal(err)
	}
	if updated.GetStateVersion() <= response.StateVersion || updated.GetCurrentTurnUserId() != "owner" {
		t.Fatalf("robot progression stopped after cancelled request: %+v", updated)
	}
	repeated, err := service.SubmitAction(ctxWithUserID(context.Background(), "owner"), &huaiv1.SubmitActionRequest{
		GameSessionId: started.GameSessionID, HandId: snapshot.HandId,
		RequestId: "22222222-2222-4222-8222-222222222222", ExpectedVersion: snapshot.StateVersion,
		Action: buryAction,
	})
	if err != nil || repeated.GetStateVersion() != response.StateVersion {
		t.Fatalf("retry changed accepted version after robots advanced: %+v, %v", repeated, err)
	}
}

func finishTestDeal(t *testing.T, sessions *runtime.Repository, id string) runtime.State {
	t.Helper()
	state, err := sessions.Load(id)
	if err != nil {
		t.Fatal(err)
	}
	if state.Phase == runtime.AwaitingReady {
		for seat := 0; seat < 4; seat++ {
			if state.Ready[seat] {
				continue
			}
			_, err = sessions.Submit(id, state.Players[seat], runtime.Action{Kind: runtime.Continue, Seat: seat, ExpectedVersion: state.Version, RequestID: fmt.Sprintf("ready-test:%d", seat)})
			if err != nil {
				t.Fatal(err)
			}
			state, err = sessions.Load(id)
			if err != nil {
				t.Fatal(err)
			}
		}
	}
	if state.Phase == runtime.Dealing {
		state, err = sessions.AdvanceDealing(id, state.Version, state.DealStarted.Add(100*state.DealInterval))
		if err != nil {
			t.Fatal(err)
		}
	}
	return state
}
