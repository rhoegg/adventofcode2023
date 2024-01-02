package main

import (
	"cmp"
	"log"
	"slices"
)

type BrickColumn struct {
	Bricks []*Brick
}

func (bc BrickColumn) Len() int {
	return len(bc.Bricks)
}

func (bc BrickColumn) ApplyGravity() {
	slices.SortFunc(bc.Bricks, func(b1, b2 *Brick) int {
		return cmp.Compare(b1.End1.Z, b2.End2.Z)
	})
	// loop and drop if clear below
	var lowerBricks []*Brick
	count := 0
	for _, b := range bc.Bricks {
		for {
			dropped := false
			if b.End1.Z > 0 {
				blocked := false
				for _, candidateBrick := range lowerBricks {
					if candidateBrick.Supports(b) {
						blocked = true
						break
					}
				}
				if !blocked {
					dropped = true
					b.End1.Z, b.End2.Z = b.End1.Z-1, b.End2.Z-1
				}
				if dropped {
					count += 1
				} else {
					break
				}
			} else {
				break
			}
		}
		lowerBricks = append(lowerBricks, b)
		// prune obstructed lower bricks
	}
	log.Printf("gravity moved %d", count)
}

func (bc BrickColumn) FindSupports(b *Brick) (result []*Brick) {
	for _, candidateBrick := range bc.Bricks {
		if candidateBrick.Supports(b) {
			result = append(result, candidateBrick)
		}
	}
	return result
}

func (bc BrickColumn) CanDisintegrate(b *Brick) bool {
	// we can disintegrate a brick if it is not the only support for any other brick
	for _, supported := range bc.Bricks {
		supports := bc.FindSupports(supported)
		if len(supports) == 1 && supports[0] == b {
			return false
		}
	}
	return true
}
