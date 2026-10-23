package lobby

import "testing"

func TestCanEnterHallAllowsLowerHallsOnly(t *testing.T) {
	tests := []struct {
		name   string
		points int64
		hall   string
		want   bool
	}{
		{name: "ordinary player enters ordinary hall", points: 0, hall: HallOrdinary, want: true},
		{name: "advanced player enters ordinary hall", points: 10000, hall: HallOrdinary, want: true},
		{name: "ordinary player cannot enter advanced hall", points: 9999, hall: HallAdvanced},
		{name: "advanced threshold", points: 10000, hall: HallAdvanced, want: true},
		{name: "advanced player cannot enter supreme hall", points: 39999, hall: HallSupreme},
		{name: "supreme threshold", points: 40000, hall: HallSupreme, want: true},
		{name: "unknown hall", points: 50000, hall: "unknown"},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := CanEnter(test.points, test.hall); got != test.want {
				t.Fatalf("CanEnter(%d, %q) = %t, want %t", test.points, test.hall, got, test.want)
			}
		})
	}
}

func TestHallsReturnsCopy(t *testing.T) {
	first := Halls()
	first[0].Name = "changed"
	second := Halls()
	if second[0].Name == "changed" {
		t.Fatal("Halls exposed its internal configuration")
	}
}
