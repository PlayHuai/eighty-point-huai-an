package runtime

import (
	"fmt"
	"sort"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"
)

// AutomaticAction chooses a legal, deterministic action using only this
// player's current hand and the public state in the session.
func AutomaticAction(state State, seat int, requestID string) (Action, error) {
	if seat < 0 || seat > 3 || requestID == "" {
		return Action{}, ErrTurn
	}
	if state.Phase != HandOver && state.Turn != seat {
		return Action{}, ErrTurn
	}
	if state.Phase == HandOver && state.Ready[seat] {
		return Action{}, ErrInvalidAction
	}
	action := Action{
		Seat: seat, RequestID: requestID, ExpectedVersion: state.Version,
	}
	switch state.Phase {
	case Declaration:
		for _, card := range state.Hands[seat] {
			if card.Rank == state.Trump.Level {
				action.Kind, action.Cards = Declare, []engine.Card{card}
				return action, nil
			}
		}
		action.Kind = Pass
	case Bury:
		action.Kind, action.Cards = BuryCards, selectBottom(state, seat)
	case Counter:
		view, err := View(state, seat)
		if err != nil {
			return Action{}, err
		}
		for _, available := range view.Actions {
			if available.Kind == CounterTrump {
				action.Kind, action.Cards = CounterTrump, available.Cards
				return action, nil
			}
		}
		for _, available := range view.Actions {
			if available.Kind == LookBack {
				action.Kind = LookBack
				return action, nil
			}
		}
		action.Kind = Pass
	case Playing:
		cards, err := choosePlay(state, seat)
		if err != nil {
			return Action{}, err
		}
		action.Kind, action.Cards = PlayCards, cards
	case HandOver:
		action.Kind = Continue
	default:
		return Action{}, ErrPhase
	}
	return action, nil
}

func selectBottom(state State, seat int) []engine.Card {
	var suitGroups [4][]engine.Card
	for _, card := range state.Hands[seat] {
		if card.Suit >= engine.Clubs && card.Suit <= engine.Spades && !engine.IsTrump(card, state.Trump) &&
			card.Rank != state.Trump.Level && !(card.Suit == engine.Hearts && card.Rank == engine.RankFive) {
			suitGroups[card.Suit-engine.Clubs] = append(suitGroups[card.Suit-engine.Clubs], card)
		}
	}
	selectedSuit, bestCount := engine.Clubs, -1
	for suit := engine.Clubs; suit <= engine.Spades; suit++ {
		count := len(suitGroups[suit-engine.Clubs])
		if seat == state.Dealer {
			for _, card := range suitGroups[suit-engine.Clubs] {
				if card.Rank == engine.RankAce {
					count--
				}
			}
		}
		if count > bestCount {
			selectedSuit, bestCount = suit, count
		}
	}
	cards := append([]engine.Card(nil), suitGroups[selectedSuit-engine.Clubs]...)
	if seat == state.Dealer {
		filtered := cards[:0]
		for _, card := range cards {
			if card.Rank != engine.RankAce {
				filtered = append(filtered, card)
			}
		}
		cards = filtered
	}
	sort.SliceStable(cards, func(i, j int) bool {
		a, b := buryValue(state, cards[i]), buryValue(state, cards[j])
		if a != b {
			return a < b
		}
		if cards[i].Suit != cards[j].Suit {
			return cards[i].Suit < cards[j].Suit
		}
		if cards[i].Rank != cards[j].Rank {
			return cards[i].Rank < cards[j].Rank
		}
		return cards[i].Copy < cards[j].Copy
	})
	if len(cards) < 8 {
		remaining := make([]engine.Card, 0, len(state.Hands[seat]))
		for _, card := range state.Hands[seat] {
			if card.Suit == selectedSuit && !engine.IsTrump(card, state.Trump) {
				continue
			}
			if card.Rank == state.Trump.Level ||
				(card.Suit == engine.Hearts && card.Rank == engine.RankFive) {
				continue
			}
			remaining = append(remaining, card)
		}
		sort.SliceStable(remaining, func(i, j int) bool {
			a, b := buryValue(state, remaining[i]), buryValue(state, remaining[j])
			if a != b {
				return a < b
			}
			if remaining[i].Rank != remaining[j].Rank {
				return remaining[i].Rank < remaining[j].Rank
			}
			return remaining[i].Copy < remaining[j].Copy
		})
		cards = append(cards, remaining...)
	}
	if len(cards) > 8 {
		cards = cards[:8]
	}
	return cards
}

func buryValue(state State, card engine.Card) int {
	value := int(card.Rank)
	if engine.IsTrump(card, state.Trump) {
		value += 100
	}
	if card.Rank == state.Trump.Level || (card.Suit == engine.Hearts && card.Rank == engine.RankFive) {
		value += 1000
	}
	if card.Rank == engine.RankFive || card.Rank == engine.RankTen || card.Rank == engine.RankKing {
		value += 50
	}
	return value
}

func choosePlay(state State, seat int) ([]engine.Card, error) {
	hand := append([]engine.Card(nil), state.Hands[seat]...)
	if len(state.Trick.Plays) == 0 {
		return chooseLead(state, seat, hand)
	}

	lead := state.Trick.Plays[0].Cards
	count := len(lead)
	if count == 0 || len(hand) < count {
		return nil, ErrInvalidAction
	}
	leadSuit := state.suit(lead[0])
	requiredSuit := min(count, len(filter(hand, func(card engine.Card) bool {
		return state.suit(card) == leadSuit
	})))
	heldFollowSuit := filter(hand, func(card engine.Card) bool {
		return state.suit(card) == leadSuit
	})
	requiredPairs := 0
	if state.sameSuit(lead) && !engine.Is510K(lead) {
		parts := state.parts(lead)
		if shape, err := engine.ClassifyPlay(lead, state.Trump); err == nil &&
			(shape.Kind == engine.PlayPair || shape.Kind == engine.PlayTwoPairs ||
				shape.Kind == engine.PlayTractor) {
			parts = [][]engine.Card{lead}
		}
		for _, part := range parts {
			if shape, err := engine.ClassifyPlay(part, state.Trump); err == nil {
				requiredPairs += shape.PairCount
			}
		}
		requiredPairs = min(requiredPairs, pairCount(heldFollowSuit))
	}
	forcedTrump := -1
	if engine.Is510K(lead) && lead[0].Suit == state.Trump.Suit {
		forcedTrump = min(3, len(filter(hand, func(card engine.Card) bool {
			return engine.IsTrump(card, state.Trump)
		})))
	}
	teammateControls := state.Trick.Winner%2 == seat%2
	var incumbent []engine.Card
	for _, play := range state.Trick.Plays {
		if play.Seat == state.Trick.Winner {
			incumbent = play.Cards
			break
		}
	}
	if len(incumbent) == 0 {
		return nil, ErrInvalidAction
	}

	sort.SliceStable(hand, func(i, j int) bool {
		aFollows, bFollows := state.suit(hand[i]) == leadSuit, state.suit(hand[j]) == leadSuit
		if aFollows != bFollows {
			return aFollows
		}
		if teammateControls {
			a, b := feedValue([]engine.Card{hand[i]}), feedValue([]engine.Card{hand[j]})
			if a != b {
				return a > b
			}
		} else if aFollows {
			if comparison := state.compare([]engine.Card{hand[i]}, []engine.Card{hand[j]}, lead); comparison != 0 {
				return comparison > 0
			}
		} else {
			aTrump, bTrump := engine.IsTrump(hand[i], state.Trump), engine.IsTrump(hand[j], state.Trump)
			if aTrump != bTrump {
				return aTrump
			}
		}
		a, b := discardValue(state, hand[i]), discardValue(state, hand[j])
		if a != b {
			return a < b
		}
		if hand[i].Suit != hand[j].Suit {
			return hand[i].Suit < hand[j].Suit
		}
		if hand[i].Rank != hand[j].Rank {
			return hand[i].Rank < hand[j].Rank
		}
		return hand[i].Copy < hand[j].Copy
	})
	chosen := make([]engine.Card, 0, count)
	chosenFollowSuit := make([]engine.Card, 0, count)
	var best []engine.Card
	bestCategory, bestCost := 0, 0
	nodes, checks := 0, 0
	const maxSearchNodes = 100_000
	const maxRuleChecks = 4_096
	var visit func(int, int, int)
	visit = func(start, suitCount, trumpCount int) {
		if nodes >= maxSearchNodes || checks >= maxRuleChecks {
			return
		}
		nodes++
		if len(chosen) == count {
			if suitCount < requiredSuit ||
				pairCount(chosenFollowSuit) < requiredPairs ||
				(forcedTrump >= 0 && trumpCount != forcedTrump) {
				return
			}
			checks++
			if state.ValidatePlay(seat, chosen) == nil {
				wins := state.beats(chosen, incumbent, lead)
				category := 1
				if wins != teammateControls {
					category = 0
				}
				cost := discardCost(state, chosen)
				if teammateControls && !wins {
					cost = -feedValue(chosen)
				}
				if best == nil || category < bestCategory ||
					(category == bestCategory && category == 0 && wins &&
						state.compare(chosen, best, lead) < 0) ||
					(category == bestCategory && !(wins && category == 0) && cost < bestCost) {
					best = append([]engine.Card(nil), chosen...)
					bestCategory, bestCost = category, cost
				}
			}
			return
		}
		remaining := count - len(chosen)
		for i := start; i <= len(hand)-remaining; i++ {
			card := hand[i]
			nextSuitCount := suitCount
			if state.suit(card) == leadSuit {
				nextSuitCount++
			}
			nextTrumpCount := trumpCount
			if engine.IsTrump(card, state.Trump) {
				nextTrumpCount++
			}
			slotsAfter := remaining - 1
			if nextSuitCount+min(slotsAfter, remainingSuitCount(hand[i+1:], leadSuit, state)) < requiredSuit {
				continue
			}
			if forcedTrump >= 0 && nextTrumpCount > forcedTrump {
				continue
			}
			if forcedTrump >= 0 &&
				nextTrumpCount+min(slotsAfter, remainingTrumpCount(hand[i+1:], state)) < forcedTrump {
				continue
			}
			chosen = append(chosen, card)
			if state.suit(card) == leadSuit {
				chosenFollowSuit = append(chosenFollowSuit, card)
			}
			possibleFollow := append([]engine.Card(nil), chosenFollowSuit...)
			possibleFollow = append(possibleFollow, filter(hand[i+1:], func(card engine.Card) bool {
				return state.suit(card) == leadSuit
			})...)
			if requiredPairs > 0 && pairCount(possibleFollow) < requiredPairs {
				if state.suit(card) == leadSuit {
					chosenFollowSuit = chosenFollowSuit[:len(chosenFollowSuit)-1]
				}
				chosen = chosen[:len(chosen)-1]
				continue
			}
			visit(i+1, nextSuitCount, nextTrumpCount)
			if state.suit(card) == leadSuit {
				chosenFollowSuit = chosenFollowSuit[:len(chosenFollowSuit)-1]
			}
			chosen = chosen[:len(chosen)-1]
			if nodes >= maxSearchNodes || checks >= maxRuleChecks {
				return
			}
		}
	}
	visit(0, 0, 0)
	if best != nil {
		return best, nil
	}
	return nil, fmt.Errorf("%w: no legal automatic response found", ErrInvalidAction)
}

func chooseLead(state State, seat int, hand []engine.Card) ([]engine.Card, error) {
	if len(hand) == 0 {
		return nil, ErrInvalidAction
	}
	for suit := engine.Clubs; suit <= engine.Spades; suit++ {
		for _, five := range hand {
			if five.Suit != suit || five.Rank != engine.RankFive {
				continue
			}
			for _, ten := range hand {
				if ten.Suit != suit || ten.Rank != engine.RankTen {
					continue
				}
				for _, king := range hand {
					candidate := []engine.Card{five, ten, king}
					if king.Suit == suit && king.Rank == engine.RankKing &&
						state.ValidatePlay(seat, candidate) == nil {
						return candidate, nil
					}
				}
			}
		}
	}

	groups := map[engine.Suit][]engine.Card{}
	for _, card := range hand {
		groups[state.suit(card)] = append(groups[state.suit(card)], card)
	}
	for suit := engine.Clubs; suit <= engine.NoSuit; suit++ {
		cards := groups[suit]
		if len(cards) < 4 {
			continue
		}
		sort.SliceStable(cards, func(i, j int) bool {
			return discardValue(state, cards[i]) > discardValue(state, cards[j])
		})
		if len(cards) > 8 {
			cards = cards[:8]
		}
		if state.ValidatePlay(seat, cards) == nil {
			return append([]engine.Card(nil), cards...), nil
		}
	}

	pairs := make([][]engine.Card, 0)
	for i := range hand {
		for j := i + 1; j < len(hand); j++ {
			candidate := []engine.Card{hand[i], hand[j]}
			if engine.IsPair(candidate) && state.ValidatePlay(seat, candidate) == nil {
				pairs = append(pairs, candidate)
			}
		}
	}
	for _, candidate := range pairs {
		suit := state.suit(candidate[0])
		if suit != engine.NoSuit && teammateVoid(state, seat, suit) {
			return candidate, nil
		}
	}
	for _, candidate := range pairs {
		if state.suit(candidate[0]) == engine.NoSuit {
			return candidate, nil
		}
	}

	sort.SliceStable(hand, func(i, j int) bool {
		a, b := discardValue(state, hand[i]), discardValue(state, hand[j])
		if a != b {
			return a < b
		}
		return hand[i].Copy < hand[j].Copy
	})
	for _, card := range hand {
		if engine.IsTrump(card, state.Trump) {
			candidate := []engine.Card{card}
			if state.ValidatePlay(seat, candidate) == nil {
				return candidate, nil
			}
		}
	}
	for _, card := range hand {
		candidate := []engine.Card{card}
		if state.ValidatePlay(seat, candidate) == nil {
			return candidate, nil
		}
	}
	return nil, ErrInvalidAction
}

func remainingSuitCount(cards []engine.Card, suit engine.Suit, state State) int {
	count := 0
	for _, card := range cards {
		if state.suit(card) == suit {
			count++
		}
	}
	return count
}

func remainingTrumpCount(cards []engine.Card, state State) int {
	count := 0
	for _, card := range cards {
		if engine.IsTrump(card, state.Trump) {
			count++
		}
	}
	return count
}

func discardCost(state State, cards []engine.Card) int {
	cost := 0
	for _, card := range cards {
		cost += discardValue(state, card)
	}
	return cost
}

func feedValue(cards []engine.Card) int {
	value := 0
	for _, card := range cards {
		switch card.Rank {
		case engine.RankFive:
			value += 5
		case engine.RankTen:
			value += 10
		case engine.RankKing:
			value += 10
		}
	}
	return value
}

func teammateVoid(state State, seat int, suit engine.Suit) bool {
	for _, trick := range state.Completed {
		if len(trick.Plays) == 0 {
			continue
		}
		leadSuit := state.suit(trick.Plays[0].Cards[0])
		if leadSuit != suit {
			continue
		}
		for _, play := range trick.Plays {
			if play.Seat%2 != seat%2 || play.Seat == seat {
				continue
			}
			followed := false
			for _, card := range play.Cards {
				followed = followed || state.suit(card) == suit
			}
			if !followed {
				return true
			}
		}
	}
	return false
}

func discardValue(state State, card engine.Card) int {
	value := int(card.Rank)
	if engine.IsTrump(card, state.Trump) {
		value += 100
	}
	if card.Rank == engine.RankFive || card.Rank == engine.RankTen || card.Rank == engine.RankKing {
		value += 50
	}
	return value
}
