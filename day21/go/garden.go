package main

import (
	"slices"
	"strings"
)

type Garden struct {
	Rocks      map[string]struct{}
	Start      Point
	Dimensions Vector
}

func (g Garden) IsRock(p Point) bool {
	_, ok := g.Rocks[p.String()]
	return ok
}

func (g Garden) InBounds(p Point) bool {
	return p.X >= 0 &&
		p.X < g.Dimensions.X &&
		p.Y >= 0 &&
		p.Y < g.Dimensions.Y
}

func (g Garden) PlotsReachedFromStart(start Point, distance int) int64 {
	return int64(len(g.PlotsReached([]Point{start}, distance)))
}

func (g Garden) PlotsReached(starts []Point, distance int) []Point {
	if distance == 0 {
		return starts
	}

	reached := make(map[string]struct{})
	var nextSteps []Point
	for _, start := range starts {
		for _, dir := range []Direction{North, South, East, West} {
			next := dir.From(start)
			if g.InBounds(next) && !g.IsRock(next) {
				if _, ok := reached[next.String()]; !ok {
					reached[next.String()] = struct{}{}
					nextSteps = append(nextSteps, next)
				}
			}
		}
	}
	return g.PlotsReached(nextSteps, distance-1)
}

func (g Garden) PrintWithPoints(points []Point) string {
	var lines []string
	for y := 0; y < g.Dimensions.Y; y++ {
		line := ""
		for x := 0; x < g.Dimensions.X; x++ {
			p := Point{X: x, Y: y}
			if slices.Contains(points, p) {
				line += "O"
			} else if _, ok := g.Rocks[p.String()]; ok {
				line += "#"
			} else {
				line += "."
			}
		}
		lines = append(lines, line)
	}
	return strings.Join(lines, "\n")
}
