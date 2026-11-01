//go:build autotest

package runtime

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"
)

// CreateScenario is compiled out of production. Fixtures model a valid public
// transition point; only the initial conditions change, never Apply or scoring.
func (r *Repository) CreateScenario(config Config, name string) (State, error) {
	state, err := NewSession(config, func([]engine.Card) {})
	if err != nil {
		return State{}, err
	}
	parts := strings.Split(name, "/")
	switch parts[0] {
	case "declaration", "red":
		err = fixtureDeal(&state)
		if err == nil && parts[0] == "red" {
			for _, card := range []engine.Card{
				{Suit: engine.Spades, Rank: 9},
				{Suit: engine.Diamonds, Rank: 2},
				{Rank: 15},
			} {
				if err = moveFixtureHand(&state, card, 3); err != nil {
					break
				}
			}
		}
	case "fallback":
		err = fixtureDeal(&state)
		if err == nil && len(parts) == 2 {
			rank, parseErr := strconv.Atoi(parts[1])
			if parseErr != nil {
				err = ErrInvalidConfig
			} else {
				target := engine.Card{Suit: engine.Hearts, Rank: engine.Rank(rank)}
				if rank >= 15 {
					target.Suit = engine.NoSuit
				}
				err = moveFixtureTop(&state, target)
			}
		} else {
			err = ErrInvalidConfig
		}
	case "score", "comeback", "spring", "sky", "redfive", "redfive-captured", "pair", "tractor", "level-gap", "throw", "follow", "draw", "combo", "bottom":
		err = fixtureFinal(&state, parts)
	default:
		err = fmt.Errorf("%w: unknown scenario %q", ErrInvalidConfig, name)
	}
	if err != nil {
		return State{}, err
	}
	r.mu.Lock()
	defer r.mu.Unlock()
	if _, exists := r.sessions[state.ID]; exists {
		return State{}, ErrExists
	}
	r.sessions[state.ID] = &entry{state: state, receipts: make(map[string]receipt)}
	return clone(state), nil
}

func moveFixtureHand(s *State, target engine.Card, destination int) error {
	for _, card := range s.Hands[destination] {
		if card == target {
			return nil
		}
	}
	for seat := range s.Hands {
		for i, card := range s.Hands[seat] {
			if card == target {
				replace := -1
				for j := len(s.Hands[destination]) - 1; j >= 0; j-- {
					candidate := s.Hands[destination][j]
					if (candidate.Suit == engine.Hearts && candidate.Rank == 5) ||
						(candidate.Suit == engine.Spades && candidate.Rank == 9) ||
						(candidate.Suit == engine.Diamonds && candidate.Rank == 2) ||
						candidate.Rank == 15 {
						continue
					}
					replace = j
					break
				}
				if replace < 0 {
					return ErrCards
				}
				s.Hands[seat][i], s.Hands[destination][replace] = s.Hands[destination][replace], card
				return nil
			}
		}
	}
	return ErrCards
}

func fixtureDeal(s *State) error {
	prescribed := [4][]engine.Card{
		{{Suit: engine.Clubs, Rank: 2}, {Suit: engine.Clubs, Rank: 2, Copy: 1}},
		{{Rank: 15}, {Rank: 15, Copy: 1}},
		{{Rank: 16}, {Rank: 16, Copy: 1}},
		{{Suit: engine.Hearts, Rank: 5}, {Suit: engine.Hearts, Rank: 5, Copy: 1}},
	}
	used := map[engine.Card]bool{}
	for seat, cards := range prescribed {
		s.Hands[seat] = append([]engine.Card(nil), cards...)
		for _, card := range cards {
			used[card] = true
		}
	}
	remaining := []engine.Card{}
	for _, card := range Deck() {
		if !used[card] {
			remaining = append(remaining, card)
		}
	}
	for seat := range s.Hands {
		count := 25 - len(s.Hands[seat])
		s.Hands[seat] = append(s.Hands[seat], remaining[:count]...)
		remaining = remaining[count:]
	}
	s.Bottom = remaining
	return nil
}

func moveFixtureTop(s *State, target engine.Card) error {
	for seat := range s.Hands {
		for i, card := range s.Hands[seat] {
			if card == target {
				s.Hands[seat][i], s.Bottom[0] = s.Bottom[0], card
				return nil
			}
		}
	}
	for i, card := range s.Bottom {
		if card == target {
			s.Bottom[0], s.Bottom[i] = s.Bottom[i], s.Bottom[0]
			return nil
		}
	}
	return ErrCards
}

func fixtureFinal(s *State, parts []string) error {
	level, score, pair := 4, 0, false
	if parts[0] == "score" || parts[0] == "comeback" {
		if len(parts) < 3 || len(parts) > 4 {
			return ErrInvalidConfig
		}
		var err error
		level, err = strconv.Atoi(parts[1])
		if err != nil {
			return ErrInvalidConfig
		}
		score, err = strconv.Atoi(parts[2])
		if err != nil || score < 0 || score > 200 || score%5 != 0 {
			return ErrInvalidConfig
		}
		pair = len(parts) == 4 && parts[3] == "pair"
	}
	if level < 2 || level > 14 {
		return ErrInvalidConfig
	}
	s.Levels = [2]engine.Rank{engine.Rank(level), engine.RankTwo}
	s.Trump = engine.Trump{Suit: engine.Clubs, Level: engine.Rank(level)}
	s.Phase, s.Turn, s.Dealer, s.BottomOwner = Playing, 0, 0, 0
	s.Trick = Trick{Leader: 0, Winner: 0}
	s.Hands = [4][]engine.Card{}
	if parts[0] == "spring" {
		s.Levels[0], s.Trump.Level, s.HandNumber = engine.RankAce, engine.RankAce, 2
		team := 0
		s.FirstSkyTeam = &team
	}
	if parts[0] == "comeback" {
		// Seat 2 wins with the current level; bottom contains no points.
		s.Hands[0] = []engine.Card{{Suit: engine.Clubs, Rank: 3}}
		s.Hands[1] = []engine.Card{{Suit: engine.Clubs, Rank: engine.Rank(level)}}
		s.Hands[2] = []engine.Card{{Suit: engine.Clubs, Rank: 4}}
		s.Hands[3] = []engine.Card{{Suit: engine.Clubs, Rank: 6}}
	} else if parts[0] == "sky" {
		s.Hands[0] = []engine.Card{{Suit: engine.Clubs, Rank: 5}, {Suit: engine.Clubs, Rank: 10}, {Suit: engine.Clubs, Rank: 13}}
		for seat := 1; seat < 4; seat++ {
			rank := engine.Rank(6 + seat)
			s.Hands[seat] = []engine.Card{
				{Suit: engine.Spades, Rank: rank}, {Suit: engine.Spades, Rank: rank, Copy: 1},
				{Suit: engine.Diamonds, Rank: rank},
			}
		}
	} else {
		s.Hands[0] = []engine.Card{{Suit: engine.Hearts, Rank: 14}}
		s.Hands[1] = []engine.Card{{Suit: engine.Hearts, Rank: 9}}
		s.Hands[2] = []engine.Card{{Suit: engine.Hearts, Rank: 8}}
		s.Hands[3] = []engine.Card{{Suit: engine.Hearts, Rank: 7}}
		if level == 14 {
			// A is trump; lead an ordinary non-scoring ace-equivalent winner.
			s.Hands[0][0].Rank = 12
		}
	}
	switch parts[0] {
	case "redfive", "redfive-captured":
		s.Hands = [4][]engine.Card{
			{{Suit: engine.Hearts, Rank: 5}},
			{{Rank: 16}},
			{{Rank: 15}},
			{{Suit: engine.Clubs, Rank: 2}},
		}
		if parts[0] == "redfive-captured" {
			s.Hands[0], s.Hands[1] = s.Hands[1], s.Hands[0]
		}
	case "pair", "tractor", "level-gap", "throw", "follow", "bottom":
		width := 2
		if parts[0] == "tractor" {
			width = 4
		}
		if parts[0] == "bottom" && len(parts) == 2 {
			var parseErr error
			width, parseErr = strconv.Atoi(parts[1])
			if parseErr != nil || (width != 1 && width != 2 && width != 4 && width != 6) {
				return ErrInvalidConfig
			}
		}
		for seat := range s.Hands {
			s.Hands[seat] = nil
			for i := 0; i < width; i++ {
				rank := engine.Rank(6 + seat*2 + i/2)
				if parts[0] == "bottom" {
					rank = engine.Rank(3 + seat*3 + i/2)
					s.Trump.Level, s.Levels[0] = engine.RankTwo, engine.RankTwo
				}
				s.Hands[seat] = append(s.Hands[seat], engine.Card{Suit: engine.Spades, Rank: rank, Copy: uint8(i % 2)})
			}
		}
		if parts[0] == "throw" {
			s.Hands[0] = []engine.Card{{Suit: engine.Spades, Rank: 14}, {Suit: engine.Spades, Rank: 12}}
			s.Hands[1] = []engine.Card{{Suit: engine.Spades, Rank: 13}, {Suit: engine.Spades, Rank: 13, Copy: 1}}
			s.Hands[3] = []engine.Card{{Suit: engine.Spades, Rank: 9}, {Suit: engine.Spades, Rank: 9, Copy: 1}}
		}
		if parts[0] == "follow" {
			s.Hands[1] = append(s.Hands[1], engine.Card{Suit: engine.Hearts, Rank: 3}, engine.Card{Suit: engine.Hearts, Rank: 3, Copy: 1})
			for _, seat := range []int{0, 2, 3} {
				s.Hands[seat] = append(s.Hands[seat], engine.Card{Suit: engine.Diamonds, Rank: engine.Rank(6 + seat), Copy: 0},
					engine.Card{Suit: engine.Diamonds, Rank: engine.Rank(6 + seat), Copy: 1})
			}
		}
		if parts[0] == "level-gap" {
			s.Trump.Level, s.Levels[0] = engine.RankEight, engine.RankEight
			s.Hands[0] = []engine.Card{
				{Suit: engine.Spades, Rank: 7}, {Suit: engine.Spades, Rank: 7, Copy: 1},
				{Suit: engine.Spades, Rank: 8}, {Suit: engine.Spades, Rank: 8, Copy: 1},
			}
			s.Hands[1] = []engine.Card{{Suit: engine.Diamonds, Rank: 6}, {Suit: engine.Diamonds, Rank: 6, Copy: 1}}
		}
	case "draw", "combo":
		s.Hands = [4][]engine.Card{
			{{Suit: engine.Clubs, Rank: 5}, {Suit: engine.Clubs, Rank: 10}, {Suit: engine.Clubs, Rank: 13}},
			{{Rank: 16}, {Rank: 15}, {Suit: engine.Clubs, Rank: 2}, {Suit: engine.Diamonds, Rank: 3}},
			{{Suit: engine.Hearts, Rank: 5}, {Suit: engine.Clubs, Rank: 14}, {Suit: engine.Clubs, Rank: 12}, {Suit: engine.Diamonds, Rank: 6}},
			{{Suit: engine.Spades, Rank: 5}, {Suit: engine.Spades, Rank: 10}, {Suit: engine.Spades, Rank: 13}, {Suit: engine.Diamonds, Rank: 7}},
		}
		s.Hands[0] = append(s.Hands[0], engine.Card{Suit: engine.Diamonds, Rank: 8})
		if parts[0] == "combo" {
			s.Hands[0] = []engine.Card{
				{Suit: engine.Spades, Rank: 5}, {Suit: engine.Spades, Rank: 10}, {Suit: engine.Spades, Rank: 13},
				{Suit: engine.Diamonds, Rank: 8},
			}
			s.Hands[1] = []engine.Card{
				{Suit: engine.Clubs, Rank: 5}, {Suit: engine.Clubs, Rank: 10}, {Suit: engine.Clubs, Rank: 13},
				{Suit: engine.Diamonds, Rank: 3},
			}
			s.Hands[3] = []engine.Card{
				{Suit: engine.Diamonds, Rank: 9}, {Suit: engine.Diamonds, Rank: 9, Copy: 1},
				{Suit: engine.Diamonds, Rank: 7}, {Suit: engine.Diamonds, Rank: 7, Copy: 1},
			}
		}
	}
	if pair {
		for seat := range s.Hands {
			card := s.Hands[seat][0]
			card.Copy = 1
			s.Hands[seat] = append(s.Hands[seat], card)
		}
	}
	used := map[engine.Card]bool{}
	for _, hand := range s.Hands {
		for _, card := range hand {
			if card.Validate() != nil || used[card] {
				return ErrCards
			}
			used[card] = true
		}
	}
	s.Bottom = nil
	remaining := []engine.Card{}
	for _, card := range Deck() {
		if used[card] {
			continue
		}
		value, _ := engine.Points([]engine.Card{card})
		if len(s.Bottom) < 8 && value == 0 {
			s.Bottom = append(s.Bottom, card)
		} else {
			remaining = append(remaining, card)
		}
	}
	if len(s.Bottom) != 8 {
		return ErrCards
	}
	if parts[0] == "bottom" {
		for i, card := range remaining {
			value, _ := engine.Points([]engine.Card{card})
			if value == 5 {
				s.Bottom[0], remaining[i] = card, s.Bottom[0]
				break
			}
		}
	}
	// Previously played cards remain public, maintaining the 108-card inventory.
	s.Completed = []Trick{{Leader: 0, Winner: 1, Plays: []Played{{Seat: 0, Cards: remaining}}}}
	s.DefenderPoints = score
	return nil
}
