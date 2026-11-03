package grpc

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/runtime"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/logging"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
)

func RunGameAutomation(ctx context.Context, rooms *room.Manager, sessions *runtime.Repository, publisher gameUpdatePublisher) {
	service := &gameServer{rooms: rooms, sessions: sessions, publisher: publisher}
	ticker := time.NewTicker(50 * time.Millisecond)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case now := <-ticker.C:
			service.advanceDue(now)
		}
	}
}

func (s *gameServer) advanceDue(now time.Time) {
	for _, state := range s.sessions.Due(now) {
		seat := state.Turn
		var err error
		if state.Phase == runtime.Dealing {
			var dealt runtime.State
			dealt, err = s.sessions.AdvanceDealing(state.ID, state.Version, now)
			if err == nil && dealt.Phase == runtime.Dealing && dealt.Declarer < 0 && dealt.Practice {
				for robot := 1; robot < 4; robot++ {
					view, viewErr := runtime.View(dealt, robot)
					if viewErr != nil {
						err = viewErr
						break
					}
					if len(view.Actions) > 0 && view.Actions[0].Kind == runtime.Declare {
						_, err = s.sessions.Submit(dealt.ID, dealt.Players[robot], runtime.Action{
							Seat: robot, Kind: runtime.Declare, Cards: view.Actions[0].Cards,
							RequestID: fmt.Sprintf("robot-declare:%d:%d", dealt.Version, robot), ExpectedVersion: dealt.Version})
						break
					}
				}
			}
		} else if state.RequireReady && (state.Phase == runtime.AwaitingReady || state.Phase == runtime.HandOver || state.Phase == runtime.Declaration) {
			_, err = s.sessions.AdvanceWaiting(state.ID, state.Version, now)
		} else {
			var action runtime.Action
			action, err = runtime.AutomaticAction(state, seat, fmt.Sprintf("timeout:%d:%d", state.Version, seat))
			if err == nil {
				_, err = s.sessions.Submit(state.ID, state.Players[seat], action)
			}
		}
		if errors.Is(err, runtime.ErrVersion) || errors.Is(err, runtime.ErrNotFound) {
			continue
		}
		if err != nil {
			logging.Error("game.timeout.failed session=%q version=%d error=%q", state.ID, state.Version, err)
			continue
		}
		updated, err := s.sessions.Load(state.ID)
		if err == nil && (updated.Phase == runtime.Finished || updated.Phase == runtime.Void) {
			_, err = s.rooms.CompleteGameSession(state.ID, state.ID)
		}
		if err == nil {
			err = s.publishUpdate(context.Background(), state.ID, state.Players[seat], updated.Version)
		}
		if err != nil {
			logging.Error("game.timeout.publish.failed session=%q error=%q", state.ID, err)
		}
	}
}
