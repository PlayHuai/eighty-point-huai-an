// Package runtime implements the authoritative, transport-independent game
// state machine. State is private server data; only Snapshot may be sent to a
// player. Seats are zero-based, clockwise, with opposite seats on the same team.
package runtime

import (
	"crypto/rand"
	"encoding/json"
	"errors"
	"math/big"

	"github.com/Derek0120/eighty-point-huai-an/server/internal/game/engine"
)

type Phase string

const (
	Declaration Phase = "declaration"
	Bury        Phase = "bury"
	Counter     Phase = "counter"
	Playing     Phase = "playing"
	HandOver    Phase = "hand_over"
	Finished    Phase = "finished"
)

type ActionKind string

const (
	Declare  ActionKind = "declare"
	Pass     ActionKind = "pass"
	CounterTrump ActionKind = "counter"
	LookBack ActionKind = "look_back"
	BuryCards ActionKind = "bury"
	PlayCards ActionKind = "play"
	Continue ActionKind = "continue"
)

var (
	ErrInvalidConfig = errors.New("invalid session configuration")
	ErrInvalidAction = errors.New("invalid action")
	ErrPhase         = errors.New("action is not allowed in this phase")
	ErrTurn          = errors.New("not this player's turn")
	ErrCards         = errors.New("invalid or unowned cards")
	ErrVersion       = errors.New("session version conflict")
	ErrRequest       = errors.New("request ID reused with different action")
	ErrNotFound      = errors.New("session not found")
	ErrExists        = errors.New("session already exists")
)

// Shuffle must only permute cards. The resulting deck is validated before use.
// Inject a seeded rand.Rand.Shuffle adapter for reproducible games.
type Shuffle func([]engine.Card)

type Config struct {
	ID       string
	Players  [4]string
	Practice bool
	Dealer   int
	Levels   [2]engine.Rank // Zero values start both teams at 2.
}

type Played struct {
	Seat  int           `json:"seat"`
	Cards []engine.Card `json:"cards"`
}

type Trick struct {
	Leader int      `json:"leader"`
	Plays  []Played `json:"plays"`
	Winner int      `json:"winner"`
}

type Result struct {
	DefenderScore int                   `json:"defender_score"`
	Resolution    engine.HandResolution `json:"resolution"`
	NextDealer    int                   `json:"next_dealer"`
	WinnerTeam    int                   `json:"winner_team"`
	SkyEarth      bool                  `json:"sky_earth"`
	Spring        bool                  `json:"spring"`
	CounterFault  bool                  `json:"counter_fault"`
}

// State contains hidden hands, bottom cards and declaration proofs. Persisting
// practice State is prohibited; the repository deliberately has no storage hook.
type State struct {
	ID           string                `json:"id"`
	Players      [4]string             `json:"players"`
	Practice     bool                  `json:"practice"`
	Version      uint64                `json:"version"`
	HandNumber   int                   `json:"hand_number"`
	Phase        Phase                 `json:"phase"`
	Dealer       int                   `json:"dealer"`
	Turn         int                   `json:"turn"`
	Levels       [2]engine.Rank         `json:"levels"`
	Trump        engine.Trump          `json:"trump"`
	Hands        [4][]engine.Card       `json:"hands"`
	Bottom       []engine.Card         `json:"bottom"`
	BottomOwner  int                   `json:"bottom_owner"`
	Declarer     int                   `json:"declarer"`
	DeclaredCard *engine.Card          `json:"declared_card,omitempty"`
	DeclarationPasses int             `json:"declaration_passes"`
	CounterKind  engine.CounterKind    `json:"counter_kind"`
	CounterProof []engine.Card         `json:"counter_proof,omitempty"`
	CounterPasses int                  `json:"counter_passes"`
	Countered    bool                  `json:"countered"`
	FinalTrump   bool                  `json:"final_trump"`
	InitialBury  bool                  `json:"initial_bury"`
	Trick        Trick                 `json:"trick"`
	Completed    []Trick               `json:"completed"`
	DefenderPoints int                 `json:"defender_points"`
	Ready        [4]bool               `json:"ready"`
	FirstSkyTeam *int                  `json:"first_sky_team,omitempty"`
	Result       *Result               `json:"result,omitempty"`
}

type Action struct {
	Seat            int           `json:"seat"`
	Kind            ActionKind    `json:"kind"`
	Cards           []engine.Card `json:"cards,omitempty"`
	RequestID       string        `json:"request_id"`
	ExpectedVersion uint64        `json:"expected_version"`
}

func NewSession(config Config, shuffle Shuffle) (State, error) {
	if config.ID == "" || config.Dealer < 0 || config.Dealer > 3 {
		return State{}, ErrInvalidConfig
	}
	seen := map[string]bool{}
	for _, player := range config.Players {
		if player == "" || seen[player] {
			return State{}, ErrInvalidConfig
		}
		seen[player] = true
	}
	for i := range config.Levels {
		if config.Levels[i] == 0 {
			config.Levels[i] = engine.RankTwo
		}
		if (engine.Trump{Level: config.Levels[i]}).Validate() != nil {
			return State{}, ErrInvalidConfig
		}
	}
	state := State{
		ID: config.ID, Players: config.Players, Practice: config.Practice,
		Version: 1, Dealer: config.Dealer, Levels: config.Levels,
	}
	if err := deal(&state, shuffle); err != nil {
		return State{}, err
	}
	return state, nil
}

func Deck() []engine.Card {
	cards := make([]engine.Card, 0, 108)
	for copyID := uint8(0); copyID < 2; copyID++ {
		for suit := engine.Clubs; suit <= engine.Spades; suit++ {
			for rank := engine.RankTwo; rank <= engine.RankAce; rank++ {
				cards = append(cards, engine.Card{Suit: suit, Rank: rank, Copy: copyID})
			}
		}
		cards = append(cards, engine.Card{Rank: engine.RankSmallJoker, Copy: copyID},
			engine.Card{Rank: engine.RankBigJoker, Copy: copyID})
	}
	return cards
}

func deal(state *State, shuffle Shuffle) error {
	cards := Deck()
	if shuffle == nil {
		for i := len(cards) - 1; i > 0; i-- {
			index, err := rand.Int(rand.Reader, big.NewInt(int64(i+1)))
			if err != nil {
				return err
			}
			j := int(index.Int64())
			cards[i], cards[j] = cards[j], cards[i]
		}
	} else {
		shuffle(cards)
	}
	if len(cards) != 108 || !unique(cards) {
		return ErrCards
	}
	for seat := range state.Hands {
		state.Hands[seat] = nil
	}
	for i, card := range cards[:100] {
		state.Hands[i%4] = append(state.Hands[i%4], card)
	}
	state.Bottom = append([]engine.Card(nil), cards[100:]...)
	state.HandNumber++
	state.Phase, state.Turn = Declaration, state.Dealer
	state.Trump = engine.Trump{Level: state.Levels[state.Dealer%2]}
	state.Declarer, state.BottomOwner = -1, -1
	state.DeclaredCard, state.CounterProof = nil, nil
	state.DeclarationPasses, state.CounterPasses, state.CounterKind = 0, 0, 0
	state.Countered, state.FinalTrump, state.InitialBury = false, false, true
	state.Trick, state.Completed = Trick{}, nil
	state.DefenderPoints, state.Ready, state.Result = 0, [4]bool{}, nil
	return nil
}

func clone(state State) State {
	data, _ := json.Marshal(state)
	var result State
	_ = json.Unmarshal(data, &result)
	return result
}

func unique(cards []engine.Card) bool {
	seen := map[engine.Card]bool{}
	for _, card := range cards {
		if card.Validate() != nil || seen[card] {
			return false
		}
		seen[card] = true
	}
	return true
}

func owns(hand, cards []engine.Card) bool {
	if !unique(cards) {
		return false
	}
	held := map[engine.Card]bool{}
	for _, card := range hand {
		held[card] = true
	}
	for _, card := range cards {
		if !held[card] {
			return false
		}
	}
	return true
}

func remove(hand, cards []engine.Card) []engine.Card {
	selected := map[engine.Card]bool{}
	for _, card := range cards {
		selected[card] = true
	}
	remaining := make([]engine.Card, 0, len(hand)-len(cards))
	for _, card := range hand {
		if !selected[card] {
			remaining = append(remaining, card)
		}
	}
	return remaining
}
