package main

import "fmt"

type Point struct {
	X, Y int
}

func (p Point) String() string { return fmt.Sprintf("%d,%d", p.X, p.Y) }

func (p Point) Move(v Vector) Point {
	return Point{X: p.X + v.X, Y: p.Y + v.Y}
}
func (p Point) ManhattanDistance(p2 Point) int {
	vertical := p2.Y - p.Y
	if vertical < 0 {
		vertical = -vertical
	}
	horizontal := p2.X - p.X
	if horizontal < 0 {
		horizontal = -horizontal
	}
	return vertical + horizontal
}

type Vector Point

type Direction int8

const (
	None Direction = iota
	North
	East
	South
	West
)

func (d Direction) UnitVector() Vector {
	switch d {
	case North:
		return Vector{X: 0, Y: -1}
	case South:
		return Vector{X: 0, Y: 1}
	case West:
		return Vector{X: -1, Y: 0}
	case East:
		return Vector{X: 1, Y: 0}
	default:
		return Vector{}
	}
}

func (d Direction) From(p Point) Point {
	return p.Move(d.UnitVector())
}

func (d Direction) String() string {
	switch d {
	case North:
		return "N"
	case South:
		return "S"
	case East:
		return "E"
	case West:
		return "W"
	default:
		return " "
	}
}
