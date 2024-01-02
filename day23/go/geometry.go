package main

import "fmt"

type Point struct {
	X int16
	Y int16
}

func (p Point) String() string {
	return fmt.Sprintf("%d,%d", p.X, p.Y)
}

func (p Point) MoveOne(direction Direction) Point {
	return p.Move(direction, 1)
}

func (p Point) Move(direction Direction, distance int16) Point {
	switch direction {
	case North:
		return Point{X: p.X, Y: p.Y - distance}
	case South:
		return Point{X: p.X, Y: p.Y + distance}
	case East:
		return Point{X: p.X + distance, Y: p.Y}
	case West:
		return Point{X: p.X - distance, Y: p.Y}
	default:
		return p
	}
}

func (p Point) DirectionOf(p2 Point) Direction {
	// assume horizontal or vertical, no diagonal support
	if p2.X > p.X {
		return East
	}
	if p2.X < p.X {
		return West
	}
	if p2.Y > p.Y {
		return South
	}
	if p2.Y < p.Y {
		return North
	}
	return Undefined
}

func (p Point) Vector(dir Direction) Vector {
	return Vector{
		Location:  p,
		Direction: dir,
	}
}

type Direction int8

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

func (d Direction) Opposite() Direction {
	switch d {
	case North:
		return South
	case South:
		return North
	case East:
		return West
	case West:
		return East
	default:
		panic("unhandled default case")
	}
}

type Vector struct {
	Location  Point
	Direction Direction
}

func (v Vector) String() string {
	return fmt.Sprintf("%s%s", v.Direction, v.Location)
}

func (v Vector) Move(distance int16) Point {
	return v.Location.Move(v.Direction, distance)
}
