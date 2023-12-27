package main

import "testing"

func TestThirdPuzzleItem(t *testing.T) {
	record := "????????#????#?.#"
	sizes := []int{1, 2, 3, 2, 1}
	count := CountCombinationsForGroups(record, sizes)
	if count != 38 {
		t.Fatalf("expected 38 but got %d", count)
	}
}
func TestThirdPuzzleItemShortened(t *testing.T) {
	record := "??#????#?.#"
	sizes := []int{3, 2, 1}
	count := CountCombinationsForGroups(record, sizes)
	if count != 6 {
		t.Fatalf("expected 6 but got %d", count)
	}
}

func TestThirdPuzzleVeryShortened(t *testing.T) {
	record := "?#?.#"
	sizes := []int{1}
	count := CountCombinationsForGroups(record, sizes)
	if count != 0 {
		t.Fatalf("expected 0 but got %d", count)
	}
}

func TestSimpleCount(t *testing.T) {
	record := "#.??"
	sizes := []int{1, 1}
	count := CountCombinationsForGroups(record, sizes)
	if count != 2 {
		t.Fatalf("expected 2 but got %d", count)
	}
}
