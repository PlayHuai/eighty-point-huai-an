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
	sort.SliceStable(hand, func(i, j int) bool {
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
	if len(state.Trick.Plays) == 0 {
		if len(hand) == 0 {
			return nil, ErrInvalidAction
		}
		candidate := []engine.Card{hand[0]}
		if err := state.ValidatePlay(seat, candidate); err != nil {
			return nil, err
		}
		return candidate, nil
	}

	count := len(state.Trick.Plays[0].Cards)
	chosen := make([]engine.Card, 0, count)
	var result []engine.Card
	var visit func(int) bool
	visit = func(start int) bool {
		if len(chosen) == count {
			if state.ValidatePlay(seat, chosen) == nil {
				result = append([]engine.Card(nil), chosen...)
				return true
			}
			return false
		}
		remaining := count - len(chosen)
		for i := start; i <= len(hand)-remaining; i++ {
			chosen = append(chosen, hand[i])
			if visit(i + 1) {
				return true
			}
			chosen = chosen[:len(chosen)-1]
		}
		return false
	}
	if visit(0) {
		return result, nil
	}
	return nil, fmt.Errorf("%w: no legal automatic response found", ErrInvalidAction)
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
