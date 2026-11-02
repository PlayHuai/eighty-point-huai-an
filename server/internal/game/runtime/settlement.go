package runtime

import (
	"github.com/Derek0120/eighty-point-huai-an/server/internal/lobby"
	"github.com/Derek0120/eighty-point-huai-an/server/internal/settlement"
)

func MatchResult(state State) (settlement.MatchResult, error) {
	if state.Practice || state.Phase != Finished || state.Result == nil {
		return settlement.MatchResult{}, settlement.ErrInvalidResult
	}
	hall, err := lobby.FindHall(state.HallID)
	if err != nil {
		return settlement.MatchResult{}, err
	}
	difference := int(state.Levels[0]) - int(state.Levels[1])
	if difference < 0 {
		difference = -difference
	}
	// Equal-level finishes still have a winner; the agreed minimum is one level.
	if difference == 0 {
		difference = 1
	}
	endType := "NORMAL"
	if state.Result.Spring {
		difference, endType = 12, settlement.SpringEndType
	}
	points, err := settlement.PointsFor(uint8(difference), endType, uint32(hall.MultiplierBasisPoints))
	if err != nil {
		return settlement.MatchResult{}, err
	}
	winner := "DEALER"
	if state.Result.WinnerTeam != state.Dealer%2 {
		winner = "DEFENDER"
	}
	result := settlement.MatchResult{
		GameSessionID: state.MatchID, Winner: winner, LevelDifference: uint8(difference),
		EndType: endType, HallMultiplierBP: uint32(hall.MultiplierBasisPoints), ConfigVersion: 1,
	}
	for seat, playerID := range state.Players {
		delta := -points
		if seat%2 == state.Result.WinnerTeam {
			delta = points
		}
		result.Changes = append(result.Changes, settlement.PointChange{UserID: playerID, Delta: delta})
	}
	return result, nil
}
