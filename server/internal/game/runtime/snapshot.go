package runtime

import "github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"

// AvailableAction describes a private action opportunity, not a robot strategy.
// Cards is populated for declaration/counter proofs. Bury/play require the
// caller to select Count cards from Hand and submit them for validation.
type AvailableAction struct {
	Kind  ActionKind    `json:"kind"`
	Cards []engine.Card `json:"cards,omitempty"`
	Count int           `json:"count,omitempty"`
}

type Snapshot struct {
	ID             string             `json:"id"`
	Players        [4]string          `json:"players"`
	Practice       bool               `json:"practice"`
	Version        uint64             `json:"version"`
	HandNumber     int                `json:"hand_number"`
	Phase          Phase              `json:"phase"`
	Dealer         int                `json:"dealer"`
	Turn           int                `json:"turn"`
	BottomOwner    int                `json:"bottom_owner"`
	Levels         [2]engine.Rank     `json:"levels"`
	Trump          engine.Trump       `json:"trump"`
	CounterKind    engine.CounterKind `json:"counter_kind"`
	Seat           int                `json:"seat"`
	Hand           []engine.Card      `json:"hand,omitempty"`
	SuggestedPlay  []engine.Card      `json:"suggested_play,omitempty"`
	HandCounts     [4]int             `json:"hand_counts"`
	Bottom         []engine.Card      `json:"bottom,omitempty"`
	BottomCount    int                `json:"bottom_count"`
	BottomPublic   bool               `json:"bottom_public"`
	Declarer       int                `json:"declarer"`
	CounterPasses  int                `json:"counter_passes"`
	Countered      bool               `json:"countered"`
	FinalTrump     bool               `json:"final_trump"`
	Trick          Trick              `json:"trick"`
	Completed      []Trick            `json:"completed"`
	DefenderPoints int                `json:"defender_points"`
	Ready          [4]bool            `json:"ready"`
	Result         *Result            `json:"result,omitempty"`
	Actions        []AvailableAction  `json:"actions"`
}

// View returns an isolated, personalized view. Seat -1 is a closed-hand
// spectator; even spectators cannot obtain hidden declaration/counter proofs.
func View(state State, seat int) (Snapshot, error) {
	if seat < -1 || seat > 3 {
		return Snapshot{}, ErrInvalidAction
	}
	s := clone(state)
	view := Snapshot{
		ID: s.ID, Players: s.Players, Practice: s.Practice, Version: s.Version,
		HandNumber: s.HandNumber, Phase: s.Phase, Dealer: s.Dealer, Turn: s.Turn,
		BottomOwner: s.BottomOwner, Levels: s.Levels, Trump: s.Trump,
		CounterKind: s.CounterKind, Seat: seat, BottomCount: len(s.Bottom),
		Declarer: s.Declarer, CounterPasses: s.CounterPasses, Countered: s.Countered,
		FinalTrump: s.FinalTrump, Trick: s.Trick, Completed: s.Completed,
		DefenderPoints: s.DefenderPoints, Ready: s.Ready, Result: s.Result,
		Actions: []AvailableAction{},
	}
	for i := range s.Hands {
		view.HandCounts[i] = len(s.Hands[i])
	}
	view.BottomPublic = s.Result != nil && s.Result.BottomCaptured
	if view.BottomPublic {
		view.Bottom = s.Bottom
	}
	if seat == -1 {
		return view, nil
	}
	view.Hand = s.Hands[seat]
	if seat == s.BottomOwner {
		view.Bottom = s.Bottom
	}
	if s.Phase == Playing && s.Turn == seat {
		if play, err := choosePlay(s, seat); err == nil {
			view.SuggestedPlay = play
		}
	}
	add := func(kind ActionKind, cards []engine.Card, count int) {
		view.Actions = append(view.Actions, AvailableAction{Kind: kind, Cards: cards, Count: count})
	}
	if s.Phase == Declaration {
		for _, card := range s.Hands[seat] {
			if card.Rank == s.Trump.Level {
				add(Declare, []engine.Card{card}, 1)
			}
		}
		if s.Turn == seat {
			add(Pass, nil, 0)
		}
		return view, nil
	}
	if s.Phase == HandOver && !s.Ready[seat] {
		add(Continue, nil, 0)
	}
	if s.Turn != seat {
		return view, nil
	}
	switch s.Phase {
	case Bury:
		add(BuryCards, nil, 8)
	case Playing:
		count := 0 // The leader chooses a nonempty legal combination.
		if len(s.Trick.Plays) > 0 {
			count = len(s.Trick.Plays[0].Cards)
		}
		add(PlayCards, nil, count)
	case Counter:
		add(Pass, nil, 0)
		if s.Declarer == seat && s.Countered {
			add(LookBack, nil, 0)
		}
		for i := range s.Hands[seat] {
			for j := i + 1; j < len(s.Hands[seat]); j++ {
				cards := []engine.Card{s.Hands[seat][i], s.Hands[seat][j]}
				_, kind, err := engine.DetermineCounterTrump(cards, s.Trump.Level)
				if err != nil || kind <= s.CounterKind {
					continue
				}
				test := clone(s)
				if test.counter(Action{Seat: seat, Cards: cards}) == nil {
					add(CounterTrump, cards, 2)
				}
			}
		}
	}
	return view, nil
}
