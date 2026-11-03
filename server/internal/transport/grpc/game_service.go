package grpc

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strconv"
	"strings"
	"time"

	huaiv1 "github.com/Derek0120/eighty-point-huai-an/server/gen/huai/v1"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/runtime"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/logging"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/room"
	grpcgo "google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type gameServer struct {
	huaiv1.UnimplementedGameServiceServer
	rooms     *room.Manager
	sessions  *runtime.Repository
	publisher gameUpdatePublisher
}

type gameUpdatePublisher interface {
	PublishGameUpdate([]string, string, uint64, json.RawMessage)
}

func RegisterGameService(
	server grpcgo.ServiceRegistrar,
	rooms *room.Manager,
	sessions *runtime.Repository,
	publishers ...gameUpdatePublisher,
) error {
	if server == nil || rooms == nil || sessions == nil || len(publishers) > 1 {
		return errors.New("gRPC registrar, room manager, and game sessions are required")
	}
	service := &gameServer{rooms: rooms, sessions: sessions}
	if len(publishers) == 1 {
		service.publisher = publishers[0]
	}
	rooms.SetSessionCleanup(func(details room.Details) {
		if details.GameSessionID != "" {
			sessions.Delete(details.GameSessionID)
		}
	})
	huaiv1.RegisterGameServiceServer(server, service)
	return nil
}

func StartGameSession(
	rooms *room.Manager,
	sessions *runtime.Repository,
	details room.Details,
	scenarios ...string,
) (room.Details, error) {
	if rooms == nil || sessions == nil || details.Room.ID == "" {
		return room.Details{}, runtime.ErrInvalidConfig
	}
	if details.Room.Status == room.StatusPlaying && details.GameSessionID != "" {
		return details, nil
	}
	if details.GameSessionID != "" {
		if previous, loadErr := sessions.Load(details.GameSessionID); loadErr == nil {
			if previous.Phase != runtime.Finished && previous.Phase != runtime.Void {
				return room.Details{}, runtime.ErrInvalidConfig
			}
			sessions.Delete(details.GameSessionID)
		} else if !errors.Is(loadErr, runtime.ErrNotFound) {
			return room.Details{}, loadErr
		}
	}
	var players [4]string
	for _, member := range details.Members {
		if member.Role != room.RolePlayer || member.Seat < 1 || member.Seat > 4 {
			continue
		}
		players[member.Seat-1] = member.UserID
	}
	state, err := createGameSession(sessions, runtime.Config{
		RequireReady: true,
		ID:           details.Room.ID, Players: players, Practice: details.Room.PracticeMode,
		HallID: details.Room.HallID, OwnerID: details.Room.OwnerID,
		DealInterval:  time.Duration(details.Room.DealIntervalMS) * time.Millisecond,
		CounterWindow: time.Duration(details.Room.CounterWindowMS) * time.Millisecond,
	}, scenarios)
	if err != nil {
		return room.Details{}, err
	}
	started, err := rooms.StartWithGameSession(
		details.Room.ID, details.Room.OwnerID, details.Version, state.ID,
	)
	if err != nil {
		sessions.Delete(state.ID)
		return room.Details{}, err
	}
	logging.Info("game.started room_id=%q game_session_id=%q version=%d", started.Room.ID, state.ID, state.Version)
	return started, nil
}

func (s *gameServer) GetGameSnapshot(
	ctx context.Context,
	request *huaiv1.GameSnapshotRequest,
) (*huaiv1.GameSnapshot, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	details, err := s.authorizedRoom(request.GetGameSessionId(), userID)
	if err != nil {
		return nil, err
	}
	return s.snapshotForMember(details, userID)
}

func (s *gameServer) SubmitAction(
	ctx context.Context,
	request *huaiv1.SubmitActionRequest,
) (*huaiv1.SubmitActionResponse, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if !validUUID(request.GetRequestId()) || request.GetAction() == nil {
		return nil, status.Error(codes.InvalidArgument, "valid request_id and action are required")
	}
	details, err := s.authorizedRoom(request.GetGameSessionId(), userID)
	if err != nil {
		return nil, err
	}
	member := findRoomMember(details, userID)
	if member.Role != room.RolePlayer || member.Seat < 1 || member.Seat > 4 {
		return nil, status.Error(codes.PermissionDenied, "only seated players can submit game actions")
	}
	action, err := runtimeAction(request.GetAction(), int(member.Seat)-1, request)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "invalid game action")
	}
	if request.GetHandId() == "" {
		return nil, status.Error(codes.InvalidArgument, "hand_id is required")
	}
	submission, err := s.sessions.SubmitHand(
		request.GetGameSessionId(), userID, request.GetHandId(), action,
	)
	if err != nil {
		return nil, gameRuntimeError(err)
	}
	state, err := s.sessions.Load(request.GetGameSessionId())
	if err != nil {
		return nil, gameRuntimeError(err)
	}
	if state.Phase == runtime.Finished || state.Phase == runtime.Void {
		if _, err := s.rooms.CompleteGameSession(request.GetGameSessionId(), request.GetGameSessionId()); err != nil {
			return nil, roomServiceError(err)
		}
	}
	if err := s.publishUpdate(context.Background(), request.GetGameSessionId(), userID, state.Version); err != nil {
		logging.Error("game.publish.failed game_session_id=%q version=%d error_type=%T", state.ID, state.Version, err)
		return nil, status.Error(codes.Internal, "could not publish game update")
	}
	logging.Info("game.action.complete game_session_id=%q request_id=%q user_id=%q version=%d phase=%v",
		state.ID, request.GetRequestId(), userID, state.Version, state.Phase)
	return &huaiv1.SubmitActionResponse{
		Accepted: true, StateVersion: submission.Snapshot.Version,
	}, nil
}

func (s *gameServer) ListEventsAfter(
	ctx context.Context,
	request *huaiv1.ListEventsAfterRequest,
) (*huaiv1.ListEventsAfterResponse, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	details, err := s.authorizedRoom(request.GetGameSessionId(), userID)
	if err != nil {
		return nil, err
	}
	limit := request.GetPageSize()
	if limit == 0 {
		limit = 100
	}
	events, latest, err := s.sessions.EventsAfter(details.GameSessionID, request.GetLastSeenSeq(), int(limit))
	if err != nil {
		return nil, gameRuntimeError(err)
	}
	return &huaiv1.ListEventsAfterResponse{Events: replayMessages(details.GameSessionID, events), LatestSeq: latest}, nil
}

func (s *gameServer) RequestReconnect(
	ctx context.Context,
	request *huaiv1.RequestReconnectRequest,
) (*huaiv1.RequestReconnectResponse, error) {
	userID, err := authenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	details, err := s.authorizedRoom(request.GetGameSessionId(), userID)
	if err != nil {
		return nil, err
	}
	snapshot, err := s.snapshotForMember(details, userID)
	if err != nil {
		return nil, err
	}
	events, _, err := s.sessions.EventsAfter(details.GameSessionID, request.GetLastSeenSeq(), 1000)
	if err != nil {
		return nil, gameRuntimeError(err)
	}
	visible := events[:0]
	for _, event := range events {
		if event.Sequence <= snapshot.GetSeq() {
			visible = append(visible, event)
		}
	}
	return &huaiv1.RequestReconnectResponse{
		Snapshot: snapshot, Events: replayMessages(details.GameSessionID, visible),
	}, nil
}

func replayMessages(sessionID string, events []runtime.Event) []*huaiv1.GameEvent {
	messages := make([]*huaiv1.GameEvent, 0, len(events))
	for _, event := range events {
		messages = append(messages, &huaiv1.GameEvent{
			EventId: event.ID, Seq: event.Sequence, Type: strings.ToUpper(string(event.Kind)),
			GameSessionId: sessionID, HandId: event.HandID, StateVersion: event.Sequence,
			CreatedAt: timestamppb.New(event.CreatedAt),
		})
	}
	return messages
}

func (s *gameServer) authorizedRoom(sessionID, userID string) (room.Details, error) {
	if sessionID == "" {
		return room.Details{}, status.Error(codes.InvalidArgument, "game_session_id is required")
	}
	details, err := s.rooms.GetRoom(sessionID, userID)
	if err != nil {
		return room.Details{}, roomServiceError(err)
	}
	if details.GameSessionID != sessionID {
		return room.Details{}, status.Error(codes.NotFound, "game session not found")
	}
	if details.Room.Status != room.StatusPlaying {
		if details.Room.Status != room.StatusWaiting {
			return room.Details{}, status.Error(codes.NotFound, "game session not found")
		}
		state, err := s.sessions.Load(sessionID)
		if err != nil || (state.Phase != runtime.Finished && state.Phase != runtime.Void) {
			return room.Details{}, status.Error(codes.NotFound, "game session not found")
		}
	}
	return details, nil
}

func (s *gameServer) snapshotForMember(
	details room.Details,
	userID string,
) (*huaiv1.GameSnapshot, error) {
	state, err := s.sessions.Load(details.GameSessionID)
	if err != nil {
		return nil, gameRuntimeError(err)
	}
	member := findRoomMember(details, userID)
	seat := -1
	visibleHand := false
	if member.Role == room.RolePlayer && member.Seat >= 1 && member.Seat <= 4 {
		seat = int(member.Seat) - 1
		visibleHand = true
	} else if member.Role == room.RoleSpectator && member.ViewSeat >= 1 && member.ViewSeat <= 4 {
		seat = int(member.ViewSeat) - 1
		for _, target := range details.Members {
			if target.Role == room.RolePlayer && target.Seat == member.ViewSeat {
				visibleHand = target.ShowHand
				break
			}
		}
	}
	view, err := runtime.View(state, seat)
	if err != nil {
		return nil, gameRuntimeError(err)
	}
	return snapshotMessage(view, member, visibleHand), nil
}

func (s *gameServer) publishUpdate(
	ctx context.Context,
	sessionID, userID string,
	version uint64,
) error {
	if s.publisher == nil {
		return nil
	}
	userIDs, err := s.rooms.RoomMemberIDs(ctx, sessionID, userID)
	if err != nil {
		return err
	}
	payload, err := json.Marshal(struct {
		GameSessionID string `json:"game_session_id"`
		StateVersion  uint64 `json:"state_version"`
	}{GameSessionID: sessionID, StateVersion: version})
	if err != nil {
		return err
	}
	s.publisher.PublishGameUpdate(userIDs, sessionID, version, payload)
	return nil
}

func runtimeAction(
	action *huaiv1.GameAction,
	seat int,
	request *huaiv1.SubmitActionRequest,
) (runtime.Action, error) {
	result := runtime.Action{
		Seat: seat, RequestID: request.GetRequestId(),
		ExpectedVersion: request.GetExpectedVersion(),
	}
	parse := func(values []string) ([]engine.Card, error) {
		cards := make([]engine.Card, 0, len(values))
		for _, value := range values {
			card, err := parseCard(value)
			if err != nil {
				return nil, err
			}
			cards = append(cards, card)
		}
		return cards, nil
	}
	switch payload := action.GetPayload().(type) {
	case *huaiv1.GameAction_DeclareTrump:
		result.Kind = runtime.Declare
		var err error
		result.Cards, err = parse(payload.DeclareTrump.GetCards())
		if err != nil {
			return runtime.Action{}, err
		}
		if len(result.Cards) != 1 || payload.DeclareTrump.GetSuit() != result.Cards[0].Suit.String() {
			return runtime.Action{}, runtime.ErrInvalidAction
		}
	case *huaiv1.GameAction_CounterTrump:
		result.Kind = runtime.CounterTrump
		var err error
		result.Cards, err = parse(payload.CounterTrump.GetCards())
		if err != nil {
			return runtime.Action{}, err
		}
	case *huaiv1.GameAction_RedeclareTrump:
		result.Kind = runtime.LookBack
	case *huaiv1.GameAction_BuryCards:
		result.Kind = runtime.BuryCards
		var err error
		result.Cards, err = parse(payload.BuryCards.GetCards())
		if err != nil {
			return runtime.Action{}, err
		}
	case *huaiv1.GameAction_PlayCards:
		result.Kind = runtime.PlayCards
		var err error
		result.Cards, err = parse(payload.PlayCards.GetCards())
		if err != nil {
			return runtime.Action{}, err
		}
	case *huaiv1.GameAction_Pass:
		result.Kind = runtime.Pass
	case *huaiv1.GameAction_ContinueAction:
		result.Kind = runtime.Continue
	case *huaiv1.GameAction_ConfirmAutoplay:
		result.Kind, result.Accept = runtime.SetAutoplay, payload.ConfirmAutoplay.GetAccept()
	case *huaiv1.GameAction_WaitVote:
		result.Kind, result.Accept = runtime.WaitVote, payload.WaitVote.GetAccept()
	default:
		return runtime.Action{}, runtime.ErrInvalidAction
	}
	return result, nil
}

func snapshotMessage(view runtime.Snapshot, member room.Member, visibleHand bool) *huaiv1.GameSnapshot {
	visibleHandCount := uint32(0)
	if view.Seat >= 0 && view.Seat < 4 {
		visibleHandCount = uint32(view.HandCounts[view.Seat])
	}
	result := &huaiv1.GameSnapshot{
		GameSessionId: view.ID, HandId: fmt.Sprintf("%s:%d", view.ID, view.HandNumber),
		StateVersion: view.Version, Phase: string(view.Phase),
		CapturedPoints: int64(view.DefenderPoints), RoundNo: uint32(view.HandNumber),
		TeamOneLevel: view.Levels[0].String(), TeamTwoLevel: view.Levels[1].String(),
		ViewSeat: member.Seat, VisibleHandCount: visibleHandCount,
		TrumpSuit: view.Trump.Suit.String(), TrumpLevel: uint32(view.Trump.Level),
		State: "IN_PROGRESS", Seq: view.Version,
		ServerTime:       timestamppb.Now(),
		AvailableActions: make([]string, 0, len(view.Actions)),
		PublicPlays:      make([]*huaiv1.PublicPlay, 0, len(view.Trick.Plays)),
	}
	if view.Phase == runtime.HandOver {
		result.State = "SETTLED"
	}
	if view.Phase == runtime.Finished {
		result.State = "FINISHED"
	}
	if view.Phase == runtime.Void {
		result.State = "VOID"
	}
	result.ReadyWaitPrompt = view.ReadyPrompt
	for seat, ready := range view.Ready {
		if ready {
			result.ReadySeats = append(result.ReadySeats, uint32(seat+1))
		}
	}
	for seat, vote := range view.WaitVotes {
		if vote < 0 {
			result.DeclinedWaitSeats = append(result.DeclinedWaitSeats, uint32(seat+1))
		}
	}
	if !view.ReadyDeadline.IsZero() {
		result.ReadyDeadline = timestamppb.New(view.ReadyDeadline)
	}
	if view.FallbackCard != nil {
		result.FallbackCard = cardsMessage([]engine.Card{*view.FallbackCard})[0]
	}
	if view.Result != nil {
		result.CapturedPoints = int64(view.Result.DefenderScore)
		result.Settlement = &huaiv1.HandSettlement{
			RoundNo: uint32(view.HandNumber), WinnerTeam: uint32(view.Result.WinnerTeam + 1),
			DefenderScore: int64(view.Result.DefenderScore), Spring: view.Result.Spring,
			SkyEarth: view.Result.SkyEarth, Comeback: view.Result.Resolution.Comeback,
			NaturalLevel: view.Result.Resolution.NaturalLevel, MatchFinished: view.Phase == runtime.Finished,
			NominalPoints: view.Result.NominalPoints,
			TeamOneLevel:  view.Levels[0].String(), TeamTwoLevel: view.Levels[1].String(),
		}
		for _, change := range view.Result.PointChanges {
			result.Settlement.PointChanges = append(result.Settlement.PointChanges, &huaiv1.PlayerPointChange{
				UserId: change.UserID, Delta: change.Delta, Rank: change.Rank,
			})
		}
	}
	if !view.Deadline.IsZero() && view.Turn >= 0 && view.Phase != runtime.Dealing && view.Phase != runtime.AwaitingReady && view.Phase != runtime.Void &&
		view.Phase != runtime.HandOver && view.Phase != runtime.Finished {
		result.ActionDeadline = timestamppb.New(view.Deadline)
	}
	for seat, enabled := range view.Autoplay {
		if enabled {
			result.AutoplaySeats = append(result.AutoplaySeats, uint32(seat+1))
		}
	}
	for _, hand := range view.History {
		for i, trick := range hand.Tricks {
			history := &huaiv1.TrickHistory{RoundNo: uint32(hand.Number), TrickNo: uint32(i + 1), WinnerSeat: uint32(trick.Winner + 1), CapturedPoints: int64(trick.CapturedPoints)}
			for _, play := range trick.Plays {
				history.Plays = append(history.Plays, &huaiv1.PublicPlay{SeatNo: uint32(play.Seat + 1), Cards: cardsMessage(play.Cards)})
			}
			result.History = append(result.History, history)
		}
	}
	if view.Turn >= 0 && view.Turn < 4 && view.Phase != runtime.Dealing && view.Phase != runtime.AwaitingReady && view.Phase != runtime.Void &&
		view.Phase != runtime.HandOver && view.Phase != runtime.Finished {
		result.CurrentTurnUserId = view.Players[view.Turn]
	}
	if view.Dealer >= 0 && view.Dealer < 4 {
		result.DealerUserId = view.Players[view.Dealer]
		result.DealerSeat = uint32(view.Dealer + 1)
	}
	if view.Seat >= 0 && view.Seat < 4 {
		result.VisibleHandCount = uint32(view.HandCounts[view.Seat])
		result.ViewerTeam = uint32(view.Seat%2 + 1)
		if visibleHand {
			result.VisibleHand = cardsMessage(view.Hand)
		}
		if member.Role == room.RolePlayer {
			result.SuggestedPlay = cardsMessage(view.SuggestedPlay)
		}
	}
	if member.Role == room.RoleSpectator {
		result.ViewSeat = member.ViewSeat
		result.ViewerTeam = teamForSeat(member.ViewSeat)
	}
	if view.BottomOwner >= 0 && view.BottomOwner < 4 {
		result.BottomOwnerUserId = view.Players[view.BottomOwner]
	}
	result.BottomPublic = view.BottomPublic
	if view.BottomPublic ||
		(member.Role == room.RolePlayer && view.BottomOwner == view.Seat) {
		result.BottomCards = cardsMessage(view.Bottom)
	}
	if view.DefenderPoints > 0 {
		result.ScoringTeam = uint32(2 - view.Dealer%2)
	}
	for _, completed := range view.Completed {
		for _, play := range completed.Plays {
			result.PublicCards = append(result.PublicCards, cardsMessage(play.Cards)...)
		}
	}
	if count := len(view.Completed); count > view.CompletedBaseline {
		trick := view.Completed[count-1]
		result.LastTrick = &huaiv1.TrickHistory{
			RoundNo: uint32(view.HandNumber), TrickNo: uint32(count - view.CompletedBaseline),
			WinnerSeat: uint32(trick.Winner + 1), CapturedPoints: int64(trick.CapturedPoints),
		}
		for _, play := range trick.Plays {
			result.LastTrick.Plays = append(result.LastTrick.Plays, &huaiv1.PublicPlay{
				SeatNo: uint32(play.Seat + 1), Cards: cardsMessage(play.Cards),
			})
		}
	}
	for _, play := range view.Trick.Plays {
		cards := cardsMessage(play.Cards)
		result.PublicCards = append(result.PublicCards, cards...)
		result.PublicPlays = append(result.PublicPlays, &huaiv1.PublicPlay{
			SeatNo: uint32(play.Seat + 1), Cards: cards,
		})
	}
	seenActions := make(map[string]struct{}, len(view.Actions))
	if member.Role == room.RolePlayer {
		for _, available := range view.Actions {
			name := actionName(available.Kind)
			if _, exists := seenActions[name]; exists {
				continue
			}
			seenActions[name] = struct{}{}
			result.AvailableActions = append(result.AvailableActions, name)
		}
	}
	result.CurrentCounter = uint32(view.CounterKind)
	return result
}

func actionName(kind runtime.ActionKind) string {
	switch kind {
	case runtime.Declare:
		return "DECLARE"
	case runtime.Pass:
		return "PASS"
	case runtime.CounterTrump:
		return "COUNTER"
	case runtime.LookBack:
		return "REDECLARE"
	case runtime.BuryCards:
		return "BURY"
	case runtime.PlayCards:
		return "PLAY"
	case runtime.Continue:
		return "CONTINUE"
	case runtime.WaitVote:
		return "WAIT_VOTE"
	default:
		return ""
	}
}

func cardsMessage(cards []engine.Card) []string {
	result := make([]string, 0, len(cards))
	for _, card := range cards {
		suit := card.Suit.String()
		if card.Rank == engine.RankSmallJoker || card.Rank == engine.RankBigJoker {
			suit = "joker"
		}
		result = append(result, fmt.Sprintf("%s:%d:%d", suit, card.Rank, card.Copy))
	}
	return result
}

func parseCard(value string) (engine.Card, error) {
	parts := strings.Split(value, ":")
	if len(parts) != 3 {
		return engine.Card{}, engine.ErrInvalidCard
	}
	suits := map[string]engine.Suit{
		"clubs": engine.Clubs, "diamonds": engine.Diamonds,
		"hearts": engine.Hearts, "spades": engine.Spades, "joker": engine.NoSuit,
	}
	suit, ok := suits[parts[0]]
	if !ok {
		return engine.Card{}, engine.ErrInvalidCard
	}
	rank, err := strconv.Atoi(parts[1])
	if err != nil || rank < 0 || rank > 255 {
		return engine.Card{}, engine.ErrInvalidCard
	}
	copyID, err := strconv.Atoi(parts[2])
	if err != nil || copyID < 0 || copyID > 255 {
		return engine.Card{}, engine.ErrInvalidCard
	}
	card := engine.Card{Suit: suit, Rank: engine.Rank(rank), Copy: uint8(copyID)}
	if err := card.Validate(); err != nil {
		return engine.Card{}, err
	}
	return card, nil
}

func handID(state runtime.State) string {
	return fmt.Sprintf("%s:%d", state.ID, state.HandNumber)
}

func findRoomMember(details room.Details, userID string) room.Member {
	for _, member := range details.Members {
		if member.UserID == userID {
			return member
		}
	}
	return room.Member{}
}

func gameRuntimeError(err error) error {
	switch {
	case errors.Is(err, runtime.ErrNotFound):
		return status.Error(codes.NotFound, "game session not found")
	case errors.Is(err, runtime.ErrVersion):
		return status.Error(codes.Aborted, "game state has changed")
	case errors.Is(err, runtime.ErrHand):
		return status.Error(codes.Aborted, "game hand has changed")
	case errors.Is(err, runtime.ErrRequest):
		return status.Error(codes.AlreadyExists, "request_id was reused for a different action")
	case errors.Is(err, runtime.ErrTurn):
		return status.Error(codes.FailedPrecondition, "it is not this player's turn")
	case errors.Is(err, runtime.ErrPhase):
		return status.Error(codes.FailedPrecondition, "action is not allowed in this phase")
	case errors.Is(err, runtime.ErrCards), errors.Is(err, runtime.ErrInvalidAction),
		errors.Is(err, engine.ErrInvalidCard), errors.Is(err, engine.ErrInvalidTrump),
		errors.Is(err, engine.ErrInvalidPlay), errors.Is(err, engine.ErrInvalidCounter),
		errors.Is(err, engine.ErrInvalidScore):
		return status.Error(codes.InvalidArgument, "game action is invalid")
	default:
		logging.Unexpected("game.action", err)
		return status.Error(codes.Internal, "could not process game action")
	}
}
