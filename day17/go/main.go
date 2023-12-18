package main

import (
	"log"
	"strings"
)

func main() {
	island := LoadGearIsland("puzzle-input.txt")
	lastState := FindPathToFactory(island)
	log.Printf("Stopped at %v with heat loss %d", lastState.Position, lastState.HeatLoss)
	log.Printf("Trail: %v", strings.Join(lastState.PrettyTrail(), "\n"))
}

type Point struct {
	X int
	Y int
}

type Direction int

const (
	Undefined Direction = iota
	North
	South
	East
	West
)

func (d Direction) String() string {
	switch d {
	case North:
		return "north"
	case South:
		return "south"
	case East:
		return "east"
	case West:
		return "west"
	default:
		return "undefined"
	}
}

func (p Point) Move(direction Direction) Point {
	switch direction {
	case North:
		return Point{X: p.X, Y: p.Y - 1}
	case South:
		return Point{X: p.X, Y: p.Y + 1}
	case East:
		return Point{X: p.X + 1, Y: p.Y}
	case West:
		return Point{X: p.X - 1, Y: p.Y}
	default:
		return p
	}
}

func (p Point) DistanceFrom(other Point) int {
	horizontal := p.X - other.X
	if horizontal < 0 {
		horizontal = -1 * horizontal
	}
	vertical := p.Y - other.Y
	if vertical < 0 {
		vertical = -1 * vertical
	}
	return horizontal + vertical
}

func (d Direction) IsBackwards(other Direction) bool {
	switch d {
	case North:
		return other == South
	case South:
		return other == North
	case East:
		return other == West
	case West:
		return other == East
	default:
		return false
	}
}
