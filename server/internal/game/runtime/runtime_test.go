package runtime

import (
	"encoding/json"
	"errors"
	"fmt"
	"math/rand"
	"reflect"
	"strings"
	"sync"
	"testing"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"
)

func card(suit engine.Suit, rank engine.Rank, copyID uint8) engine.Card {
	return engine.Card{Suit: suit, Rank: rank, Copy: copyID}
}

func pair(suit engine.Suit, rank engine.Rank) []engine.Card {
	return []engine.Card{card(suit, rank, 0), card(suit, rank, 1)}
}

func fiveTenKing(suit engine.Suit) []engine.Card {
	return []engine.Card{card(suit, engine.RankFive, 0),
		card(suit, engine.RankTen, 0), card(suit, engine.RankKing, 0)}
}

func config() Config {
	return Config{ID: "session", Players: [4]string{"a", "b", "c", "d"}}
}

func identity([]engine.Card) {}

func session(t *testing.T) State {
	t.Helper()
	state, err := NewSession(config(), identity)
	if err != nil {
		t.Fatal(err)
	}
	return state
}

func apply(t *testing.T, state State, seat int, kind ActionKind, cards ...engine.Card) State {
	t.Helper()
	next, err := Apply(state, Action{
		Seat: seat, Kind: kind, Cards: cards,
		RequestID: fmt.Sprintf("request-%d", state.Version), ExpectedVersion: state.Version,
	}, identity)
	if err != nil {
		t.Fatalf("%s seat %d phase %s: %v", kind, seat, state.Phase, err)
	}
	if next.Version != state.Version+1 {
		t.Fatal("version did not advance")
	}
	return next
}

func start(t *testing.T, state State) State {
	t.Helper()
	for state.Phase == Declaration {
		state = apply(t, state, state.Turn, Pass)
	}
	seat := state.Turn
	state = apply(t, state, seat, BuryCards, state.Hands[seat][:8]...)
	for state.Phase == Counter {
		state = apply(t, state, state.Turn, Pass)
	}
	return state
}

func TestDeckDealAndShuffle(t *testing.T) {
	deck := Deck()
	if len(deck) != 108 || !unique(deck) {
		t.Fatal("deck is not two complete packs")
	}
	points, err := engine.Points(deck)
	if err != nil || points != 200 {
		t.Fatalf("deck points %d, %v", points, err)
	}
	first := session(t)
	var all []engine.Card
	for _, hand := range first.Hands {
		if len(hand) != 25 {
			t.Fatalf("hand size %d", len(hand))
		}
		all = append(all, hand...)
	}
	all = append(all, first.Bottom...)
	if len(first.Bottom) != 8 || len(all) != 108 || !unique(all) {
		t.Fatal("deal lost or duplicated cards")
	}
	seeded := func() Shuffle {
		random := rand.New(rand.NewSource(42))
		return func(cards []engine.Card) {
			random.Shuffle(len(cards), func(i, j int) { cards[i], cards[j] = cards[j], cards[i] })
		}
	}
	a, err := NewSession(config(), seeded())
	if err != nil {
		t.Fatal(err)
	}
	b, err := NewSession(config(), seeded())
	if err != nil || !reflect.DeepEqual(a, b) || reflect.DeepEqual(a.Hands, first.Hands) {
		t.Fatal("shuffle is not reproducible/injectable")
	}
	if _, err := NewSession(config(), func(cards []engine.Card) { cards[0] = cards[1] }); !errors.Is(err, ErrCards) {
		t.Fatalf("bad shuffler accepted: %v", err)
	}
	if _, err := NewSession(config(), nil); err != nil {
		t.Fatalf("default shuffle: %v", err)
	}
}

func TestInvalidConfig(t *testing.T) {
	for _, mutate := range []func(*Config){
		func(c *Config) { c.ID = "" },
		func(c *Config) { c.Dealer = -1 },
		func(c *Config) { c.Dealer = 4 },
		func(c *Config) { c.Players[2] = "" },
		func(c *Config) { c.Players[2] = c.Players[0] },
		func(c *Config) { c.Levels[0] = engine.RankSmallJoker },
	} {
		cfg := config()
		mutate(&cfg)
		if _, err := NewSession(cfg, identity); !errors.Is(err, ErrInvalidConfig) {
			t.Fatalf("invalid config accepted: %+v, %v", cfg, err)
		}
	}
}

func TestAutomaticActionAlwaysReturnsRuleCheckedMoves(t *testing.T) {
	state := session(t)
	state.Phase, state.Turn = Playing, 0
	state.Trump = engine.Trump{Suit: engine.Clubs, Level: engine.RankTwo}
	lead, err := AutomaticAction(state, 0, "robot-lead")
	if err != nil || lead.Kind != PlayCards || state.ValidatePlay(0, lead.Cards) != nil {
		t.Fatalf("automatic lead = %+v, %v", lead, err)
	}

	state.Trick = Trick{
		Leader: 3, Winner: 3,
		Plays: []Played{{Seat: 3, Cards: []engine.Card{state.Hands[3][0]}}},
	}
	follow, err := AutomaticAction(state, 0, "robot-follow")
	if err != nil || follow.Kind != PlayCards || state.ValidatePlay(0, follow.Cards) != nil {
		t.Fatalf("automatic follow = %+v, %v", follow, err)
	}

	state.Phase, state.Turn = Bury, 0
	bury, err := AutomaticAction(state, 0, "robot-bury")
	if err != nil || bury.Kind != BuryCards || len(bury.Cards) != 8 {
		t.Fatalf("automatic bury = %+v, %v", bury, err)
	}
	for _, buried := range bury.Cards {
		if buried.Rank == state.Trump.Level ||
			(buried.Suit == engine.Hearts && buried.Rank == engine.RankFive) {
			t.Fatalf("automatic bury selected protected card: %+v", buried)
		}
	}

	state.Phase, state.Turn = HandOver, -1
	continueAction, err := AutomaticAction(state, 1, "robot-continue")
	if err != nil || continueAction.Kind != Continue {
		t.Fatalf("automatic continuation = %+v, %v", continueAction, err)
	}
}

func TestAutomaticPlayPreservesFollowObligationsAndWinsWhenPossible(t *testing.T) {
	state := session(t)
	state.Phase, state.Turn = Playing, 0
	state.Trump = engine.Trump{Suit: engine.Spades, Level: engine.RankTwo}
	state.Hands = [4][]engine.Card{}
	state.Hands[0] = append(pair(engine.Clubs, engine.RankEight),
		card(engine.Clubs, engine.RankThree, 0), card(engine.Clubs, engine.RankFour, 0))
	lead := pair(engine.Clubs, engine.RankKing)
	state.Hands[3] = lead
	state.Trick = Trick{Leader: 3, Winner: 3, Plays: []Played{{Seat: 3, Cards: lead}}}

	action, err := AutomaticAction(state, 0, "mandatory-pair")
	if err != nil || len(action.Cards) != 2 || !engine.IsPair(action.Cards) ||
		action.Cards[0].Rank != engine.RankEight || state.ValidatePlay(0, action.Cards) != nil {
		t.Fatalf("automatic pair response = %+v, %v", action, err)
	}

	state.Hands[0] = []engine.Card{
		card(engine.Clubs, engine.RankThree, 0),
		card(engine.Clubs, engine.RankAce, 0),
	}
	state.Trick.Plays[0].Cards = []engine.Card{card(engine.Clubs, engine.RankKing, 0)}
	action, err = AutomaticAction(state, 0, "winning-single")
	if err != nil || len(action.Cards) != 1 || action.Cards[0].Rank != engine.RankAce {
		t.Fatalf("automatic winning response = %+v, %v", action, err)
	}
}

func TestAutomaticPlayFollowsMain510KForcedDraw(t *testing.T) {
	state := session(t)
	state.Phase, state.Turn = Playing, 0
	state.Trump = engine.Trump{Suit: engine.Clubs, Level: engine.RankTwo}
	state.Hands = [4][]engine.Card{}
	state.Hands[0] = []engine.Card{
		card(engine.Hearts, engine.RankTwo, 0),
		card(engine.Hearts, engine.RankFive, 0),
		card(engine.Diamonds, engine.RankThree, 0),
	}
	lead := fiveTenKing(engine.Clubs)
	state.Hands[3] = lead
	state.Trick = Trick{Leader: 3, Winner: 3, Plays: []Played{{Seat: 3, Cards: lead}}}

	action, err := AutomaticAction(state, 0, "forced-draw")
	if err != nil || state.ValidatePlay(0, action.Cards) != nil ||
		len(filter(action.Cards, func(card engine.Card) bool {
			return engine.IsTrump(card, state.Trump)
		})) != 2 {
		t.Fatalf("automatic forced draw = %+v, %v", action, err)
	}
}

func TestAutomaticLeadPrioritizes510KAndTrumpPairs(t *testing.T) {
	state := session(t)
	state.Phase, state.Turn = Playing, 0
	state.Trump = engine.Trump{Suit: engine.Spades, Level: engine.RankTwo}
	state.Hands = [4][]engine.Card{
		append(fiveTenKing(engine.Clubs), pair(engine.Spades, engine.RankEight)...),
	}
	action, err := AutomaticAction(state, 0, "lead-510k")
	if err != nil || !engine.Is510K(action.Cards) {
		t.Fatalf("automatic 510k lead = %+v, %v", action, err)
	}

	state.Hands[0] = pair(engine.Spades, engine.RankEight)
	action, err = AutomaticAction(state, 0, "lead-trump-pair")
	if err != nil || !engine.IsPair(action.Cards) || action.Cards[0].Suit != engine.Spades {
		t.Fatalf("automatic trump-pair lead = %+v, %v", action, err)
	}
}

func TestFallbackAndInitialBury(t *testing.T) {
	state := session(t)
	want, _ := engine.FallbackTrump(state.Bottom[0], engine.RankTwo)
	for i := 0; i < 4; i++ {
		state = apply(t, state, state.Turn, Pass)
	}
	if state.Phase != Bury || state.Trump != want || len(state.Hands[0]) != 33 || len(state.Bottom) != 0 {
		t.Fatal("fallback did not grant bottom to dealer")
	}
	buried := append([]engine.Card(nil), state.Hands[0][:8]...)
	state = apply(t, state, 0, BuryCards, buried...)
	if state.Phase != Counter || state.Turn != 1 || len(state.Hands[0]) != 25 || !reflect.DeepEqual(state.Bottom, buried) {
		t.Fatal("initial bury transition")
	}
	for i := 0; i < 3; i++ {
		state = apply(t, state, state.Turn, Pass)
	}
	if state.Phase != Playing || state.Turn != state.Dealer {
		t.Fatal("three passes must end counter polling")
	}
}

func counterState(t *testing.T) State {
	t.Helper()
	state := session(t)
	state.Phase, state.Turn = Counter, 1
	state.Declarer = 1
	declared := card(engine.Diamonds, engine.RankTwo, 0)
	state.DeclaredCard = &declared
	state.Trump.Suit = engine.Diamonds
	state.InitialBury = false
	state.Hands = [4][]engine.Card{}
	state.Hands[1] = append(pair(engine.Clubs, engine.RankTwo),
		pair(engine.NoSuit, engine.RankSmallJoker)...)
	state.Hands[1] = append(state.Hands[1], pair(engine.Hearts, engine.RankFive)...)
	state.Hands[1] = append(state.Hands[1], card(engine.Spades, engine.RankThree, 0))
	state.Hands[2] = pair(engine.NoSuit, engine.RankBigJoker)
	state.Hands[3] = pair(engine.Diamonds, engine.RankTwo)
	used := map[engine.Card]bool{}
	for _, hand := range state.Hands {
		for _, held := range hand {
			used[held] = true
		}
	}
	var remaining []engine.Card
	for _, candidate := range Deck() {
		if !used[candidate] {
			remaining = append(remaining, candidate)
		}
	}
	for seat := range state.Hands {
		need := 25 - len(state.Hands[seat])
		state.Hands[seat] = append(state.Hands[seat], remaining[:need]...)
		remaining = remaining[need:]
	}
	state.Bottom = remaining
	return state
}

func TestDeclarationSkipAndLookBack(t *testing.T) {
	state := session(t)
	// Declaration races are allowed from any seat until the fourth pass.
	proof := card(engine.Diamonds, engine.RankTwo, 0)
	state = apply(t, state, 1, Declare, proof)
	if state.Declarer != 1 || state.Trump.Suit != engine.Diamonds || state.Turn != 0 {
		t.Fatal("declaration changed the configured dealer or wrong trump")
	}
	state = apply(t, state, 0, BuryCards, state.Hands[0][:8]...)
	if state.Turn != 2 {
		t.Fatal("dealer's immediate downstream declarer must be skipped")
	}
	state = counterState(t)
	state = apply(t, state, 1, CounterTrump, pair(engine.Clubs, engine.RankTwo)...)
	if state.Phase != Bury || state.CounterKind != engine.CounterLevel || state.Trump.Suit != engine.Clubs {
		t.Fatal("level counter transition")
	}
	state = apply(t, state, 1, BuryCards, state.Hands[1][:8]...)
	if state.Turn != 2 {
		t.Fatal("polling did not resume after counter-burier")
	}
	state = apply(t, state, 2, CounterTrump, pair(engine.NoSuit, engine.RankBigJoker)...)
	state = apply(t, state, 2, BuryCards, state.Hands[2][:8]...)
	state = apply(t, state, 3, Pass)
	state = apply(t, state, 0, Pass)
	if state.Turn != 1 || state.CounterPasses != 2 {
		t.Fatal("declarer must reenter later polling")
	}
	state = apply(t, state, 1, LookBack)
	if !state.FinalTrump || state.Trump.Suit != engine.Diamonds || state.Phase != Bury {
		t.Fatal("look-back must restore original declaration")
	}
	state = apply(t, state, 1, BuryCards, state.Hands[1][:8]...)
	if state.Phase != Playing || state.Turn != state.Dealer {
		t.Fatal("final look-back bury must end polling")
	}
}

func TestCounterRulesAndPenalty(t *testing.T) {
	t.Run("red-five-requires-pair", func(t *testing.T) {
		state := counterState(t)
		state.Hands[1] = remove(state.Hands[1], []engine.Card{card(engine.Hearts, engine.RankFive, 1)})
		action := Action{Seat: 1, Kind: CounterTrump, RequestID: "r", ExpectedVersion: state.Version,
			Cards: []engine.Card{card(engine.Hearts, engine.RankFive, 0), card(engine.Spades, engine.RankThree, 0)}}
		if _, err := Apply(state, action, identity); !errors.Is(err, ErrCards) {
			t.Fatalf("single red five accepted: %v", err)
		}
	})
	t.Run("red-five-companion", func(t *testing.T) {
		state := counterState(t)
		state = apply(t, state, 1, CounterTrump,
			card(engine.Hearts, engine.RankFive, 0), card(engine.Spades, engine.RankThree, 0))
		if state.CounterKind != engine.CounterRedFive || state.Trump.Suit != engine.Spades {
			t.Fatal("red five companion did not set suit")
		}
	})
	t.Run("equal-counter-is-rejected", func(t *testing.T) {
		state := counterState(t)
		state.CounterKind = engine.CounterLevel
		action := Action{Seat: 1, Kind: CounterTrump, RequestID: "r", ExpectedVersion: state.Version,
			Cards: pair(engine.Clubs, engine.RankTwo)}
		if _, err := Apply(state, action, identity); !errors.Is(err, engine.ErrInvalidCounter) {
			t.Fatalf("equal counter accepted: %v", err)
		}
	})
	for _, seat := range []int{1, 2} {
		t.Run(fmt.Sprintf("lower-counter-seat-%d", seat), func(t *testing.T) {
			state := counterState(t)
			state.Turn = seat
			state.CounterKind = engine.CounterBigJoker
			state.Hands[seat] = pair(engine.Clubs, engine.RankTwo)
			state = apply(t, state, seat, CounterTrump, state.Hands[seat]...)
			want := 0
			if seat%2 == state.Dealer%2 {
				want = 200
			}
			if state.Result == nil || !state.Result.CounterFault || state.Result.DefenderScore != want || state.Phase != HandOver {
				t.Fatal("lower counter must lose the hand with the specified penalty")
			}
		})
	}
}

func TestApplyRejectsWithoutMutation(t *testing.T) {
	state := start(t, session(t))
	before, _ := json.Marshal(state)
	for _, action := range []Action{
		{Seat: -1, Kind: Pass},
		{Seat: 4, Kind: Pass},
		{Seat: 0, Kind: Pass},
		{Seat: 1, Kind: PlayCards, Cards: []engine.Card{state.Hands[1][0]}},
		{Seat: 0, Kind: PlayCards},
		{Seat: 0, Kind: PlayCards, Cards: []engine.Card{state.Hands[0][0], state.Hands[0][0]}},
		{Seat: 0, Kind: PlayCards, Cards: []engine.Card{{Rank: 255}}},
		{Seat: 0, Kind: PlayCards, Cards: []engine.Card{state.Hands[1][0]}},
		{Seat: 0, Kind: Declare, Cards: []engine.Card{state.Hands[0][0]}},
		{Seat: 0, Kind: LookBack},
		{Seat: 0, Kind: Continue},
		{Seat: 0, Kind: "unknown"},
	} {
		action.RequestID, action.ExpectedVersion = "r", state.Version
		if _, err := Apply(state, action, identity); err == nil {
			t.Fatalf("invalid action accepted: %+v", action)
		}
		after, _ := json.Marshal(state)
		if string(before) != string(after) {
			t.Fatal("failed action mutated input")
		}
	}
	if _, err := Apply(state, Action{Seat: 0, Kind: PlayCards, RequestID: "r",
		ExpectedVersion: state.Version - 1, Cards: state.Hands[0][:1]}, identity); !errors.Is(err, ErrVersion) {
		t.Fatalf("stale version: %v", err)
	}
	next := apply(t, state, state.Turn, PlayCards, state.Hands[state.Turn][0])
	next.Trick.Plays[0].Cards[0].Rank = 255
	after, _ := json.Marshal(state)
	if string(before) != string(after) {
		t.Fatal("successful action shared input storage")
	}
}

func TestStateJSONRoundTrip(t *testing.T) {
	state := counterState(t)
	state = apply(t, state, 1, CounterTrump, pair(engine.Clubs, engine.RankTwo)...)
	data, err := json.Marshal(state)
	if err != nil {
		t.Fatal(err)
	}
	var restored State
	if err := json.Unmarshal(data, &restored); err != nil {
		t.Fatal(err)
	}
	if !reflect.DeepEqual(state, restored) {
		t.Fatal("serialized state lost information")
	}
	state = apply(t, state, 1, BuryCards, state.Hands[1][:8]...)
	restored = apply(t, restored, 1, BuryCards, restored.Hands[1][:8]...)
	if !reflect.DeepEqual(state, restored) {
		t.Fatal("restored state cannot resume")
	}
}

func TestPersonalizedSnapshots(t *testing.T) {
	state := counterState(t)
	state.BottomOwner = 0
	state.CounterProof = pair(engine.NoSuit, engine.RankSmallJoker)
	for seat := -1; seat < 4; seat++ {
		view, err := View(state, seat)
		if err != nil {
			t.Fatal(err)
		}
		data, _ := json.Marshal(view)
		for _, hidden := range []string{`"hands"`, `"declared_card"`, `"counter_proof"`} {
			if strings.Contains(string(data), hidden) {
				t.Fatalf("snapshot leaked %s", hidden)
			}
		}
		if seat < 0 && (len(view.Hand) != 0 || len(view.Actions) != 0 || len(view.Bottom) != 0) {
			t.Fatal("spectator got private information")
		}
		if seat >= 0 && (len(view.Hand) != len(state.Hands[seat]) || !owns(view.Hand, state.Hands[seat])) {
			t.Fatal("own hand missing")
		}
		if seat != 0 && len(view.Bottom) != 0 {
			t.Fatal("bottom exposed to a non-owner")
		}
		if seat == 0 && len(view.Bottom) != 8 {
			t.Fatal("bottom owner cannot see bottom")
		}
		if seat >= 0 && len(view.Hand) > 0 {
			view.Hand[0].Rank = 255
			if state.Hands[seat][0].Rank == 255 {
				t.Fatal("view aliases private state")
			}
		}
		if seat == state.Turn {
			for _, option := range view.Actions {
				if option.Kind != CounterTrump && option.Kind != Pass {
					continue
				}
				if _, err := Apply(state, Action{Seat: seat, Kind: option.Kind, Cards: option.Cards,
					RequestID: "r", ExpectedVersion: state.Version}, identity); err != nil {
					t.Fatalf("offered action is illegal: %v", err)
				}
			}
		}
	}
	if _, err := View(state, 4); err == nil {
		t.Fatal("invalid viewer accepted")
	}
}

func TestSnapshotProjectsCounterBottomOwnerAndPublicCapture(t *testing.T) {
	state := counterState(t)
	if state.BottomOwner != -1 {
		t.Fatalf("unassigned bottom owner = %d, want -1", state.BottomOwner)
	}
	state.BottomOwner = 1
	state.CounterKind = engine.CounterLevel
	private, err := View(state, 1)
	if err != nil {
		t.Fatal(err)
	}
	if private.BottomOwner != 1 || private.CounterKind != engine.CounterLevel ||
		len(private.Bottom) != 8 || private.BottomPublic {
		t.Fatalf("private projection = %+v", private)
	}
	state.Phase = HandOver
	state.Result = &Result{BottomCaptured: true}
	public, err := View(state, -1)
	if err != nil {
		t.Fatal(err)
	}
	if !public.BottomPublic || len(public.Bottom) != 8 {
		t.Fatalf("captured bottom projection = %+v", public)
	}
}

func TestRepositoryIdempotencyIsolationAndPractice(t *testing.T) {
	repository := NewRepository(identity)
	cfg := config()
	cfg.Practice = true
	state, err := repository.Create(cfg)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := repository.Create(cfg); !errors.Is(err, ErrExists) {
		t.Fatalf("duplicate session: %v", err)
	}
	state.Hands[0][0].Rank = 255
	loaded, err := repository.Load(cfg.ID)
	if err != nil || loaded.Hands[0][0].Rank == 255 || !loaded.Practice {
		t.Fatal("repository shared mutable state or lost practice mode")
	}
	action := Action{Seat: 0, Kind: Pass, RequestID: "r", ExpectedVersion: loaded.Version}
	first, err := repository.Submit(cfg.ID, "a", action)
	if err != nil || first.Duplicate {
		t.Fatalf("first action: %v", err)
	}
	_, err = repository.Submit(cfg.ID, "b", Action{Seat: 1, Kind: Pass, RequestID: "r2",
		ExpectedVersion: first.Snapshot.Version})
	if err != nil {
		t.Fatal(err)
	}
	retry, err := repository.Submit(cfg.ID, "a", action)
	if err != nil || !retry.Duplicate || retry.Snapshot.Version != first.Snapshot.Version {
		t.Fatal("retry must return original result despite stale expected version")
	}
	action.Kind = Declare
	if _, err := repository.Submit(cfg.ID, "a", action); !errors.Is(err, ErrRequest) {
		t.Fatalf("request reuse: %v", err)
	}
	if _, err := repository.Submit(cfg.ID, "b", Action{Seat: 0, Kind: Pass, RequestID: "spoof",
		ExpectedVersion: 3}); !errors.Is(err, ErrInvalidAction) {
		t.Fatalf("actor spoofing: %v", err)
	}
	if _, err := repository.Snapshot(cfg.ID, "outsider"); err == nil {
		t.Fatal("nonparticipant received a personalized snapshot")
	}
	view, err := repository.Snapshot(cfg.ID, "a")
	if err != nil {
		t.Fatal(err)
	}
	view.Hand[0].Rank = 255
	loaded, _ = repository.Load(cfg.ID)
	if loaded.Hands[0][0].Rank == 255 {
		t.Fatal("repository snapshot aliases stored state")
	}
	// Practice data has no path into another repository or a durable adapter.
	fresh := NewRepository(identity)
	if _, err := fresh.Load(cfg.ID); !errors.Is(err, ErrNotFound) {
		t.Fatal("practice session survived repository replacement")
	}
	repository.Delete(cfg.ID)
	if _, err := repository.Load(cfg.ID); !errors.Is(err, ErrNotFound) {
		t.Fatal("deleted session remained in memory")
	}
	if _, err := repository.Submit(cfg.ID, "a", action); !errors.Is(err, ErrNotFound) {
		t.Fatal("deleted receipt remained accessible")
	}
}

func TestConcurrentRetries(t *testing.T) {
	repository := NewRepository(identity)
	state, err := repository.Create(config())
	if err != nil {
		t.Fatal(err)
	}
	action := Action{Seat: 0, Kind: Pass, RequestID: "r", ExpectedVersion: state.Version}
	var wait sync.WaitGroup
	errs := make(chan error, 16)
	for i := 0; i < cap(errs); i++ {
		wait.Add(1)
		go func() {
			defer wait.Done()
			_, err := repository.Submit(state.ID, "a", action)
			errs <- err
		}()
	}
	wait.Wait()
	close(errs)
	for err := range errs {
		if err != nil {
			t.Fatal(err)
		}
	}

	loaded, _ := repository.Load(state.ID)
	if loaded.Version != state.Version+1 || loaded.DeclarationPasses != 1 {
		t.Fatal("concurrent retry applied more than once")
	}
}

func TestRejectedRequestDoesNotReserveID(t *testing.T) {
	repository := NewRepository(identity)
	state, err := repository.Create(config())
	if err != nil {
		t.Fatal(err)
	}
	action := Action{Seat: 0, Kind: Continue, RequestID: "retry", ExpectedVersion: state.Version}
	if _, err := repository.Submit(state.ID, "a", action); !errors.Is(err, ErrPhase) {
		t.Fatal("invalid request was accepted")
	}
	action.Kind = Pass
	if _, err := repository.Submit(state.ID, "a", action); err != nil {
		t.Fatalf("failed request reserved its ID: %v", err)
	}
	action.RequestID = "stale"
	if _, err := repository.Submit(state.ID, "a", action); !errors.Is(err, ErrVersion) {
		t.Fatalf("distinct stale request accepted: %v", err)
	}
}
