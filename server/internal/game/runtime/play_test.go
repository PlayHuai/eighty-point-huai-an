package runtime

import (
	"encoding/json"
	"errors"
	"fmt"
	"math/rand"
	"reflect"
	"testing"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"
)

func playingState(t *testing.T) State {
	t.Helper()
	state := session(t)
	state.Phase, state.Turn, state.Dealer = Playing, 0, 0
	state.Trump = engine.Trump{Suit: engine.Spades, Level: engine.RankTwo}
	state.Hands = [4][]engine.Card{}
	state.Trick = Trick{Leader: 0, Winner: 0}
	state.BottomOwner = 0
	return state
}

func TestFollowEffectiveSuitAndStructure(t *testing.T) {
	state := playingState(t)
	club3 := card(engine.Clubs, engine.RankThree, 0)
	club4 := card(engine.Clubs, engine.RankFour, 0)
	spade3 := card(engine.Spades, engine.RankThree, 0)
	heart2 := card(engine.Hearts, engine.RankTwo, 0)
	red5 := card(engine.Hearts, engine.RankFive, 0)
	for _, test := range []struct {
		name     string
		hand     []engine.Card
		lead     []engine.Card
		response []engine.Card
		valid    bool
	}{
		{"follow-side", []engine.Card{club3, spade3}, []engine.Card{club4}, []engine.Card{club3}, true},
		{"cannot-cut-held-side", []engine.Card{club3, spade3}, []engine.Card{club4}, []engine.Card{spade3}, false},
		{"level-is-trump", []engine.Card{heart2, club3}, []engine.Card{spade3}, []engine.Card{heart2}, true},
		{"must-follow-effective-trump", []engine.Card{heart2, club3}, []engine.Card{spade3}, []engine.Card{club3}, false},
		{"red-five-is-not-ordinary-heart", []engine.Card{red5, club3},
			[]engine.Card{card(engine.Hearts, engine.RankThree, 0)}, []engine.Card{club3}, true},
		{"joker-lead-follow-trump", []engine.Card{spade3, club3},
			[]engine.Card{card(engine.NoSuit, engine.RankSmallJoker, 0)}, []engine.Card{spade3}, true},
		{"partial-suit-must-use-all", []engine.Card{club3, spade3, red5},
			pair(engine.Clubs, engine.RankFour), []engine.Card{spade3, red5}, false},
		{"partial-suit-then-discard", []engine.Card{club3, spade3, red5},
			pair(engine.Clubs, engine.RankFour), []engine.Card{club3, red5}, true},
		{"must-follow-pair", append(pair(engine.Clubs, engine.RankThree), club4),
			pair(engine.Clubs, engine.RankSix), []engine.Card{club3, club4}, false},
		{"no-pair-can-follow-singles", []engine.Card{club3, club4},
			pair(engine.Clubs, engine.RankSix), []engine.Card{club3, club4}, true},
		{"wrong-count", []engine.Card{club3, club4}, []engine.Card{club4}, []engine.Card{club3, club4}, false},
	} {
		t.Run(test.name, func(t *testing.T) {
			err := state.validateFollow(test.hand, test.lead, test.response)
			if (err == nil) != test.valid {
				t.Fatalf("valid=%v, error=%v", test.valid, err)
			}
		})
	}
	tractor := append(pair(engine.Clubs, engine.RankThree), pair(engine.Clubs, engine.RankFour)...)
	hand := append(append([]engine.Card(nil), tractor...), pair(engine.Clubs, engine.RankSeven)...)
	broken := append(pair(engine.Clubs, engine.RankThree), pair(engine.Clubs, engine.RankSeven)...)
	if err := state.validateFollow(hand, tractor, broken); err == nil {
		t.Fatal("tractor in hand must be followed")
	}
	if err := state.validateFollow(hand, tractor, tractor); err != nil {
		t.Fatal(err)
	}
	state.Trump.Suit = engine.NoSuit
	if err := state.validateFollow([]engine.Card{red5, club3},
		[]engine.Card{card(engine.Hearts, engine.RankThree, 0)}, []engine.Card{club3}); err == nil {
		t.Fatal("red five is an ordinary heart in no-trump games")
	}
}

func TestLeadThrowsAnd510K(t *testing.T) {
	state := playingState(t)
	state.Hands[1] = []engine.Card{card(engine.Clubs, engine.RankAce, 0)}
	lowerThrow := []engine.Card{card(engine.Clubs, engine.RankThree, 0), card(engine.Clubs, engine.RankFour, 0)}
	if err := state.validateLead(lowerThrow); err == nil {
		t.Fatal("nonmaximum throw accepted")
	}
	winningThrow := []engine.Card{card(engine.Diamonds, engine.RankAce, 0), card(engine.Diamonds, engine.RankKing, 0)}
	if err := state.validateLead(winningThrow); err != nil {
		t.Fatalf("maximum throw rejected: %v", err)
	}
	mixed := []engine.Card{card(engine.Diamonds, engine.RankThree, 0), card(engine.Clubs, engine.RankFour, 0)}
	if err := state.validateLead(mixed); err == nil {
		t.Fatal("ordinary mixed-suit lead accepted")
	}
	main := fiveTenKing(engine.Spades)
	if err := state.validateLead(main); err != nil {
		t.Fatal(err)
	}
	if err := state.validateLead(append(append([]engine.Card(nil), main...),
		card(engine.Spades, engine.RankAce, 0))); err == nil {
		t.Fatal("main 510k cannot carry more trump")
	}
	if err := state.validateLead(append(append([]engine.Card(nil), main...),
		card(engine.Diamonds, engine.RankAce, 0))); err != nil {
		t.Fatalf("main 510k with maximum side card: %v", err)
	}
	if err := state.validateLead(fiveTenKing(engine.Hearts)); err != nil {
		t.Fatalf("side 510k must remain a combination despite red-five trump: %v", err)
	}
}

func TestMain510KForcedDraw(t *testing.T) {
	state := playingState(t)
	lead := fiveTenKing(engine.Spades)
	hand := []engine.Card{
		card(engine.Hearts, engine.RankFive, 0),
		card(engine.NoSuit, engine.RankBigJoker, 0),
		card(engine.NoSuit, engine.RankSmallJoker, 0),
		card(engine.Spades, engine.RankAce, 0),
		card(engine.Clubs, engine.RankThree, 0),
	}
	if err := state.validateFollow(hand, lead, hand[:3]); err != nil {
		t.Fatalf("largest three trumps rejected: %v", err)
	}
	if err := state.validateFollow(hand, lead, hand[1:4]); err == nil {
		t.Fatal("failed to draw red five")
	}
	short := []engine.Card{hand[0], hand[4], card(engine.Diamonds, engine.RankThree, 0),
		card(engine.Clubs, engine.RankAce, 0)}
	if err := state.validateFollow(short, lead, []engine.Card{short[0], short[1], short[3]}); err != nil {
		t.Fatal("arbitrary side fillers should be allowed with fewer than three trumps")
	}
	compound := append(append([]engine.Card(nil), lead...), card(engine.Diamonds, engine.RankAce, 0))
	compoundHand := append(append([]engine.Card(nil), hand...), card(engine.Diamonds, engine.RankThree, 0))
	response := append(append([]engine.Card(nil), hand[:3]...), compoundHand[5])
	if err := state.validateFollow(compoundHand, compound, response); err != nil {
		t.Fatalf("main draw plus side follow rejected: %v", err)
	}
	response[3] = hand[4]
	if err := state.validateFollow(compoundHand, compound, response); err == nil {
		t.Fatal("main draw cannot bypass the carried side suit")
	}
}

func TestTrickWinnerAndPoints(t *testing.T) {
	state := playingState(t)
	state.Hands[0] = []engine.Card{card(engine.Clubs, engine.RankTen, 0), card(engine.Diamonds, engine.RankThree, 0)}
	state.Hands[1] = []engine.Card{card(engine.Spades, engine.RankThree, 0), card(engine.Diamonds, engine.RankFour, 0)}
	state.Hands[2] = []engine.Card{card(engine.Clubs, engine.RankKing, 0), card(engine.Diamonds, engine.RankSix, 0)}
	state.Hands[3] = []engine.Card{card(engine.Clubs, engine.RankFive, 0), card(engine.Diamonds, engine.RankSeven, 0)}
	for seat := 0; seat < 4; seat++ {
		state = apply(t, state, seat, PlayCards, state.Hands[seat][0])
	}
	if state.DefenderPoints != 25 || state.Turn != 1 || state.Trick.Leader != 1 || len(state.Completed) != 1 {
		t.Fatal("cutting defender must win points and lead next trick")
	}
}

func TestTrickComparisonEligibility(t *testing.T) {
	state := playingState(t)
	for _, test := range []struct {
		name string
		lead []engine.Card
		next []engine.Card
		win  bool
	}{
		{"off-suit-ace-does-not-win", []engine.Card{card(engine.Clubs, engine.RankThree, 0)},
			[]engine.Card{card(engine.Diamonds, engine.RankAce, 0)}, false},
		{"trump-cuts", []engine.Card{card(engine.Clubs, engine.RankAce, 0)},
			[]engine.Card{card(engine.Spades, engine.RankThree, 0)}, true},
		{"joker-lead", []engine.Card{card(engine.NoSuit, engine.RankSmallJoker, 0)},
			[]engine.Card{card(engine.NoSuit, engine.RankBigJoker, 0)}, true},
		{"pair-requires-pair", pair(engine.Clubs, engine.RankThree),
			[]engine.Card{card(engine.Spades, engine.RankAce, 0), card(engine.Spades, engine.RankKing, 0)}, false},
		{"off-suit-510k", fiveTenKing(engine.Clubs), fiveTenKing(engine.Diamonds), false},
		{"main-510k", fiveTenKing(engine.Clubs), fiveTenKing(engine.Spades), true},
		{"equal-keeps-earlier", pair(engine.Clubs, engine.RankThree), pair(engine.Clubs, engine.RankThree), false},
	} {
		t.Run(test.name, func(t *testing.T) {
			if got := state.beats(test.next, test.lead, test.lead); got != test.win {
				t.Fatalf("winner comparison %v, want %v", got, test.win)
			}
		})
	}
}

func TestFullDealsConservationSettlementAndContinue(t *testing.T) {
	for seed := int64(0); seed < 12; seed++ {
		t.Run(fmt.Sprint(seed), func(t *testing.T) {
			random := rand.New(rand.NewSource(seed))
			shuffle := func(cards []engine.Card) {
				random.Shuffle(len(cards), func(i, j int) { cards[i], cards[j] = cards[j], cards[i] })
			}
			state, err := NewSession(config(), shuffle)
			if err != nil {
				t.Fatal(err)
			}
			state = start(t, state)
			for state.Phase == Playing {
				var selection []engine.Card
				for _, candidate := range state.Hands[state.Turn] {
					if len(state.Trick.Plays) == 0 || state.validateFollow(
						state.Hands[state.Turn], state.Trick.Plays[0].Cards, []engine.Card{candidate}) == nil {
						selection = []engine.Card{candidate}
						break
					}
				}
				if len(selection) == 0 {
					t.Fatal("no legal single response")
				}
				before, _ := json.Marshal(state)
				state = apply(t, state, state.Turn, PlayCards, selection...)
				if !json.Valid(before) {
					t.Fatal("state was not serializable")
				}
			}
			if state.Phase != HandOver || state.Result == nil || len(state.Completed) != 25 {
				t.Fatal("complete deal did not settle once")
			}
			all := append([]engine.Card(nil), state.Bottom...)
			for _, trick := range state.Completed {
				if len(trick.Plays) != 4 {
					t.Fatal("incomplete archived trick")
				}
				for _, play := range trick.Plays {
					all = append(all, play.Cards...)
				}
			}
			if len(all) != 108 || !unique(all) {
				t.Fatal("full deal lost physical cards")
			}
			oldLevels, nextDealer := state.Levels, state.Result.NextDealer
			for seat := 0; seat < 4; seat++ {
				state = apply(t, state, seat, Continue)
				if seat < 3 && state.Phase != HandOver {
					t.Fatal("continued before all players acknowledged")
				}
			}
			if state.Phase != Declaration || state.HandNumber != 2 || state.Dealer != nextDealer ||
				state.Levels != oldLevels || state.Trump.Level != oldLevels[nextDealer%2] ||
				len(state.Completed) != 0 || state.Result != nil {
				t.Fatal("next hand was not reset correctly")
			}
		})
	}
}

func TestBottomScoringAndSpecialSettlement(t *testing.T) {
	state := playingState(t)
	state.Hands[0] = []engine.Card{card(engine.Clubs, engine.RankThree, 0)}
	state.Hands[1] = []engine.Card{card(engine.Clubs, engine.RankAce, 0)}
	state.Hands[2] = []engine.Card{card(engine.Clubs, engine.RankKing, 0)}
	state.Hands[3] = []engine.Card{card(engine.Clubs, engine.RankFive, 0)}
	state.Bottom = []engine.Card{card(engine.Diamonds, engine.RankTen, 0)}
	for seat := 0; seat < 4; seat++ {
		state = apply(t, state, seat, PlayCards, state.Hands[seat][0])
	}
	if state.Result.DefenderScore != 35 || state.Result.NextDealer != 2 {
		t.Fatalf("bottom score/next dealer: %+v", state.Result)
	}
	for _, test := range []struct {
		name        string
		level       engine.Rank
		score       int
		final       []engine.Card
		winner      int
		wantLevel   engine.Rank
		wantNext    int
		wantGameWon bool
	}{
		{"mandatory-J-stop", engine.RankTen, 0, nil, 0, engine.RankJack, 2, false},
		{"J-comeback-under-80", engine.RankJack, 70,
			[]engine.Card{card(engine.Clubs, engine.RankJack, 0)}, 1, engine.RankThree, 2, false},
		{"A-low-score-wins", engine.RankAce, 75,
			[]engine.Card{card(engine.Clubs, engine.RankAce, 0)}, 1, engine.RankAce, 2, true},
		{"A-pair-comeback", engine.RankAce, 80, pair(engine.Clubs, engine.RankAce), 1, engine.RankTwo, 1, false},
	} {
		t.Run(test.name, func(t *testing.T) {
			s := playingState(t)
			s.Levels[0], s.Trump.Level = test.level, test.level
			if err := s.settle(test.score, test.final, test.winner, false); err != nil {
				t.Fatal(err)
			}
			if s.Levels[0] != test.wantLevel || s.Result.NextDealer != test.wantNext ||
				s.Result.Resolution.GameWon != test.wantGameWon {
				t.Fatalf("settlement %+v levels %v", s.Result, s.Levels)
			}
		})
	}
}

func TestBottomMultipliersThroughPlay(t *testing.T) {
	for _, test := range []struct {
		name  string
		hands [4][]engine.Card
		score int
	}{
		{"pair", [4][]engine.Card{
			pair(engine.Clubs, engine.RankThree), pair(engine.Clubs, engine.RankAce),
			pair(engine.Clubs, engine.RankKing), pair(engine.Clubs, engine.RankFive),
		}, 70},
		{"tractor", [4][]engine.Card{
			append(pair(engine.Clubs, engine.RankThree), pair(engine.Clubs, engine.RankFour)...),
			append(pair(engine.Clubs, engine.RankSix), pair(engine.Clubs, engine.RankSeven)...),
			append(pair(engine.Clubs, engine.RankEight), pair(engine.Clubs, engine.RankNine)...),
			append(pair(engine.Clubs, engine.RankQueen), pair(engine.Clubs, engine.RankKing)...),
		}, 100},
		{"dealer-keeps-bottom", [4][]engine.Card{
			pair(engine.Clubs, engine.RankAce), pair(engine.Clubs, engine.RankThree),
			pair(engine.Clubs, engine.RankKing), pair(engine.Clubs, engine.RankFive),
		}, 0},
	} {
		t.Run(test.name, func(t *testing.T) {
			state := playingState(t)
			state.Hands = test.hands
			state.Bottom = []engine.Card{card(engine.Diamonds, engine.RankTen, 0)}
			for seat := 0; seat < 4; seat++ {
				state = apply(t, state, seat, PlayCards, state.Hands[seat]...)
			}
			if state.Result.DefenderScore != test.score {
				t.Fatalf("score %d, want %d", state.Result.DefenderScore, test.score)
			}
		})
	}
}

func TestIncomingTeamCannotSkipItsMandatoryLevel(t *testing.T) {
	for _, level := range []engine.Rank{engine.RankTwo, engine.RankJack} {
		state := playingState(t)
		state.Trump.Level, state.Levels[0], state.Levels[1] = engine.RankTen, engine.RankTen, level
		if err := state.settle(200, nil, 1, false); err != nil {
			t.Fatal(err)
		}
		if state.Levels[1] != level {
			t.Fatalf("incoming team skipped mandatory %v to %v", level, state.Levels[1])
		}
	}
}

func TestSkyEarthAndSpring(t *testing.T) {
	state := playingState(t)
	state.Hands[0] = fiveTenKing(engine.Clubs)
	state.Hands[1] = fiveTenKing(engine.Spades)
	state.Hands[2] = []engine.Card{card(engine.Diamonds, engine.RankThree, 0),
		card(engine.Diamonds, engine.RankFour, 0), card(engine.Diamonds, engine.RankSix, 0)}
	state.Hands[3] = []engine.Card{card(engine.Hearts, engine.RankThree, 0),
		card(engine.Hearts, engine.RankFour, 0), card(engine.Hearts, engine.RankSix, 0)}
	for seat := 0; seat < 4; seat++ {
		state = apply(t, state, seat, PlayCards, state.Hands[seat]...)
	}
	if !state.Result.SkyEarth || state.Result.WinnerTeam != 1 ||
		state.Levels != [2]engine.Rank{engine.RankTwo, engine.RankAce} ||
		state.FirstSkyTeam == nil || *state.FirstSkyTeam != 1 || state.Result.NextDealer != 1 {
		t.Fatalf("main 510k countercut did not transfer sky-earth: %+v", state.Result)
	}
	for seat := 0; seat < 4; seat++ {
		state = apply(t, state, seat, Continue)
	}
	if state.Dealer != 1 || state.Trump.Level != engine.RankAce {
		t.Fatal("sky-earth did not prepare A vs 2")
	}
	if err := state.settle(75, nil, state.Dealer, false); err != nil {
		t.Fatal(err)
	}
	if state.Phase != Finished || !state.Result.Spring {
		t.Fatal("two-hand spring not recognized")
	}
	action := Action{Seat: 0, Kind: Continue, RequestID: "end", ExpectedVersion: state.Version}
	if _, err := Apply(state, action, identity); !errors.Is(err, ErrPhase) {
		t.Fatal("finished match can continue")
	}
}

func TestFinal510KWithCarriedSideCard(t *testing.T) {
	state := playingState(t)
	state.Hands[0] = append(fiveTenKing(engine.Spades), card(engine.Diamonds, engine.RankAce, 0))
	state.Hands[1] = []engine.Card{
		card(engine.NoSuit, engine.RankBigJoker, 0), card(engine.NoSuit, engine.RankSmallJoker, 0),
		card(engine.Clubs, engine.RankTwo, 0), card(engine.Diamonds, engine.RankThree, 0),
	}
	state.Hands[2] = []engine.Card{
		card(engine.Hearts, engine.RankFive, 0), card(engine.Spades, engine.RankAce, 0),
		card(engine.Diamonds, engine.RankTwo, 0), card(engine.Diamonds, engine.RankFour, 0),
	}
	state.Hands[3] = []engine.Card{
		card(engine.Clubs, engine.RankThree, 0), card(engine.Clubs, engine.RankFour, 0),
		card(engine.Clubs, engine.RankSix, 0), card(engine.Diamonds, engine.RankSix, 0),
	}
	for seat := 0; seat < 4; seat++ {
		state = apply(t, state, seat, PlayCards, state.Hands[seat]...)
	}
	if !state.Result.SkyEarth || state.Result.WinnerTeam != 0 ||
		state.Levels != [2]engine.Rank{engine.RankAce, engine.RankTwo} {
		t.Fatal("a final 510k throw with side cards must retain sky-earth")
	}
}

func TestContinueIsTransactionalOnBadShuffle(t *testing.T) {
	state := playingState(t)
	if err := state.settle(75, nil, 0, false); err != nil {
		t.Fatal(err)
	}
	for seat := 0; seat < 3; seat++ {
		state = apply(t, state, seat, Continue)
	}
	before := clone(state)
	_, err := Apply(state, Action{Seat: 3, Kind: Continue, RequestID: "last",
		ExpectedVersion: state.Version}, func(cards []engine.Card) { cards[0] = cards[1] })
	if !errors.Is(err, ErrCards) || !reflect.DeepEqual(before, state) {
		t.Fatal("failed redeal mutated ready flags or settlement")
	}
}
