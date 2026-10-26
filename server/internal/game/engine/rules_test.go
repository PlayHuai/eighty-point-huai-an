package engine

import (
	"strconv"
	"testing"
)

func card(suit Suit, rank Rank, copy uint8) Card {
	return Card{Suit: suit, Rank: rank, Copy: copy}
}

func TestCompareCards(t *testing.T) {
	trump := Trump{Suit: Clubs, Level: RankTwo}
	tests := []struct {
		name string
		a    Card
		b    Card
		want int
		err  error
	}{
		{"red five beats big joker", card(Hearts, RankFive, 0), card(NoSuit, RankBigJoker, 0), 1, nil},
		{"big joker beats small joker", card(NoSuit, RankBigJoker, 0), card(NoSuit, RankSmallJoker, 0), 1, nil},
		{"main level beats off-suit level", card(Clubs, RankTwo, 0), card(Hearts, RankTwo, 0), 1, nil},
		{"off-suit level beats main suit ace", card(Diamonds, RankTwo, 0), card(Clubs, RankAce, 0), 1, nil},
		{"main suit ace beats main suit king", card(Clubs, RankAce, 0), card(Clubs, RankKing, 0), 1, nil},
		{"different side suits are incomparable", card(Hearts, RankAce, 0), card(Spades, RankKing, 0), 0, ErrDifferentSuits},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			got, err := CompareCards(test.a, test.b, trump)
			if got != test.want || err != test.err {
				t.Fatalf("CompareCards() = (%d, %v), want (%d, %v)", got, err, test.want, test.err)
			}
		})
	}

	noTrump := Trump{Suit: NoSuit, Level: RankTwo}
	if !IsTrump(card(Spades, RankTwo, 0), noTrump) || IsTrump(card(Spades, RankAce, 0), noTrump) ||
		IsTrump(card(Hearts, RankFive, 0), noTrump) {
		t.Fatal("no-trump should retain only level cards and jokers as trumps")
	}
}

func TestTrumpSelection(t *testing.T) {
	trump, err := TrumpFromLevelCard(card(Spades, RankTwo, 0), RankTwo)
	if err != nil || trump != (Trump{Suit: Spades, Level: RankTwo}) {
		t.Fatalf("TrumpFromLevelCard() = (%+v, %v)", trump, err)
	}
	if _, err := TrumpFromLevelCard(card(Spades, RankAce, 0), RankTwo); err == nil {
		t.Fatal("a non-level card cannot select trump")
	}

	tests := []struct {
		name string
		top  Card
		suit Suit
	}{
		{"ordinary card selects its suit", card(Diamonds, RankAce, 0), Diamonds},
		{"level card selects no-trump", card(Clubs, RankTwo, 0), NoSuit},
		{"joker selects no-trump", card(NoSuit, RankBigJoker, 0), NoSuit},
		{"red five selects no-trump", card(Hearts, RankFive, 0), NoSuit},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			got, err := FallbackTrump(test.top, RankTwo)
			if err != nil || got != (Trump{Suit: test.suit, Level: RankTwo}) {
				t.Fatalf("FallbackTrump() = (%+v, %v)", got, err)
			}
		})
	}
}

func TestClassifyPairTractorAnd510K(t *testing.T) {
	trump := Trump{Suit: Clubs, Level: RankTwo}
	tests := []struct {
		name  string
		cards []Card
		want  PlayKind
		valid bool
	}{
		{"pair", []Card{card(Hearts, RankAce, 0), card(Hearts, RankAce, 1)}, PlayPair, true},
		{"tractor", []Card{card(Hearts, RankFive, 0), card(Hearts, RankFive, 1), card(Hearts, RankSix, 0), card(Hearts, RankSix, 1)}, PlayTractor, true},
		{"two nonconsecutive pairs", []Card{card(Hearts, RankFive, 0), card(Hearts, RankFive, 1), card(Hearts, RankSeven, 0), card(Hearts, RankSeven, 1)}, PlayTwoPairs, true},
		{"level card cannot form a tractor", []Card{card(Hearts, RankTwo, 0), card(Hearts, RankTwo, 1), card(Hearts, RankThree, 0), card(Hearts, RankThree, 1)}, PlayTwoPairs, true},
		{"duplicate physical copy is not a pair", []Card{card(Hearts, RankAce, 0), card(Hearts, RankAce, 0)}, 0, false},
		{"same-suit 510K", []Card{card(Spades, RankKing, 0), card(Spades, RankFive, 0), card(Spades, RankTen, 1)}, Play510K, true},
		{"mixed-suit 510K rejected", []Card{card(Spades, RankFive, 0), card(Spades, RankTen, 1), card(Hearts, RankKing, 0)}, 0, false},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			got, err := ClassifyPlay(test.cards, trump)
			if test.valid {
				if err != nil || got.Kind != test.want {
					t.Fatalf("ClassifyPlay() = (%+v, %v), want kind %v", got, err, test.want)
				}
			} else if err == nil {
				t.Fatalf("ClassifyPlay() = %+v, want an error", got)
			}
		})
	}
	if IsTractor([]Card{
		card(Hearts, RankTwo, 0), card(Hearts, RankTwo, 1),
		card(Hearts, RankThree, 0), card(Hearts, RankThree, 1),
	}, trump) {
		t.Fatal("a level pair cannot connect to a same-suit side pair")
	}

	if !Has510K([]Card{card(Clubs, RankFive, 0), card(Clubs, RankTen, 0), card(Clubs, RankKing, 0), card(Hearts, RankAce, 0)}) {
		t.Fatal("510K with other cards should be recognized as a component")
	}
}

func TestCompare510K(t *testing.T) {
	main := []Card{card(Clubs, RankFive, 0), card(Clubs, RankTen, 0), card(Clubs, RankKing, 0)}
	side := []Card{card(Hearts, RankFive, 0), card(Hearts, RankTen, 0), card(Hearts, RankKing, 0)}
	got, err := Compare510K(main, side, Trump{Suit: Clubs, Level: RankTwo})
	if err != nil || got != 1 {
		t.Fatalf("main 510K comparison = (%d, %v), want (1, nil)", got, err)
	}
	got, err = Compare510K(main, side, Trump{Suit: NoSuit, Level: RankTwo})
	if err != nil || got != 0 {
		t.Fatalf("no-trump 510K comparison = (%d, %v), want (0, nil)", got, err)
	}
}

func TestComparePlays(t *testing.T) {
	trump := Trump{Suit: Clubs, Level: RankTwo}
	tests := []struct {
		name      string
		candidate []Card
		incumbent []Card
		leadSuit  Suit
		want      int
		wantErr   bool
	}{
		{"higher card of led suit wins", []Card{card(Hearts, RankAce, 0)}, []Card{card(Hearts, RankKing, 0)}, Hearts, 1, false},
		{"trump beats led suit", []Card{card(Clubs, RankAce, 0)}, []Card{card(Hearts, RankAce, 0)}, Hearts, 1, false},
		{"led suit beats an off-suit discard", []Card{card(Hearts, RankKing, 0)}, []Card{card(Spades, RankAce, 0)}, Hearts, 1, false},
		{"a higher off-suit card cannot win", []Card{card(Spades, RankAce, 0)}, []Card{card(Hearts, RankKing, 0)}, Hearts, -1, false},
		{"main 510K beats side 510K", []Card{card(Clubs, RankFive, 0), card(Clubs, RankTen, 0), card(Clubs, RankKing, 0)}, []Card{card(Hearts, RankFive, 0), card(Hearts, RankTen, 0), card(Hearts, RankKing, 0)}, Hearts, 1, false},
		{"different shapes cannot be compared", []Card{card(Hearts, RankAce, 0)}, []Card{card(Hearts, RankAce, 0), card(Hearts, RankAce, 1)}, Hearts, 0, true},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			got, err := ComparePlays(test.candidate, test.incumbent, test.leadSuit, trump)
			if (err != nil) != test.wantErr || got != test.want {
				t.Fatalf("ComparePlays() = (%d, %v), want (%d, error=%v)", got, err, test.want, test.wantErr)
			}
		})
	}
}

func TestCounterTrump(t *testing.T) {
	tests := []struct {
		name  string
		cards []Card
		suit  Suit
		kind  CounterKind
		valid bool
	}{
		{"same-suit level pair", []Card{card(Spades, RankTwo, 0), card(Spades, RankTwo, 1)}, Spades, CounterLevel, true},
		{"small joker pair is no-trump", []Card{card(NoSuit, RankSmallJoker, 0), card(NoSuit, RankSmallJoker, 1)}, NoSuit, CounterSmallJoker, true},
		{"big joker pair is no-trump", []Card{card(NoSuit, RankBigJoker, 0), card(NoSuit, RankBigJoker, 1)}, NoSuit, CounterBigJoker, true},
		{"red five with level gives no-trump", []Card{card(Hearts, RankFive, 0), card(Clubs, RankTwo, 0)}, NoSuit, CounterRedFive, true},
		{"red five with ordinary card selects its suit", []Card{card(Hearts, RankFive, 1), card(Spades, RankAce, 0)}, Spades, CounterRedFive, true},
		{"unrecognized pair rejected", []Card{card(Clubs, RankAce, 0), card(Clubs, RankAce, 1)}, NoSuit, 0, false},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			got, kind, err := DetermineCounterTrump(test.cards, RankTwo)
			if test.valid {
				if err != nil || got.Suit != test.suit || kind != test.kind {
					t.Fatalf("DetermineCounterTrump() = (%+v, %v, %v)", got, kind, err)
				}
			} else if err == nil {
				t.Fatalf("DetermineCounterTrump() = (%+v, %v), want an error", got, kind)
			}
		})
	}

	if got, err := CompareCounterTrump(CounterRedFive, CounterBigJoker); err != nil || got != 1 {
		t.Fatalf("red-five counter should beat big joker: (%d, %v)", got, err)
	}
}

func TestPointsAndBottomMultiplier(t *testing.T) {
	points, err := Points([]Card{
		card(Clubs, RankFive, 0),
		card(Hearts, RankTen, 0),
		card(Spades, RankKing, 1),
		card(Diamonds, RankAce, 0),
	})
	if err != nil || points != 25 {
		t.Fatalf("Points() = (%d, %v), want (25, nil)", points, err)
	}
	tests := []struct {
		kind       PlayKind
		pairs      int
		multiplier int
	}{
		{PlaySingle, 0, 2},
		{PlayPair, 1, 4},
		{PlayTwoPairs, 2, 8},
		{PlayTractor, 2, 8},
		{PlayTractor, 3, 16},
		{PlayTractor, 4, 32},
	}
	for _, test := range tests {
		got, err := BottomMultiplier(test.kind, test.pairs)
		if err != nil || got != test.multiplier {
			t.Errorf("BottomMultiplier(%v, %d) = (%d, %v), want %d", test.kind, test.pairs, got, err, test.multiplier)
		}
	}
	for _, test := range []struct {
		kind  PlayKind
		pairs int
	}{
		{PlaySingle, 1},
		{PlayPair, 0},
		{PlayTwoPairs, 1},
		{Play510K, 3},
	} {
		if _, err := BottomMultiplier(test.kind, test.pairs); err != ErrInvalidPlay {
			t.Errorf("BottomMultiplier(%v, %d) error = %v, want ErrInvalidPlay", test.kind, test.pairs, err)
		}
	}
	got, err := ScoreHand(35, 15, true, PlayPair, 1)
	if err != nil || got != 95 {
		t.Fatalf("ScoreHand() = (%d, %v), want (95, nil)", got, err)
	}
	got, err = ScoreHand(35, 15, false, PlayPair, 1)
	if err != nil || got != 35 {
		t.Fatalf("ScoreHand without captured bottom = (%d, %v), want (35, nil)", got, err)
	}
}

func TestValidateResponse(t *testing.T) {
	trump := Trump{Suit: Clubs, Level: RankTwo}
	lead := []Card{card(Hearts, RankAce, 0)}
	tests := []struct {
		name     string
		lead     []Card
		hand     []Card
		response []Card
		wantErr  bool
	}{
		{"must follow suit when available", lead, []Card{lead[0], card(Clubs, RankAce, 0)}, []Card{card(Clubs, RankAce, 0)}, true},
		{"follows suit", lead, []Card{lead[0], card(Clubs, RankAce, 0)}, []Card{lead[0]}, false},
		{"void may cut with matching single", lead, []Card{card(Clubs, RankAce, 0)}, []Card{card(Clubs, RankAce, 0)}, false},
		{"void cannot cut with mismatched shape", []Card{card(Hearts, RankFive, 0), card(Hearts, RankFive, 1), card(Hearts, RankSix, 0), card(Hearts, RankSix, 1)}, []Card{card(Clubs, RankTwo, 0), card(Clubs, RankTwo, 1), card(Clubs, RankFive, 0), card(Clubs, RankFive, 1)}, []Card{card(Clubs, RankTwo, 0), card(Clubs, RankTwo, 1), card(Clubs, RankFive, 0), card(Clubs, RankFive, 1)}, true},
		{"cannot play a card not in hand", lead, []Card{card(Clubs, RankAce, 0)}, []Card{card(Clubs, RankKing, 0)}, true},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			testLead := test.lead
			if testLead == nil {
				testLead = lead
			}
			err := ValidateResponse(test.hand, testLead, test.response, trump)
			if (err != nil) != test.wantErr {
				t.Fatalf("ValidateResponse() error = %v, wantErr %v", err, test.wantErr)
			}
		})
	}
}

func TestForcedDrawCards(t *testing.T) {
	hand := []Card{
		card(Clubs, RankTwo, 0),
		card(Hearts, RankFive, 0),
		card(NoSuit, RankSmallJoker, 0),
		card(NoSuit, RankBigJoker, 0),
		card(Spades, RankAce, 0),
	}
	got, err := ForcedDrawCards(hand, Trump{Suit: Clubs, Level: RankTwo})
	if err != nil {
		t.Fatal(err)
	}
	want := []Card{card(Hearts, RankFive, 0), card(NoSuit, RankBigJoker, 0), card(NoSuit, RankSmallJoker, 0)}
	for i := range want {
		if got[i] != want[i] {
			t.Fatalf("ForcedDrawCards() = %v, want %v", got, want)
		}
	}

	got, err = ForcedDrawCards([]Card{
		card(Hearts, RankFive, 0),
		card(NoSuit, RankBigJoker, 0),
		card(Spades, RankAce, 0),
		card(Diamonds, RankThree, 0),
	}, Trump{Suit: Clubs, Level: RankTwo})
	if err != nil || len(got) != 3 || got[2] != card(Diamonds, RankThree, 0) {
		t.Fatalf("ForcedDrawCards() should fill with deterministic side cards: (%v, %v)", got, err)
	}
}

func TestResolveHandScoreBoundaries(t *testing.T) {
	tests := []struct {
		score           int
		dealerAdvance   int
		defenderAdvance int
		nextDealer      Side
		winner          Side
	}{
		{0, 8, 0, DealerSide, DealerSide},
		{5, 7, 0, DealerSide, DealerSide},
		{10, 7, 0, DealerSide, DealerSide},
		{15, 6, 0, DealerSide, DealerSide},
		{20, 6, 0, DealerSide, DealerSide},
		{25, 5, 0, DealerSide, DealerSide},
		{30, 5, 0, DealerSide, DealerSide},
		{35, 4, 0, DealerSide, DealerSide},
		{40, 4, 0, DealerSide, DealerSide},
		{45, 3, 0, DealerSide, DealerSide},
		{50, 3, 0, DealerSide, DealerSide},
		{55, 2, 0, DealerSide, DealerSide},
		{60, 2, 0, DealerSide, DealerSide},
		{65, 1, 0, DealerSide, DealerSide},
		{70, 1, 0, DealerSide, DealerSide},
		{75, 0, 0, DealerSide, DealerSide},
		{80, 0, 0, DefenderSide, DefenderSide},
		{85, 0, 0, DefenderSide, DefenderSide},
		{90, 0, 1, DefenderSide, DefenderSide},
		{95, 0, 1, DefenderSide, DefenderSide},
		{100, 0, 2, DefenderSide, DefenderSide},
		{105, 0, 2, DefenderSide, DefenderSide},
		{110, 0, 3, DefenderSide, DefenderSide},
		{115, 0, 3, DefenderSide, DefenderSide},
		{120, 0, 4, DefenderSide, DefenderSide},
		{125, 0, 4, DefenderSide, DefenderSide},
		{130, 0, 5, DefenderSide, DefenderSide},
		{135, 0, 5, DefenderSide, DefenderSide},
		{140, 0, 6, DefenderSide, DefenderSide},
		{145, 0, 6, DefenderSide, DefenderSide},
		{150, 0, 7, DefenderSide, DefenderSide},
		{155, 0, 7, DefenderSide, DefenderSide},
		{160, 0, 8, DefenderSide, DefenderSide},
		{165, 0, 8, DefenderSide, DefenderSide},
		{170, 0, 9, DefenderSide, DefenderSide},
		{175, 0, 9, DefenderSide, DefenderSide},
		{180, 0, 10, DefenderSide, DefenderSide},
		{185, 0, 10, DefenderSide, DefenderSide},
		{190, 0, 11, DefenderSide, DefenderSide},
		{195, 0, 11, DefenderSide, DefenderSide},
		{200, 0, 12, DefenderSide, DefenderSide},
		{250, 0, 12, DefenderSide, DefenderSide},
	}
	for _, test := range tests {
		t.Run(testNameForScore(test.score), func(t *testing.T) {
			got, err := ResolveHand(HandInput{
				DealerLevel:   RankFour,
				DefenderLevel: RankTwo,
				DefenderScore: test.score,
			})
			if err != nil {
				t.Fatal(err)
			}
			if got.DealerLevel != RankFour+Rank(test.dealerAdvance) ||
				got.DefenderLevel != RankTwo+Rank(test.defenderAdvance) ||
				got.NextDealer != test.nextDealer || got.Winner != test.winner {
				t.Fatalf("ResolveHand() = %+v, unexpected result for score %d", got, test.score)
			}
		})
	}
}

func testNameForScore(score int) string {
	return "score_" + strconv.Itoa(score)
}

func TestResolveMandatoryLevels(t *testing.T) {
	tests := []struct {
		name        string
		level       Rank
		score       int
		dealerLevel Rank
		defender    Rank
		nextDealer  Side
		gameWon     bool
	}{
		{"2 and 0 advances by full table amount plus natural level", RankTwo, 0, RankJack, RankTwo, DealerSide, false},
		{"2 and 70 advances one plus natural level", RankTwo, 70, RankFour, RankTwo, DealerSide, false},
		{"2 and 75 advances one plus natural level", RankTwo, 75, RankFour, RankTwo, DealerSide, false},
		{"2 and 80 exchanges but stays at 2", RankTwo, 80, RankTwo, RankTwo, DefenderSide, false},
		{"J and 75 stays", RankJack, 75, RankJack, RankTwo, DealerSide, false},
		{"J and 90 exchanges but stays at J", RankJack, 90, RankJack, RankJack, DefenderSide, false},
		{"A and 75 wins", RankAce, 75, RankAce, RankTwo, DealerSide, true},
		{"A and 80 exchanges at A", RankAce, 80, RankAce, RankAce, DefenderSide, false},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			got, err := ResolveHand(HandInput{
				DealerLevel:   test.level,
				DefenderLevel: RankTwo,
				DefenderScore: test.score,
			})
			if err != nil {
				t.Fatal(err)
			}
			if got.DealerLevel != test.dealerLevel || got.DefenderLevel != test.defender ||
				got.NextDealer != test.nextDealer || got.GameWon != test.gameWon {
				t.Fatalf("ResolveHand() = %+v", got)
			}
		})
	}
}

func TestResolveNaturalLevel(t *testing.T) {
	tenKingFive := []Card{
		card(Clubs, RankFive, 0),
		card(Clubs, RankTen, 0),
		card(Clubs, RankKing, 0),
	}
	tests := []struct {
		name        string
		input       HandInput
		dealerLevel Rank
		winner      Side
		nextDealer  Side
		triggered   bool
	}{
		{
			name: "adds one after normal progression at zero",
			input: HandInput{
				DealerLevel: RankTwo, DefenderLevel: RankTwo, DefenderScore: 0,
			},
			dealerLevel: RankJack, winner: DealerSide, nextDealer: DealerSide, triggered: true,
		},
		{
			name: "adds one after normal progression at 75",
			input: HandInput{
				DealerLevel: RankTwo, DefenderLevel: RankTwo, DefenderScore: 75,
			},
			dealerLevel: RankFour, winner: DealerSide, nextDealer: DealerSide, triggered: true,
		},
		{
			name: "does not trigger at 80",
			input: HandInput{
				DealerLevel: RankTwo, DefenderLevel: RankTwo, DefenderScore: 80,
			},
			dealerLevel: RankTwo, winner: DefenderSide, nextDealer: DefenderSide,
		},
		{
			name: "does not trigger outside level two",
			input: HandInput{
				DealerLevel: RankThree, DefenderLevel: RankTwo, DefenderScore: 70,
			},
			dealerLevel: RankFour, winner: DealerSide, nextDealer: DealerSide,
		},
		{
			name: "defender 510k bottom capture blocks natural level",
			input: HandInput{
				DealerLevel: RankTwo, DefenderLevel: RankTwo, DefenderScore: 70,
				FinalTrick: tenKingFive, FinalTrickWinner: DefenderSide, BottomCaptured: true,
			},
			dealerLevel: RankThree, winner: DealerSide, nextDealer: DealerSide,
		},
		{
			name: "defender bottom capture without 510k still triggers",
			input: HandInput{
				DealerLevel: RankTwo, DefenderLevel: RankTwo, DefenderScore: 70,
				FinalTrick: []Card{card(Clubs, RankAce, 0)}, FinalTrickWinner: DefenderSide, BottomCaptured: true,
			},
			dealerLevel: RankFour, winner: DealerSide, nextDealer: DealerSide, triggered: true,
		},
		{
			name: "510k without defender bottom capture does not block",
			input: HandInput{
				DealerLevel: RankTwo, DefenderLevel: RankTwo, DefenderScore: 70,
				FinalTrick: tenKingFive, FinalTrickWinner: DefenderSide,
			},
			dealerLevel: RankFour, winner: DealerSide, nextDealer: DealerSide, triggered: true,
		},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			got, err := ResolveHand(test.input)
			if err != nil {
				t.Fatal(err)
			}
			if got.DealerLevel != test.dealerLevel || got.Winner != test.winner ||
				got.NextDealer != test.nextDealer || got.NaturalLevel != test.triggered ||
				got.DefenderLevel != test.input.DefenderLevel || got.GameWon || got.Comeback {
				t.Fatalf("ResolveHand() = %+v", got)
			}
		})
	}
}

func TestResolveComeback(t *testing.T) {
	tests := []struct {
		name         string
		level        Rank
		score        int
		finalTrick   []Card
		wantDealer   Rank
		wantNext     Side
		wantComeback bool
		wantWon      bool
	}{
		{"single J forces level 3", RankJack, 70, []Card{card(Hearts, RankJack, 0)}, RankThree, DealerSide, true, false},
		{"pair J forces level 2 and exchanges at 80", RankJack, 80, []Card{card(Hearts, RankJack, 0), card(Hearts, RankJack, 1)}, RankTwo, DefenderSide, true, false},
		{"single A forces J and exchanges", RankAce, 80, []Card{card(Spades, RankAce, 0)}, RankJack, DefenderSide, true, false},
		{"pair A forces 2 and exchanges", RankAce, 100, []Card{card(Spades, RankAce, 0), card(Spades, RankAce, 1)}, RankTwo, DefenderSide, true, false},
		{"A with 75 wins without comeback", RankAce, 75, []Card{card(Spades, RankAce, 0)}, RankAce, DealerSide, false, true},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			got, err := ResolveHand(HandInput{
				DealerLevel:      test.level,
				DefenderLevel:    RankTwo,
				DefenderScore:    test.score,
				FinalTrick:       test.finalTrick,
				FinalTrickWinner: DefenderSide,
				BottomCaptured:   true,
			})
			if err != nil {
				t.Fatal(err)
			}
			if got.DealerLevel != test.wantDealer || got.NextDealer != test.wantNext ||
				got.Comeback != test.wantComeback || got.GameWon != test.wantWon {
				t.Fatalf("ResolveHand() = %+v", got)
			}
		})
	}
}

func TestResolveSkyEarthAndSpring(t *testing.T) {
	deputy := []Card{card(Hearts, RankFive, 0), card(Hearts, RankTen, 0), card(Hearts, RankKing, 0)}
	main := []Card{card(Clubs, RankFive, 0), card(Clubs, RankTen, 0), card(Clubs, RankKing, 0)}
	tests := []struct {
		name       string
		input      SkyEarthInput
		triggered  bool
		nextDealer Side
	}{
		{"last main 510K grants A versus 2", SkyEarthInput{MainSuit: Clubs, Played510K: main, PlayedBy: DealerSide, FinalWinner: DealerSide, IsFinalPlay: true, HandEmptyAfter: true}, true, DealerSide},
		{"main 510K pressing deputy transfers award", SkyEarthInput{MainSuit: Clubs, Played510K: deputy, Final510K: main, PlayedBy: DealerSide, FinalWinner: DefenderSide, IsFinalPlay: true, HandEmptyAfter: true}, true, DefenderSide},
		{"not the final hand does not trigger", SkyEarthInput{MainSuit: Clubs, Played510K: main, PlayedBy: DealerSide, FinalWinner: DealerSide, IsFinalPlay: false, HandEmptyAfter: true}, false, 0},
		{"deputy 510K is not beaten by another deputy", SkyEarthInput{MainSuit: Clubs, Played510K: deputy, Final510K: []Card{card(Spades, RankFive, 0), card(Spades, RankTen, 0), card(Spades, RankKing, 0)}, PlayedBy: DealerSide, FinalWinner: DefenderSide, IsFinalPlay: true, HandEmptyAfter: true}, false, 0},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			got, err := ResolveSkyEarth(test.input)
			if err != nil {
				t.Fatal(err)
			}
			if got.Triggered != test.triggered || got.NextDealer != test.nextDealer {
				t.Fatalf("ResolveSkyEarth() = %+v", got)
			}
			if got.Triggered && (got.WinnerLevel != RankAce || got.LoserLevel != RankTwo) {
				t.Fatalf("sky-earth levels = %+v, want A versus 2", got)
			}
		})
	}

	if !IsSpring(true, 2, RankAce, true, 75) {
		t.Fatal("the defined two-hand A:2 finish should be spring")
	}
	for _, test := range []struct {
		firstSky bool
		hands    int
		level    Rank
		won      bool
		score    int
	}{
		{false, 2, RankAce, true, 0},
		{true, 3, RankAce, true, 0},
		{true, 2, RankKing, true, 0},
		{true, 2, RankAce, false, 0},
		{true, 2, RankAce, true, 80},
	} {
		if IsSpring(test.firstSky, test.hands, test.level, test.won, test.score) {
			t.Errorf("IsSpring(%+v) = true, want false", test)
		}
	}
}
