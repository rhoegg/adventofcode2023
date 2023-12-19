package main

import "testing"

func BenchmarkFindPath(b *testing.B) {
	island := LoadGearIsland("puzzle-input.txt")
	lastState := FindPathToFactory(island)
	if lastState.HeatLoss != 102 {
		b.Errorf("Heat loss for sample1.txt should be 102")
	}
}
