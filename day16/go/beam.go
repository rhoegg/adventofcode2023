package main

import "fmt"

type Beam struct {
	Location  Point
	Direction Direction
}

func (b Beam) Forward() Beam {
	return Beam{
		Location:  b.Location.Move(b.Direction.Vector()),
		Direction: b.Direction,
	}
}

func (b Beam) String() string {
	return fmt.Sprintf("%d,%d %s", b.Location.X, b.Location.Y, b.Direction)
}
