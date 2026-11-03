package runtime

import (
	"sort"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"
)

func (s *State) play(action Action) error {
	if err := s.ValidatePlay(action.Seat, action.Cards); err != nil {
		return err
	}
	cards := append([]engine.Card(nil), action.Cards...)
	s.Hands[action.Seat] = remove(s.Hands[action.Seat], cards)
	s.Trick.Plays = append(s.Trick.Plays, Played{Seat: action.Seat, Cards: cards})
	if len(s.Trick.Plays) == 1 {
		s.Trick.Winner = action.Seat
	} else {
		incumbent := s.Trick.Plays[0].Cards
		for _, play := range s.Trick.Plays {
			if play.Seat == s.Trick.Winner {
				incumbent = play.Cards
				break
			}
		}
		if s.beats(cards, incumbent, s.Trick.Plays[0].Cards) {
			s.Trick.Winner = action.Seat
		}
	}
	s.Turn = (action.Seat + 1) % 4
	if len(s.Trick.Plays) != 4 {
		return nil
	}
	var trickCards, winning []engine.Card
	for _, play := range s.Trick.Plays {
		trickCards = append(trickCards, play.Cards...)
		if play.Seat == s.Trick.Winner {
			winning = play.Cards
		}
	}
	points, err := engine.Points(trickCards)
	if err != nil {
		return err
	}
	if s.Trick.Winner%2 != s.Dealer%2 {
		s.DefenderPoints += points
		s.Trick.CapturedPoints = points
	}
	s.Completed = append(s.Completed, s.Trick)
	if len(s.Hands[0]) != 0 {
		s.Turn = s.Trick.Winner
		s.Trick = Trick{Leader: s.Turn, Winner: s.Turn}
		return nil
	}
	bottomPoints, err := engine.Points(s.Bottom)
	if err != nil {
		return err
	}
	shape, err := engine.ClassifyPlay(winning, s.Trump)
	if err != nil {
		shape = s.bottomShape(winning)
	}
	// The business rules specify no 510k bottom multiplier. It is three
	// singles for bottom scoring; its separate sky-earth override still applies.
	if shape.Kind == engine.Play510K {
		shape = engine.PlayShape{Kind: engine.PlaySingle}
	}
	score, err := engine.ScoreHand(s.DefenderPoints, bottomPoints,
		s.Trick.Winner%2 != s.Dealer%2, shape.Kind, shape.PairCount)
	if err != nil {
		return err
	}
	return s.settle(score, winning, s.Trick.Winner, false)
}

func (s State) ValidatePlay(seat int, cards []engine.Card) error {
	if s.Phase != Playing {
		return ErrPhase
	}
	if seat < 0 || seat > 3 {
		return ErrInvalidAction
	}
	if seat != s.Turn {
		return ErrTurn
	}
	if len(cards) == 0 || !owns(s.Hands[seat], cards) {
		return ErrCards
	}
	if len(s.Trick.Plays) == 0 {
		return s.validateLead(cards)
	}
	return s.validateFollow(s.Hands[seat], s.Trick.Plays[0].Cards, cards)
}

func (s State) suit(card engine.Card) engine.Suit {
	if engine.IsTrump(card, s.Trump) {
		return engine.NoSuit
	}
	return card.Suit
}

func (s State) sameSuit(cards []engine.Card) bool {
	if len(cards) == 0 {
		return false
	}
	for _, card := range cards[1:] {
		if s.suit(card) != s.suit(cards[0]) {
			return false
		}
	}
	return true
}

// parts decomposes a throw deterministically, preserving 510k as an indivisible
// component. Pairs and tractors are extracted before remaining singles.
func (s State) parts(cards []engine.Card) [][]engine.Card {
	remaining := append([]engine.Card(nil), cards...)
	sort.Slice(remaining, func(i, j int) bool {
		a, b := remaining[i], remaining[j]
		if a.Suit != b.Suit {
			return a.Suit < b.Suit
		}
		if a.Rank != b.Rank {
			return a.Rank < b.Rank
		}
		return a.Copy < b.Copy
	})
	var result [][]engine.Card
	for suit := engine.Clubs; suit <= engine.Spades; suit++ {
		for {
			var group []engine.Card
			for _, rank := range []engine.Rank{engine.RankFive, engine.RankTen, engine.RankKing} {
				for _, card := range remaining {
					if card.Suit == suit && card.Rank == rank {
						group = append(group, card)
						break
					}
				}
			}
			if len(group) != 3 {
				break
			}
			result = append(result, group)
			remaining = remove(remaining, group)
		}
	}
	var pairs [][]engine.Card
	for i := 0; i+1 < len(remaining); {
		if engine.IsPair(remaining[i : i+2]) {
			group := append([]engine.Card(nil), remaining[i:i+2]...)
			pairs = append(pairs, group)
			remaining = remove(remaining, group)
		} else {
			i++
		}
	}
	for i := 0; i < len(pairs); {
		group := append([]engine.Card(nil), pairs[i]...)
		j := i + 1
		for j < len(pairs) && engine.IsTractor(append(append([]engine.Card(nil), group...), pairs[j]...), s.Trump) {
			group = append(group, pairs[j]...)
			j++
		}
		result = append(result, group)
		i = j
	}
	for _, card := range remaining {
		result = append(result, []engine.Card{card})
	}
	sort.SliceStable(result, func(i, j int) bool {
		iMain := engine.Is510K(result[i]) && result[i][0].Suit == s.Trump.Suit
		jMain := engine.Is510K(result[j]) && result[j][0].Suit == s.Trump.Suit
		return iMain && !jMain
	})
	return result
}

func (s State) validateLead(cards []engine.Card) error {
	parts := s.parts(cards)
	main510 := false
	for _, part := range parts {
		if engine.Is510K(part) && part[0].Suit == s.Trump.Suit {
			main510 = true
		}
	}
	if main510 {
		mainCount := 0
		for _, part := range parts {
			if engine.Is510K(part) && part[0].Suit == s.Trump.Suit {
				mainCount++
				continue
			}
			for _, card := range part {
				if engine.IsTrump(card, s.Trump) {
					return engine.ErrInvalidPlay
				}
			}
		}
		if mainCount != 1 {
			return engine.ErrInvalidPlay
		}
	} else if !s.sameSuit(cards) && !engine.Is510K(cards) {
		// A side-suit 510k remains one combination even when its five or
		// level card would individually be trump.
		with510 := false
		for _, part := range parts {
			with510 = with510 || engine.Is510K(part)
			if !engine.Is510K(part) {
				for _, card := range part {
					if engine.IsTrump(card, s.Trump) {
						return engine.ErrInvalidPlay
					}
				}
			}
		}
		for _, card := range cards {
			if !with510 || card.Suit != cards[0].Suit {
				return engine.ErrInvalidPlay
			}
		}
	}
	shape, shapeErr := engine.ClassifyPlay(cards, s.Trump)
	if shapeErr == nil && shape.Kind != engine.PlayTwoPairs {
		return nil
	}
	for _, part := range parts {
		if engine.Is510K(part) {
			continue
		}
		for seat, hand := range s.Hands {
			if seat == s.Turn {
				continue
			}
			for _, candidate := range s.groups(hand, part) {
				if s.suit(candidate[0]) == s.suit(part[0]) && s.compare(candidate, part, part) > 0 {
					return engine.ErrInvalidPlay
				}
			}
		}
	}
	return nil
}

// groups enumerates comparable components, not arbitrary hand subsets.
func (s State) groups(hand, model []engine.Card) [][]engine.Card {
	if len(model) == 1 {
		groups := make([][]engine.Card, 0, len(hand))
		for _, card := range hand {
			groups = append(groups, []engine.Card{card})
		}
		return groups
	}
	var pairs [][]engine.Card
	for i := range hand {
		for j := i + 1; j < len(hand); j++ {
			group := []engine.Card{hand[i], hand[j]}
			if engine.IsPair(group) {
				pairs = append(pairs, group)
			}
		}
	}
	if len(model) == 2 {
		return pairs
	}
	var result [][]engine.Card
	var visit func(int, []engine.Card)
	visit = func(start int, selected []engine.Card) {
		if len(selected) == len(model) {
			if engine.IsTractor(selected, s.Trump) {
				result = append(result, append([]engine.Card(nil), selected...))
			}
			return
		}
		for i := start; i < len(pairs); i++ {
			visit(i+1, append(append([]engine.Card(nil), selected...), pairs[i]...))
		}
	}
	visit(0, nil)
	return result
}

func (s State) validateFollow(hand, lead, response []engine.Card) error {
	if len(response) != len(lead) {
		return engine.ErrInvalidPlay
	}
	if engine.Is510K(lead) && lead[0].Suit == s.Trump.Suit {
		return s.validateDraw(hand, response)
	}
	if !s.sameSuit(lead) && !engine.Is510K(lead) {
		return s.validateCompoundFollow(hand, s.parts(lead), response)
	}
	leadSuit := s.suit(lead[0])
	if engine.Is510K(lead) && lead[0].Suit != s.Trump.Suit {
		leadSuit = lead[0].Suit
	}
	held, played := filter(hand, func(card engine.Card) bool { return s.suit(card) == leadSuit }),
		filter(response, func(card engine.Card) bool { return s.suit(card) == leadSuit })
	need := len(lead)
	if len(held) < need {
		need = len(held)
	}
	if len(played) != need {
		return engine.ErrInvalidPlay
	}
	// Use the engine's validation when physical and effective suits coincide.
	equivalent := true
	for _, card := range append(append([]engine.Card(nil), hand...), lead...) {
		if engine.IsTrump(card, s.Trump) {
			equivalent = false
			break
		}
	}
	if equivalent {
		if err := engine.ValidateResponse(hand, lead, response, s.Trump); err != nil {
			return err
		}
	}
	// Follow the lead's pair/tractor structure whenever the hand allows it.
	return s.validateStructure(held, lead, played)
}

func (s State) validateDraw(hand, response []engine.Card) error {
	forced, err := engine.ForcedDrawCards(hand, s.Trump)
	if err != nil {
		return err
	}
	var threshold *engine.Card
	for _, card := range forced {
		if engine.IsTrump(card, s.Trump) {
			c := card
			threshold = &c
		}
	}
	heldTrump := filter(hand, func(card engine.Card) bool { return engine.IsTrump(card, s.Trump) })
	playedTrump := filter(response, func(card engine.Card) bool { return engine.IsTrump(card, s.Trump) })
	need := len(heldTrump)
	if need > 3 {
		need = 3
	}
	if len(playedTrump) != need {
		return engine.ErrInvalidPlay
	}
	if threshold != nil {
		for _, card := range playedTrump {
			cmp, _ := engine.CompareCards(card, *threshold, s.Trump)
			if cmp < 0 {
				return engine.ErrInvalidPlay
			}
		}
		for _, card := range remove(heldTrump, playedTrump) {
			cmp, _ := engine.CompareCards(card, *threshold, s.Trump)
			if cmp > 0 {
				return engine.ErrInvalidPlay
			}
		}
	}
	return nil
}

func (s State) validateCompoundFollow(hand []engine.Card, parts [][]engine.Card, response []engine.Card) error {
	// Allocate the main 510k draw first; the remaining side-suit components
	// then follow independently. Search only the three-card draw selection.
	if len(parts) == 0 {
		return engine.ErrInvalidPlay
	}
	first := parts[0]
	if engine.Is510K(first) && first[0].Suit == s.Trump.Suit {
		for i := 0; i < len(response); i++ {
			for j := i + 1; j < len(response); j++ {
				for k := j + 1; k < len(response); k++ {
					draw := []engine.Card{response[i], response[j], response[k]}
					if s.validateDraw(hand, draw) == nil &&
						s.validateSideComponents(remove(hand, draw), parts[1:], remove(response, draw)) == nil {
						return nil
					}
				}
			}
		}
		return engine.ErrInvalidPlay
	}
	return s.validateSideComponents(hand, parts, response)
}

func (s State) validateSideComponents(hand []engine.Card, parts [][]engine.Card, response []engine.Card) error {
	groups := map[engine.Suit][]engine.Card{}
	total := 0
	for _, part := range parts {
		suit := s.suit(part[0])
		if engine.Is510K(part) {
			suit = part[0].Suit
		}
		groups[suit] = append(groups[suit], part...)
		total += len(part)
	}
	if total != len(response) {
		return engine.ErrInvalidPlay
	}
	for suit, lead := range groups {
		held := filter(hand, func(card engine.Card) bool { return s.suit(card) == suit })
		played := filter(response, func(card engine.Card) bool { return s.suit(card) == suit })
		required := len(lead)
		if len(held) < required {
			required = len(held)
		}
		if len(played) < required || s.validateStructure(held, lead, played) != nil {
			return engine.ErrInvalidPlay
		}
	}
	return nil
}

func (s State) validateStructure(held, lead, played []engine.Card) error {
	requiredPairs := 0
	parts := s.parts(lead)
	if shape, err := engine.ClassifyPlay(lead, s.Trump); err == nil &&
		(shape.Kind == engine.PlayPair || shape.Kind == engine.PlayTwoPairs || shape.Kind == engine.PlayTractor) {
		parts = [][]engine.Card{lead}
	}
	for _, part := range parts {
		if shape, err := engine.ClassifyPlay(part, s.Trump); err == nil {
			requiredPairs += shape.PairCount
		}
		if engine.IsTractor(part, s.Trump) && len(s.groups(held, part)) > 0 {
			if len(s.groups(played, part)) == 0 {
				return engine.ErrInvalidPlay
			}
		}
	}
	if requiredPairs > pairCount(held) {
		requiredPairs = pairCount(held)
	}
	if pairCount(played) < requiredPairs {
		return engine.ErrInvalidPlay
	}
	return nil
}

func (s State) compare(candidate, incumbent, lead []engine.Card) int {
	leadSuit := lead[0].Suit
	if leadSuit == engine.NoSuit {
		leadSuit = engine.Clubs // Engine requires a physical suit, even for joker leads.
	}
	cmp, err := engine.ComparePlays(candidate, incumbent, leadSuit, s.Trump)
	if err != nil {
		return 0
	}
	return cmp
}

func (s State) eligible(cards, lead []engine.Card) bool {
	cs, ce := engine.ClassifyPlay(cards, s.Trump)
	ls, le := engine.ClassifyPlay(lead, s.Trump)
	if ce != nil || le != nil || cs != ls {
		return false
	}
	if cs.Kind == engine.Play510K {
		return cards[0].Suit == lead[0].Suit || cards[0].Suit == s.Trump.Suit
	}
	if !s.sameSuit(cards) {
		return false
	}
	return s.suit(cards[0]) == s.suit(lead[0]) || s.suit(cards[0]) == engine.NoSuit
}

func (s State) beats(candidate, incumbent, lead []engine.Card) bool {
	if _, err := engine.ClassifyPlay(lead, s.Trump); err == nil {
		if !s.eligible(candidate, lead) {
			return false
		}
		return !s.eligible(incumbent, lead) || s.compare(candidate, incumbent, lead) > 0
	}
	lp, cp, ip := s.parts(lead), s.parts(candidate), s.parts(incumbent)
	if len(lp) != len(cp) || len(lp) != len(ip) {
		return false
	}
	higher := false
	for i := range lp {
		if !s.eligible(cp[i], lp[i]) {
			return false
		}
		cmp := s.compare(cp[i], ip[i], lp[i])
		if !s.eligible(ip[i], lp[i]) {
			cmp = 1
		}
		if cmp < 0 {
			return false
		}
		higher = higher || cmp > 0
	}
	return higher
}

func (s State) bottomShape(cards []engine.Card) engine.PlayShape {
	best := engine.PlayShape{Kind: engine.PlaySingle}
	pairsBySuit := map[engine.Suit]int{}
	for _, part := range s.parts(cards) {
		shape, err := engine.ClassifyPlay(part, s.Trump)
		if err == nil && shape.PairCount > best.PairCount {
			best = shape
		}
		if err == nil && shape.PairCount > 0 {
			pairsBySuit[part[0].Suit] += shape.PairCount
		}
	}
	for _, pairs := range pairsBySuit {
		if pairs >= 2 && best.PairCount < 2 {
			best = engine.PlayShape{Kind: engine.PlayTwoPairs, PairCount: 2}
		}
	}
	return best
}

func filter(cards []engine.Card, include func(engine.Card) bool) []engine.Card {
	var result []engine.Card
	for _, card := range cards {
		if include(card) {
			result = append(result, card)
		}
	}
	return result
}

func pairCount(cards []engine.Card) int {
	count := 0
	for i := range cards {
		for j := i + 1; j < len(cards); j++ {
			if engine.IsPair([]engine.Card{cards[i], cards[j]}) {
				count++
			}
		}
	}
	return count
}
