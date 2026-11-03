package runtime

import (
	"sort"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"
)

func sortHand(cards []engine.Card, trump engine.Trump) {
	suitOrder := func(suit engine.Suit) int {
		switch suit {
		case engine.Spades:
			return 0
		case engine.Hearts:
			return 1
		case engine.Clubs:
			return 2
		default:
			return 3
		}
	}
	group := func(c engine.Card) int {
		switch {
		case c.Suit == engine.Hearts && c.Rank == engine.RankFive:
			return 0
		case c.Rank == engine.RankBigJoker:
			return 1
		case c.Rank == engine.RankSmallJoker:
			return 2
		case c.Rank == trump.Level && c.Suit == trump.Suit:
			return 3
		case c.Rank == trump.Level:
			return 4
		case c.Suit == trump.Suit:
			return 5
		default:
			return 6 + suitOrder(c.Suit)
		}
	}
	sort.SliceStable(cards, func(i, j int) bool {
		a, b := cards[i], cards[j]
		if group(a) != group(b) {
			return group(a) < group(b)
		}
		if a.Rank != b.Rank {
			return a.Rank > b.Rank
		}
		if a.Suit != b.Suit {
			return suitOrder(a.Suit) < suitOrder(b.Suit)
		}
		return a.Copy < b.Copy
	})
}
