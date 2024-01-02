package main

import (
	"cmp"
	"log"
	"slices"
)

type BrickColumn struct {
	Bricks []*Brick
}

func (bc BrickColumn) CloneWithout(b *Brick) BrickColumn {
	var newBricks []*Brick
	for _, oldBrick := range bc.Bricks {
		if oldBrick != b {
			newBricks = append(newBricks, &Brick{
				End1: Point{X: oldBrick.End1.X, Y: oldBrick.End1.Y, Z: oldBrick.End1.Z},
				End2: Point{X: oldBrick.End2.X, Y: oldBrick.End2.Y, Z: oldBrick.End2.Z},
			})
		}
	}
	return BrickColumn{Bricks: newBricks}
}

func (bc BrickColumn) Len() int {
	return len(bc.Bricks)
}

func (bc BrickColumn) ApplyGravity() int {
	slices.SortFunc(bc.Bricks, func(b1, b2 *Brick) int {
		return cmp.Compare(b1.End1.Z, b2.End2.Z)
	})
	// loop and drop if clear below
	var lowerBricks []*Brick
	droppedDistance := 0
	droppedBricks := 0
	for _, b := range bc.Bricks {
		brickDropped := false
		for {
			dropped := false
			if b.End1.Z > 1 {
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
					brickDropped = true
					droppedDistance += 1
				} else {
					break
				}
			} else {
				break
			}
		}
		if brickDropped {
			droppedBricks += 1
		}
		lowerBricks = append(lowerBricks, b)
		// prune obstructed lower bricks
	}
	log.Printf("gravity moved %d bricks for %d", droppedBricks, droppedDistance)
	return droppedBricks
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
