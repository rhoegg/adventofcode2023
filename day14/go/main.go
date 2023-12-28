package main

import (
	"cmp"
	"fmt"
	"log"
)

func main() {
	platform := LoadPlatform("puzzle-input.txt")
	log.Printf("Loaded %dx%d platform, %d cube rocks and %d round rocks",
		platform.Dimensions.X, platform.Dimensions.Y, len(platform.CubeRocks), len(platform.RoundRocks))
	platform.Tilt(North)
	fmt.Println(platform)
	fmt.Printf("Total load %d", platform.TotalLoad())
}

type Point struct {
	X, Y int
}

type Direction int8

const (
	Undefined Direction = iota
	North
	East
	South
	West
)

func (d Direction) PointSortFunc() func(p1, p2 *Point) int {
	return func(p1, p2 *Point) int {
		switch d {
		case North:
			return cmp.Compare(p1.Y, p2.Y)
		case South:
			return cmp.Compare(p2.Y, p1.Y)
		case East:
			return cmp.Compare(p2.X, p1.X)
		case West:
			return cmp.Compare(p1.X, p2.X)
		default:
			return 0
		}
	}
}

func (d Direction) NextPoint(p *Point) Point {
	switch d {
	case North:
		return Point{X: p.X, Y: p.Y - 1}
	case East:
		return Point{X: p.X + 1, Y: p.Y}
	case South:
		return Point{X: p.X, Y: p.Y + 1}
	case West:
		return Point{X: p.X - 1, Y: p.Y}
	default:
		return *p
	}
}
