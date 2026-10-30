package lobby

import "errors"

const (
	HallOrdinary      = "ordinary"
	HallAdvanced      = "advanced"
	HallSupreme       = "supreme"
	HallFriend        = "friend"
	HallEntertainment = "entertainment"
)

var ErrUnknownHall = errors.New("unknown hall")

type Hall struct {
	ID                    string
	Name                  string
	MinimumPoints         int64
	MaximumPoints         int64
	MultiplierBasisPoints int32
}

var halls = [...]Hall{
	{ID: HallOrdinary, Name: "普通大厅", MinimumPoints: 0, MaximumPoints: 9999, MultiplierBasisPoints: 10000},
	{ID: HallAdvanced, Name: "高手大厅", MinimumPoints: 10000, MaximumPoints: 39999, MultiplierBasisPoints: 15000},
	{ID: HallSupreme, Name: "至尊大厅", MinimumPoints: 40000, MaximumPoints: 0, MultiplierBasisPoints: 20000},
	{ID: HallFriend, Name: "好友房", MinimumPoints: 0, MaximumPoints: 0, MultiplierBasisPoints: 10000},
	{ID: HallEntertainment, Name: "娱乐厅", MinimumPoints: 0, MaximumPoints: 0, MultiplierBasisPoints: 10000},
}

func Halls() []Hall {
	return append([]Hall(nil), halls[:]...)
}

func FindHall(id string) (Hall, error) {
	for _, hall := range halls {
		if hall.ID == id {
			return hall, nil
		}
	}
	return Hall{}, ErrUnknownHall
}

// CanEnter permits players to enter their own hall or any lower hall.
func CanEnter(points int64, hallID string) bool {
	hall, err := FindHall(hallID)
	return err == nil && hallID != HallFriend && points >= hall.MinimumPoints
}
