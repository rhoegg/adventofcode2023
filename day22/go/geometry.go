package main

import "fmt"

type Point struct {
	X, Y, Z int
}

func (p Point) String() string { return fmt.Sprintf("%d,%d,%d", p.X, p.Y, p.Z) }

func (p Point) Move(v Vector) Point {
	return Point{X: p.X + v.X, Y: p.Y + v.Y, Z: p.Z + v.Z}
}

type Vector Point
