package runtime

import "github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"

// Apply is transactional: neither state nor action is mutated on success or
// failure. Request deduplication belongs to Repository.Submit.
func Apply(state State, action Action, shuffle Shuffle) (State, error) {
	if action.Seat < 0 || action.Seat > 3 || action.RequestID == "" || len(action.RequestID) > 128 {
		return State{}, ErrInvalidAction
	}
	if action.ExpectedVersion != state.Version {
		return State{}, ErrVersion
	}
	if len(action.Cards) != 0 && action.Kind != Declare && action.Kind != CounterTrump &&
		action.Kind != BuryCards && action.Kind != PlayCards {
		return State{}, ErrInvalidAction
	}
	next := clone(state)
	var err error
	switch action.Kind {
	case Declare:
		err = next.declare(action)
	case Pass:
		err = next.pass(action)
	case CounterTrump:
		err = next.counter(action)
	case LookBack:
		err = next.lookBack(action)
	case BuryCards:
		err = next.bury(action)
	case PlayCards:
		err = next.play(action)
	case Continue:
		err = next.continueHand(action, shuffle)
	default:
		err = ErrInvalidAction
	}
	if err != nil {
		return State{}, err
	}
	next.Version++
	return next, nil
}

func (s *State) declare(action Action) error {
	if s.Phase != Declaration {
		return ErrPhase
	}
	if len(action.Cards) != 1 || !owns(s.Hands[action.Seat], action.Cards) {
		return ErrCards
	}
	trump, err := engine.TrumpFromLevelCard(action.Cards[0], s.Trump.Level)
	if err != nil {
		return err
	}
	s.Trump, s.Declarer = trump, action.Seat
	card := action.Cards[0]
	s.DeclaredCard = &card
	s.pickBottom(s.Dealer)
	return nil
}

func (s *State) pass(action Action) error {
	if s.Phase != Declaration && s.Phase != Counter {
		return ErrPhase
	}
	if action.Seat != s.Turn {
		return ErrTurn
	}
	if s.Phase == Declaration {
		s.DeclarationPasses++
		s.Turn = (s.Turn + 1) % 4
		if s.DeclarationPasses == 4 {
			trump, err := engine.FallbackTrump(s.Bottom[0], s.Trump.Level)
			if err != nil {
				return err
			}
			s.Trump = trump
			s.pickBottom(s.Dealer)
		}
		return nil
	}
	s.CounterPasses++
	if s.CounterPasses == 3 {
		s.startPlaying()
	} else {
		s.Turn = (s.Turn + 1) % 4
	}
	return nil
}

func (s *State) pickBottom(seat int) {
	s.Hands[seat] = append(s.Hands[seat], s.Bottom...)
	s.Bottom = nil
	s.BottomOwner, s.Turn, s.Phase = seat, seat, Bury
}

func (s *State) bury(action Action) error {
	if s.Phase != Bury {
		return ErrPhase
	}
	if s.Turn != action.Seat {
		return ErrTurn
	}
	if len(action.Cards) != 8 || !owns(s.Hands[action.Seat], action.Cards) {
		return ErrCards
	}
	s.Hands[action.Seat] = remove(s.Hands[action.Seat], action.Cards)
	s.Bottom = append([]engine.Card(nil), action.Cards...)
	if s.FinalTrump {
		s.startPlaying()
		return nil
	}
	s.Phase, s.Turn, s.CounterPasses = Counter, (action.Seat+1)%4, 0
	if s.InitialBury && s.Turn == s.Declarer {
		s.Turn = (s.Turn + 1) % 4
	}
	s.InitialBury = false
	return nil
}

func (s *State) counter(action Action) error {
	if s.Phase != Counter {
		return ErrPhase
	}
	if action.Seat != s.Turn {
		return ErrTurn
	}
	if len(action.Cards) != 2 || !owns(s.Hands[action.Seat], action.Cards) {
		return ErrCards
	}
	trump, kind, err := engine.DetermineCounterTrump(action.Cards, s.Trump.Level)
	if err != nil {
		return err
	}
	if kind == engine.CounterRedFive {
		count := 0
		for _, card := range s.Hands[action.Seat] {
			if card.Suit == engine.Hearts && card.Rank == engine.RankFive {
				count++
			}
		}
		if count != 2 {
			return ErrCards
		}
	}
	if s.CounterKind != 0 {
		comparison, err := engine.CompareCounterTrump(kind, s.CounterKind)
		if err != nil {
			return err
		}
		if comparison == 0 {
			return engine.ErrInvalidCounter
		}
		if comparison < 0 {
			score := 0
			if action.Seat%2 == s.Dealer%2 {
				score = 200
			}
			return s.settle(score, nil, -1, true)
		}
	}
	s.Trump, s.CounterKind, s.Countered = trump, kind, true
	s.CounterProof = append([]engine.Card(nil), action.Cards...)
	s.pickBottom(action.Seat)
	return nil
}

func (s *State) lookBack(action Action) error {
	if s.Phase != Counter {
		return ErrPhase
	}
	if action.Seat != s.Turn {
		return ErrTurn
	}
	if action.Seat != s.Declarer || !s.Countered || s.DeclaredCard == nil {
		return ErrInvalidAction
	}
	trump, err := engine.TrumpFromLevelCard(*s.DeclaredCard, s.Trump.Level)
	if err != nil {
		return err
	}
	s.Trump, s.FinalTrump = trump, true
	s.pickBottom(action.Seat)
	return nil
}

func (s *State) startPlaying() {
	s.Phase, s.Turn = Playing, s.Dealer
	s.Trick = Trick{Leader: s.Dealer, Winner: s.Dealer}
}

func (s *State) continueHand(action Action, shuffle Shuffle) error {
	if s.Phase != HandOver {
		return ErrPhase
	}
	if s.Ready[action.Seat] {
		return ErrInvalidAction
	}
	s.Ready[action.Seat] = true
	for _, ready := range s.Ready {
		if !ready {
			return nil
		}
	}
	s.Dealer = s.Result.NextDealer
	return deal(s, shuffle)
}

func (s *State) settle(score int, winning []engine.Card, winner int, fault bool) error {
	dealerTeam := s.Dealer % 2
	side := engine.DealerSide
	if winner >= 0 && winner%2 != dealerTeam {
		side = engine.DefenderSide
	}
	resolution, err := engine.ResolveHand(engine.HandInput{
		DealerLevel: s.Levels[dealerTeam], DefenderLevel: s.Levels[1-dealerTeam],
		DefenderScore: score, FinalTrick: winning, FinalTrickWinner: side,
		BottomCaptured: !fault && side == engine.DefenderSide,
	})
	if err != nil {
		return err
	}
	// The engine exposes score settlement separately from advancement barriers.
	// A normal advance may reach J, but cannot skip the unplayed mandatory J.
	if !resolution.Comeback && s.Levels[dealerTeam] < engine.RankJack &&
		resolution.DealerLevel > engine.RankJack {
		resolution.DealerLevel = engine.RankJack
	}
	if s.Levels[1-dealerTeam] < engine.RankJack &&
		s.Trump.Level != engine.RankJack && s.Trump.Level != engine.RankAce &&
		resolution.DefenderLevel > engine.RankJack {
		resolution.DefenderLevel = engine.RankJack
	}
	if resolution.NextDealer == engine.DefenderSide &&
		s.Trump.Level != engine.RankTwo && s.Trump.Level != engine.RankJack && s.Trump.Level != engine.RankAce {
		defenderLevel := s.Levels[1-dealerTeam]
		if defenderLevel == engine.RankTwo || defenderLevel == engine.RankJack || defenderLevel == engine.RankAce {
			// Capturing points cannot clear the incoming team's unplayed
			// mandatory level. The current mandatory-level table takes priority.
			resolution.DefenderLevel = defenderLevel
		}
	}
	result := &Result{
		DefenderScore: score, BottomCaptured: !fault && side == engine.DefenderSide,
		Resolution: resolution, CounterFault: fault,
	}
	s.Levels[dealerTeam], s.Levels[1-dealerTeam] = resolution.DealerLevel, resolution.DefenderLevel
	result.WinnerTeam = dealerTeam
	result.NextDealer = (s.Dealer + 2) % 4
	if resolution.NextDealer == engine.DefenderSide {
		result.WinnerTeam = 1 - dealerTeam
		result.NextDealer = (s.Dealer + 1) % 4
	}
	if !fault && len(s.Trick.Plays) == 4 && engine.Has510K(s.Trick.Plays[0].Cards) {
		lead := s.Trick.Plays[0]
		playedSide := engine.DealerSide
		if lead.Seat%2 != dealerTeam {
			playedSide = engine.DefenderSide
		}
		var played510K, final510K []engine.Card
		for _, part := range s.parts(lead.Cards) {
			if engine.Is510K(part) {
				played510K = part
				break
			}
		}
		for _, part := range s.parts(winning) {
			if engine.Is510K(part) {
				final510K = part
				break
			}
		}
		sky, err := engine.ResolveSkyEarth(engine.SkyEarthInput{
			MainSuit: s.Trump.Suit, Played510K: played510K, Final510K: final510K,
			PlayedBy: playedSide, FinalWinner: side, IsFinalPlay: true, HandEmptyAfter: true,
		})
		if err != nil {
			return err
		}
		if sky.Triggered {
			result.SkyEarth = true
			result.WinnerTeam = winner % 2
			s.Levels[result.WinnerTeam], s.Levels[1-result.WinnerTeam] = engine.RankAce, engine.RankTwo
			result.Resolution.DealerLevel = s.Levels[dealerTeam]
			result.Resolution.DefenderLevel = s.Levels[1-dealerTeam]
			result.Resolution.NextDealer = sky.NextDealer
			result.Resolution.Winner = sky.Winner
			result.Resolution.GameWon = false
			result.Resolution.NaturalLevel = false
			result.Resolution.Comeback = false
			result.NextDealer = (s.Dealer + 2) % 4
			if sky.NextDealer == engine.DefenderSide {
				result.NextDealer = (s.Dealer + 1) % 4
			}
			if s.HandNumber == 1 {
				team := result.WinnerTeam
				s.FirstSkyTeam = &team
			}
		}
	}
	result.Spring = s.FirstSkyTeam != nil && *s.FirstSkyTeam == dealerTeam &&
		engine.IsSpring(true, s.HandNumber, s.Trump.Level,
			result.Resolution.GameWon && result.WinnerTeam == dealerTeam, score)
	s.Phase, s.Result, s.Turn = HandOver, result, -1
	if result.Resolution.GameWon {
		s.Phase = Finished
	}
	return nil
}
