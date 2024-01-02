package main

import "fmt"

type Brick struct {
	End1, End2 Point
}

func (b *Brick) String() string {
	return fmt.Sprintf("%s~%s", b.End1, b.End2)
}

func (b *Brick) Supports(b2 *Brick) bool {
	if b2.End1.Z-1 != b.End2.Z {
		return false
	}
	for y := b2.End1.Y; y <= b2.End2.Y; y++ {
		for x := b2.End1.X; x <= b2.End2.X; x++ {
			if x >= b.End1.X && x <= b.End2.X && y >= b.End1.Y && y <= b.End2.Y {
				return true
			}
		}
	}
	return false
}

func (b *Brick) Equals(b2 *Brick) bool {
	return b.End1 == b2.End1 && b.End2 == b2.End2
}
