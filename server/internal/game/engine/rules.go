package engine

import (
	"errors"
	"sort"
	"strconv"
)

type Suit uint8

const (
	NoSuit Suit = iota
	Clubs
	Diamonds
	Hearts
	Spades
)

type Rank uint8

const (
	RankTwo Rank = 2 + iota
	RankThree
	RankFour
	RankFive
	RankSix
	RankSeven
	RankEight
	RankNine
	RankTen
	RankJack
	RankQueen
	RankKing
	RankAce
	RankSmallJoker
	RankBigJoker
)

type Card struct {
	Suit Suit
	Rank Rank
	Copy uint8
}

type Trump struct {
	Suit  Suit
	Level Rank
}

type PlayKind uint8

const (
	PlaySingle PlayKind = iota + 1
	PlayPair
	PlayTwoPairs
	PlayTractor
	Play510K
)

type PlayShape struct {
	Kind      PlayKind
	PairCount int
}

type Side uint8

const (
	DealerSide Side = iota + 1
	DefenderSide
)

var (
	ErrInvalidCard    = errors.New("invalid card")
	ErrInvalidTrump   = errors.New("invalid trump")
	ErrInvalidPlay    = errors.New("invalid play")
	ErrInvalidScore   = errors.New("invalid score")
	ErrInvalidCounter = errors.New("invalid counter-trump")
	ErrInvalidHand    = errors.New("invalid hand")
	ErrDifferentSuits = errors.New("cards cannot be compared across these suits")
)

func (c Card) Validate() error {
	if c.Copy > 1 {
		return ErrInvalidCard
	}
	if c.Rank == RankSmallJoker || c.Rank == RankBigJoker {
		if c.Suit != NoSuit {
			return ErrInvalidCard
		}
		return nil
	}
	if c.Rank < RankTwo || c.Rank > RankAce || c.Suit < Clubs || c.Suit > Spades {
		return ErrInvalidCard
	}
	return nil
}

func (t Trump) Validate() error {
	if t.Level < RankTwo || t.Level > RankAce || (t.Suit != NoSuit && (t.Suit < Clubs || t.Suit > Spades)) {
		return ErrInvalidTrump
	}
	return nil
}

func TrumpFromLevelCard(card Card, level Rank) (Trump, error) {
	if card.Validate() != nil || (Trump{Level: level}).Validate() != nil || card.Rank != level {
		return Trump{}, ErrInvalidTrump
	}
	return Trump{Suit: card.Suit, Level: level}, nil
}

func FallbackTrump(topCard Card, level Rank) (Trump, error) {
	if topCard.Validate() != nil || (Trump{Level: level}).Validate() != nil {
		return Trump{}, ErrInvalidTrump
	}
	if topCard.Rank == level || topCard.Rank == RankSmallJoker ||
		topCard.Rank == RankBigJoker || (topCard.Suit == Hearts && topCard.Rank == RankFive) {
		return Trump{Suit: NoSuit, Level: level}, nil
	}
	return Trump{Suit: topCard.Suit, Level: level}, nil
}

func IsTrump(card Card, trump Trump) bool {
	return card.Validate() == nil &&
		trump.Validate() == nil &&
		(card.Rank == RankSmallJoker ||
			card.Rank == RankBigJoker ||
			card.Rank == trump.Level ||
			(trump.Suit != NoSuit && card.Suit == Hearts && card.Rank == RankFive) ||
			(trump.Suit != NoSuit && card.Suit == trump.Suit))
}

func CompareCards(a, b Card, trump Trump) (int, error) {
	if err := a.Validate(); err != nil {
		return 0, err
	}
	if err := b.Validate(); err != nil {
		return 0, err
	}
	if err := trump.Validate(); err != nil {
		return 0, err
	}

	aClass, bClass := cardClass(a, trump), cardClass(b, trump)
	if aClass != bClass {
		return compareInt(aClass, bClass), nil
	}
	if aClass == 0 && a.Suit != b.Suit {
		return 0, ErrDifferentSuits
	}
	if aClass == 2 || aClass == 3 || aClass >= 4 {
		return 0, nil
	}
	return compareInt(int(a.Rank), int(b.Rank)), nil
}

func cardClass(card Card, trump Trump) int {
	switch {
	case trump.Suit != NoSuit && card.Suit == Hearts && card.Rank == RankFive:
		return 6
	case card.Rank == RankBigJoker:
		return 5
	case card.Rank == RankSmallJoker:
		return 4
	case card.Rank == trump.Level && trump.Suit != NoSuit && card.Suit == trump.Suit:
		return 3
	case card.Rank == trump.Level:
		return 2
	case trump.Suit != NoSuit && card.Suit == trump.Suit:
		return 1
	default:
		return 0
	}
}

func compareInt(a, b int) int {
	if a < b {
		return -1
	}
	if a > b {
		return 1
	}
	return 0
}

func IsPair(cards []Card) bool {
	return len(cards) == 2 &&
		cards[0].Validate() == nil &&
		cards[1].Validate() == nil &&
		cards[0].Suit == cards[1].Suit &&
		cards[0].Rank == cards[1].Rank &&
		cards[0].Copy != cards[1].Copy
}

func IsTractor(cards []Card, trump Trump) bool {
	if len(cards) < 4 || len(cards)%2 != 0 || trump.Validate() != nil {
		return false
	}
	suit := cards[0].Suit
	counts := make(map[Rank]int)
	copies := make(map[Rank]map[uint8]bool)
	for _, card := range cards {
		if card.Validate() != nil || card.Suit != suit || card.Rank > RankAce {
			return false
		}
		counts[card.Rank]++
		if copies[card.Rank] == nil {
			copies[card.Rank] = make(map[uint8]bool)
		}
		if copies[card.Rank][card.Copy] {
			return false
		}
		copies[card.Rank][card.Copy] = true
	}
	if len(counts)*2 != len(cards) {
		return false
	}
	ranks := make([]int, 0, len(counts))
	for rank, count := range counts {
		if count != 2 || rank == trump.Level {
			return false
		}
		ranks = append(ranks, int(rank))
	}
	sort.Ints(ranks)
	for i := 1; i < len(ranks); i++ {
		if ranks[i] != ranks[i-1]+1 {
			return false
		}
	}
	return true
}

func Is510K(cards []Card) bool {
	if len(cards) != 3 {
		return false
	}
	suit := cards[0].Suit
	ranks := map[Rank]int{}
	for _, card := range cards {
		if card.Validate() != nil || card.Suit != suit {
			return false
		}
		ranks[card.Rank]++
	}
	return len(ranks) == 3 && ranks[RankFive] == 1 && ranks[RankTen] == 1 && ranks[RankKing] == 1
}

func Has510K(cards []Card) bool {
	for _, card := range cards {
		if card.Validate() != nil {
			return false
		}
	}
	suits := []Suit{Clubs, Diamonds, Hearts, Spades}
	for _, suit := range suits {
		for _, five := range cards {
			if five.Suit != suit || five.Rank != RankFive {
				continue
			}
			for _, ten := range cards {
				if ten.Suit != suit || ten.Rank != RankTen {
					continue
				}
				for _, king := range cards {
					if king.Suit == suit && king.Rank == RankKing {
						return true
					}
				}
			}
		}
	}
	return false
}

func ClassifyPlay(cards []Card, trump Trump) (PlayShape, error) {
	if len(cards) == 0 || trump.Validate() != nil {
		return PlayShape{}, ErrInvalidPlay
	}
	for _, card := range cards {
		if card.Validate() != nil {
			return PlayShape{}, ErrInvalidPlay
		}
	}
	switch {
	case len(cards) == 1:
		return PlayShape{Kind: PlaySingle}, nil
	case IsPair(cards):
		return PlayShape{Kind: PlayPair, PairCount: 1}, nil
	case Is510K(cards):
		return PlayShape{Kind: Play510K}, nil
	case IsTractor(cards, trump):
		return PlayShape{Kind: PlayTractor, PairCount: len(cards) / 2}, nil
	case isTwoPairs(cards):
		return PlayShape{Kind: PlayTwoPairs, PairCount: 2}, nil
	default:
		return PlayShape{}, ErrInvalidPlay
	}
}

func isTwoPairs(cards []Card) bool {
	if len(cards) != 4 || cards[0].Suit != cards[1].Suit ||
		cards[0].Suit != cards[2].Suit || cards[0].Suit != cards[3].Suit {
		return false
	}
	counts := map[Rank]int{}
	copies := map[Rank]map[uint8]bool{}
	for _, card := range cards {
		if card.Validate() != nil {
			return false
		}
		counts[card.Rank]++
		if copies[card.Rank] == nil {
			copies[card.Rank] = map[uint8]bool{}
		}
		if copies[card.Rank][card.Copy] {
			return false
		}
		copies[card.Rank][card.Copy] = true
	}
	if len(counts) != 2 {
		return false
	}
	for _, count := range counts {
		if count != 2 {
			return false
		}
	}
	return true
}

func Compare510K(a, b []Card, trump Trump) (int, error) {
	if !Is510K(a) || !Is510K(b) || trump.Validate() != nil {
		return 0, ErrInvalidPlay
	}
	aMain := trump.Suit != NoSuit && a[0].Suit == trump.Suit
	bMain := trump.Suit != NoSuit && b[0].Suit == trump.Suit
	return compareInt(boolInt(aMain), boolInt(bMain)), nil
}

func ComparePlays(candidate, incumbent []Card, leadSuit Suit, trump Trump) (int, error) {
	if leadSuit < Clubs || leadSuit > Spades || trump.Validate() != nil {
		return 0, ErrInvalidPlay
	}
	candidateShape, err := ClassifyPlay(candidate, trump)
	if err != nil {
		return 0, err
	}
	incumbentShape, err := ClassifyPlay(incumbent, trump)
	if err != nil || candidateShape != incumbentShape {
		return 0, ErrInvalidPlay
	}
	if candidateShape.Kind == Play510K {
		return Compare510K(candidate, incumbent, trump)
	}
	candidateHigh, err := highestCard(candidate, leadSuit, trump)
	if err != nil {
		return 0, err
	}
	incumbentHigh, err := highestCard(incumbent, leadSuit, trump)
	if err != nil {
		return 0, err
	}
	return compareTrickCards(candidateHigh, incumbentHigh, leadSuit, trump)
}

func highestCard(cards []Card, leadSuit Suit, trump Trump) (Card, error) {
	highest := cards[0]
	for _, card := range cards[1:] {
		comparison, err := compareTrickCards(card, highest, leadSuit, trump)
		if err != nil {
			return Card{}, err
		}
		if comparison > 0 {
			highest = card
		}
	}
	return highest, nil
}

func compareTrickCards(candidate, incumbent Card, leadSuit Suit, trump Trump) (int, error) {
	candidateTrump, incumbentTrump := IsTrump(candidate, trump), IsTrump(incumbent, trump)
	if candidateTrump != incumbentTrump {
		return compareInt(boolInt(candidateTrump), boolInt(incumbentTrump)), nil
	}
	if candidateTrump {
		return CompareCards(candidate, incumbent, trump)
	}
	candidateLead, incumbentLead := candidate.Suit == leadSuit, incumbent.Suit == leadSuit
	if candidateLead != incumbentLead {
		return compareInt(boolInt(candidateLead), boolInt(incumbentLead)), nil
	}
	if !candidateLead {
		return 0, nil
	}
	return CompareCards(candidate, incumbent, trump)
}

func boolInt(value bool) int {
	if value {
		return 1
	}
	return 0
}

type CounterKind uint8

const (
	CounterLevel CounterKind = iota + 1
	CounterSmallJoker
	CounterBigJoker
	CounterRedFive
)

func CompareCounterTrump(a, b CounterKind) (int, error) {
	if a < CounterLevel || a > CounterRedFive || b < CounterLevel || b > CounterRedFive {
		return 0, ErrInvalidCounter
	}
	return compareInt(int(a), int(b)), nil
}

func DetermineCounterTrump(cards []Card, level Rank) (Trump, CounterKind, error) {
	if len(cards) != 2 {
		return Trump{}, 0, ErrInvalidCounter
	}
	for _, card := range cards {
		if card.Validate() != nil {
			return Trump{}, 0, ErrInvalidCounter
		}
	}
	if err := (Trump{Level: level}).Validate(); err != nil {
		return Trump{}, 0, ErrInvalidCounter
	}

	redFive := -1
	for i, card := range cards {
		if card.Suit == Hearts && card.Rank == RankFive {
			redFive = i
		}
	}
	if redFive < 0 {
		if IsPair(cards) && cards[0].Rank == level {
			return Trump{Suit: cards[0].Suit, Level: level}, CounterLevel, nil
		}
		if IsPair(cards) && cards[0].Rank == RankSmallJoker {
			return Trump{Suit: NoSuit, Level: level}, CounterSmallJoker, nil
		}
		if IsPair(cards) && cards[0].Rank == RankBigJoker {
			return Trump{Suit: NoSuit, Level: level}, CounterBigJoker, nil
		}
		return Trump{}, 0, ErrInvalidCounter
	}
	companion := cards[1-redFive]
	if companion.Rank == level || companion.Rank == RankSmallJoker || companion.Rank == RankBigJoker {
		return Trump{Suit: NoSuit, Level: level}, CounterRedFive, nil
	}
	return Trump{Suit: companion.Suit, Level: level}, CounterRedFive, nil
}

func Points(cards []Card) (int, error) {
	points := 0
	for _, card := range cards {
		if err := card.Validate(); err != nil {
			return 0, err
		}
		switch card.Rank {
		case RankFive:
			points += 5
		case RankTen, RankKing:
			points += 10
		}
	}
	return points, nil
}

func BottomMultiplier(kind PlayKind, pairCount int) (int, error) {
	switch kind {
	case PlaySingle:
		if pairCount != 0 {
			return 0, ErrInvalidPlay
		}
		return 2, nil
	case PlayPair:
		if pairCount != 1 {
			return 0, ErrInvalidPlay
		}
		return 4, nil
	case PlayTwoPairs:
		if pairCount != 2 {
			return 0, ErrInvalidPlay
		}
		return 8, nil
	case PlayTractor:
		if pairCount < 2 || pairCount > 30 {
			return 0, ErrInvalidPlay
		}
		return 1 << (pairCount + 1), nil
	default:
		return 0, ErrInvalidPlay
	}
}

func ScoreHand(trickPoints, bottomPoints int, bottomCaptured bool, kind PlayKind, pairCount int) (int, error) {
	if trickPoints < 0 || bottomPoints < 0 {
		return 0, ErrInvalidScore
	}
	points := trickPoints
	if bottomCaptured {
		multiplier, err := BottomMultiplier(kind, pairCount)
		if err != nil {
			return 0, err
		}
		points += bottomPoints * multiplier
	}
	return points, nil
}

func ValidateResponse(hand, lead, response []Card, trump Trump) error {
	if len(lead) == 0 || len(response) != len(lead) || trump.Validate() != nil ||
		!validUniqueCards(hand) || !validUniqueCards(lead) || !validUniqueCards(response) {
		return ErrInvalidPlay
	}
	if !containsCards(hand, response) {
		return ErrInvalidHand
	}

	leadSuit := lead[0].Suit
	heldLeadSuit, playedLeadSuit := 0, 0
	for _, card := range hand {
		if card.Suit == leadSuit {
			heldLeadSuit++
		}
	}
	for _, card := range response {
		if card.Suit == leadSuit {
			playedLeadSuit++
		}
	}
	if heldLeadSuit >= len(lead) && playedLeadSuit != len(lead) {
		return ErrInvalidPlay
	}
	if heldLeadSuit < len(lead) && playedLeadSuit < heldLeadSuit {
		return ErrInvalidPlay
	}
	if heldLeadSuit == 0 && allTrump(response, trump) {
		leadShape, leadErr := ClassifyPlay(lead, trump)
		responseShape, responseErr := ClassifyPlay(response, trump)
		if leadErr != nil || responseErr != nil || leadShape != responseShape {
			return ErrInvalidPlay
		}
	}
	return nil
}

func validUniqueCards(cards []Card) bool {
	seen := make(map[Card]bool, len(cards))
	for _, card := range cards {
		if card.Validate() != nil || seen[card] {
			return false
		}
		seen[card] = true
	}
	return true
}

func containsCards(hand, cards []Card) bool {
	counts := make(map[Card]int, len(hand))
	for _, card := range hand {
		counts[card]++
	}
	for _, card := range cards {
		if counts[card] == 0 {
			return false
		}
		counts[card]--
	}
	return true
}

func allTrump(cards []Card, trump Trump) bool {
	for _, card := range cards {
		if !IsTrump(card, trump) {
			return false
		}
	}
	return true
}

func ForcedDrawCards(hand []Card, trump Trump) ([]Card, error) {
	if len(hand) < 3 || trump.Validate() != nil || !validUniqueCards(hand) {
		return nil, ErrInvalidHand
	}
	trumps, sideCards := make([]Card, 0, len(hand)), make([]Card, 0, len(hand))
	for _, card := range hand {
		if IsTrump(card, trump) {
			trumps = append(trumps, card)
		} else {
			sideCards = append(sideCards, card)
		}
	}
	sort.Slice(trumps, func(i, j int) bool {
		return cardOrder(trumps[i], trump) > cardOrder(trumps[j], trump)
	})
	sort.Slice(sideCards, func(i, j int) bool {
		return cardOrder(sideCards[i], trump) < cardOrder(sideCards[j], trump)
	})
	selected := append([]Card(nil), trumps...)
	if len(selected) > 3 {
		selected = selected[:3]
	}
	for _, card := range sideCards {
		if len(selected) == 3 {
			break
		}
		selected = append(selected, card)
	}
	if len(selected) != 3 {
		return nil, ErrInvalidHand
	}
	return selected, nil
}

func cardOrder(card Card, trump Trump) int {
	return cardClass(card, trump)*10000 + int(card.Rank)*100 + int(card.Suit)*2 + int(card.Copy)
}

type HandInput struct {
	DealerLevel      Rank
	DefenderLevel    Rank
	DefenderScore    int
	FinalTrick       []Card
	FinalTrickWinner Side
	BottomCaptured   bool
}

type HandResolution struct {
	DealerLevel   Rank
	DefenderLevel Rank
	NextDealer    Side
	Winner        Side
	GameWon       bool
	Comeback      bool
	NaturalLevel  bool
}

func ResolveHand(input HandInput) (HandResolution, error) {
	if (Trump{Level: input.DealerLevel}).Validate() != nil ||
		(Trump{Level: input.DefenderLevel}).Validate() != nil ||
		input.DefenderScore < 0 || input.DefenderScore%5 != 0 {
		return HandResolution{}, ErrInvalidScore
	}
	result := HandResolution{
		DealerLevel:   input.DealerLevel,
		DefenderLevel: input.DefenderLevel,
		NextDealer:    DealerSide,
		Winner:        DealerSide,
	}

	steps := levelSteps(input.DefenderScore)
	if input.DefenderScore >= 80 {
		result.NextDealer = DefenderSide
		result.Winner = DefenderSide
		if isMandatory(input.DealerLevel) {
			result.DefenderLevel = input.DealerLevel
		} else {
			result.DefenderLevel = advanceLevel(input.DefenderLevel, steps)
		}
	} else if input.DealerLevel == RankAce {
		result.GameWon = true
	} else {
		if input.DefenderScore == 75 {
			if input.DealerLevel == RankTwo {
				steps = 1
			} else {
				steps = 0
			}
		}
		result.DealerLevel = advanceLevel(input.DealerLevel, steps)
	}

	forcedLevel, triggered := comebackLevel(input)
	if triggered {
		result.DealerLevel = forcedLevel
		result.Comeback = true
		if input.DealerLevel == RankAce {
			result.NextDealer = DefenderSide
			result.Winner = DefenderSide
		}
	}
	if input.DealerLevel == RankTwo && result.Winner == DealerSide && input.DefenderScore < 80 &&
		!(input.BottomCaptured && input.FinalTrickWinner == DefenderSide && Has510K(input.FinalTrick)) {
		result.DealerLevel = advanceLevel(result.DealerLevel, 1)
		result.NaturalLevel = true
	}
	return result, nil
}

func levelSteps(score int) int {
	if score < 75 {
		return 8 - (score+5)/10
	}
	if score < 90 {
		return 0
	}
	steps := score/10 - 8
	if steps > 12 {
		return 12
	}
	return steps
}

func isMandatory(level Rank) bool {
	return level == RankTwo || level == RankJack || level == RankAce
}

func advanceLevel(level Rank, steps int) Rank {
	next := int(level) + steps
	if next > int(RankAce) {
		return RankAce
	}
	return Rank(next)
}

func comebackLevel(input HandInput) (Rank, bool) {
	if !input.BottomCaptured || input.FinalTrickWinner != DefenderSide ||
		len(input.FinalTrick) == 0 || !validUniqueCards(input.FinalTrick) {
		return 0, false
	}
	level := input.DealerLevel
	if level != RankJack && level != RankAce {
		return 0, false
	}
	if level == RankAce && input.DefenderScore <= 75 {
		return 0, false
	}
	single := len(input.FinalTrick) == 1 && input.FinalTrick[0].Rank == level
	pair := IsPair(input.FinalTrick) && input.FinalTrick[0].Rank == level
	if !single && !pair {
		return 0, false
	}
	if level == RankJack {
		if pair {
			return RankTwo, true
		}
		return RankThree, true
	}
	if pair {
		return RankTwo, true
	}
	return RankJack, true
}

type SkyEarthInput struct {
	MainSuit       Suit
	Played510K     []Card
	Final510K      []Card
	PlayedBy       Side
	FinalWinner    Side
	IsFinalPlay    bool
	HandEmptyAfter bool
}

type SkyEarthResult struct {
	Triggered   bool
	NextDealer  Side
	Winner      Side
	WinnerLevel Rank
	LoserLevel  Rank
}

func ResolveSkyEarth(input SkyEarthInput) (SkyEarthResult, error) {
	if !Is510K(input.Played510K) || (input.MainSuit != NoSuit && (input.MainSuit < Clubs || input.MainSuit > Spades)) ||
		(input.PlayedBy != DealerSide && input.PlayedBy != DefenderSide) ||
		(input.FinalWinner != DealerSide && input.FinalWinner != DefenderSide) {
		return SkyEarthResult{}, ErrInvalidPlay
	}
	if len(input.Final510K) != 0 && !Is510K(input.Final510K) {
		return SkyEarthResult{}, ErrInvalidPlay
	}
	result := SkyEarthResult{}
	if !input.IsFinalPlay || !input.HandEmptyAfter {
		return result, nil
	}
	winner := input.PlayedBy
	if input.FinalWinner != input.PlayedBy {
		if !Is510K(input.Final510K) || input.MainSuit == NoSuit ||
			input.Played510K[0].Suit == input.MainSuit || input.Final510K[0].Suit != input.MainSuit {
			return result, nil
		}
		winner = input.FinalWinner
	}
	return SkyEarthResult{
		Triggered:   true,
		NextDealer:  winner,
		Winner:      winner,
		WinnerLevel: RankAce,
		LoserLevel:  RankTwo,
	}, nil
}

func IsSpring(firstHandSkyEarth bool, handsPlayed int, currentLevel Rank, dealerWon bool, defenderScore int) bool {
	return firstHandSkyEarth && handsPlayed == 2 && currentLevel == RankAce &&
		dealerWon && defenderScore >= 0 && defenderScore <= 75 && defenderScore%5 == 0
}

func (s Suit) String() string {
	switch s {
	case Clubs:
		return "clubs"
	case Diamonds:
		return "diamonds"
	case Hearts:
		return "hearts"
	case Spades:
		return "spades"
	default:
		return "no suit"
	}
}

func (r Rank) String() string {
	switch r {
	case RankJack:
		return "J"
	case RankQueen:
		return "Q"
	case RankKing:
		return "K"
	case RankAce:
		return "A"
	case RankSmallJoker:
		return "small joker"
	case RankBigJoker:
		return "big joker"
	default:
		if r >= RankTwo && r <= RankTen {
			return strconv.Itoa(int(r))
		}
		return "invalid rank"
	}
}
