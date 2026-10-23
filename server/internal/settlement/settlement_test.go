package settlement

import "testing"

func TestPointsFor(t *testing.T) {
	tests := []struct {
		name            string
		levelDifference uint8
		endType         string
		multiplierBP    uint32
		want            int64
	}{
		{name: "small gap", levelDifference: 5, endType: "NORMAL", multiplierBP: 10000, want: 25},
		{name: "large gap", levelDifference: 6, endType: "NORMAL", multiplierBP: 10000, want: 60},
		{name: "single hand A to 2", levelDifference: 12, endType: "NORMAL", multiplierBP: 10000, want: 180},
		{name: "spring", levelDifference: 12, endType: SpringEndType, multiplierBP: 10000, want: 480},
		{name: "hall multiplier truncates fractional points", levelDifference: 1, endType: "NORMAL", multiplierBP: 15000, want: 7},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			got, err := PointsFor(test.levelDifference, test.endType, test.multiplierBP)
			if err != nil {
				t.Fatal(err)
			}
			if got != test.want {
				t.Fatalf("PointsFor() = %d, want %d", got, test.want)
			}
		})
	}
}

func TestPointsForRejectsInvalidResults(t *testing.T) {
	for _, test := range []struct {
		levelDifference uint8
		endType         string
		multiplierBP    uint32
	}{
		{levelDifference: 0, endType: "NORMAL", multiplierBP: 10000},
		{levelDifference: 13, endType: "NORMAL", multiplierBP: 10000},
		{levelDifference: 11, endType: SpringEndType, multiplierBP: 10000},
		{levelDifference: 1, endType: "NORMAL", multiplierBP: 0},
		{levelDifference: 1, endType: "NORMAL", multiplierBP: 1},
	} {
		if _, err := PointsFor(test.levelDifference, test.endType, test.multiplierBP); err == nil {
			t.Errorf("PointsFor(%d, %q, %d) succeeded", test.levelDifference, test.endType, test.multiplierBP)
		}
	}
}

func TestRankForPoints(t *testing.T) {
	tests := []struct {
		points int64
		want   string
	}{
		{points: 0, want: "青铜"},
		{points: 999, want: "青铜"},
		{points: 1000, want: "白银"},
		{points: 3000, want: "黄金"},
		{points: 6000, want: "铂金"},
		{points: 10000, want: "钻石"},
		{points: 16000, want: "大师"},
		{points: 24000, want: "宗师"},
		{points: 40000, want: "王者"},
	}

	for _, test := range tests {
		got, err := RankForPoints(test.points)
		if err != nil {
			t.Fatal(err)
		}
		if got != test.want {
			t.Errorf("RankForPoints(%d) = %q, want %q", test.points, got, test.want)
		}
	}
	if _, err := RankForPoints(-1); err == nil {
		t.Fatal("RankForPoints(-1) succeeded")
	}
}
