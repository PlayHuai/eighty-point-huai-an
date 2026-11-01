package grpc

import (
	"context"
	"testing"

	huaiv1 "github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/runtime"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
)

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
