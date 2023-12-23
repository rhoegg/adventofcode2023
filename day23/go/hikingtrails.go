package main

import (
	"log"
	"os"
	"strings"
)

type Point struct {
	X int16
	Y int16
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

type PathSegment struct {
	Id     int
	Points []Point
	Exits  []*PathSegment
}

func (s PathSegment) Contains(p Point) bool {
	for _, visited := range s.Points {
		if visited == p {
			return true
		}
	}
	return false
}

func InBounds(trailMap []string, p Point) bool {
	return (p.X >= 0 && p.X < int16(len(trailMap[0]))) &&
		(p.Y >= 0 && p.Y < int16(len(trailMap)))
}

func CanMove(trailMap []string, origin Point, dir Direction, slippery bool) bool {
	c := trailMap[origin.Y][origin.X]
	if slippery {
		if c == '>' && dir != East {
			return false
		}
		if c == 'v' && dir != South {
			return false
		}
		if c == '<' && dir != West {
			return false
		}
		if c == '^' && dir != North {
			return false
		}
	}
	p := origin.MoveOne(dir)
	if !InBounds(trailMap, p) {
		return false
	}
	c = trailMap[p.Y][p.X]
	if c == '#' {
		return false
	}
	if c == '.' {
		return true
	}
	if slippery {
		if c == '>' && dir == West {
			return false
		}
		if c == 'v' && dir == North {
			return false
		}
		if c == '<' && dir == East {
			return false
		}
		if c == '^' && dir == South {
			return false
		}
	}
	return true
}

func ParseHikingTrails(filename string, slippery bool) *PathSegment {
	inputdata, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	rows := strings.Split(string(inputdata), "\n")
	p := Point{X: 1, Y: 0}
	var mappedSegments []*PathSegment
	return FindSegment(rows, p, slippery, &mappedSegments)
}

func PossibleMoves(trailMap []string, p Point, slippery bool) []Point {
	var options []Point
	for _, dir := range []Direction{North, East, South, West} {
		nextPos := p.MoveOne(dir)
		if CanMove(trailMap, p, dir, slippery) {
			options = append(options, nextPos)
		}
	}
	return options
}

func MergingSegments(trailMap []string, p Point, segment PathSegment) bool {
	for _, checkDir := range []Direction{North, East, South, West} {
		checkPos := p.MoveOne(checkDir)
		if !segment.Contains(checkPos) && InBounds(trailMap, checkPos) {
			c := trailMap[checkPos.Y][checkPos.X]
			if c == 'v' && checkDir == North {
				return true
			}
			if c == '<' && checkDir == East {
				return true
			}
			if c == '^' && checkDir == South {
				return true
			}
			if c == '>' && checkDir == West {
				return true
			}
		}
	}
	return false
}

func FindSegment(trailMap []string, start Point, slippery bool, mapped *[]*PathSegment) *PathSegment {

	id := 0
	for _, s := range *mapped {
		if s.Id >= id {
			id = s.Id + 1
		}
	}
	currentSegment := &PathSegment{
		Id:     id,
		Points: []Point{start},
	}

	p := start
	for {
		options := PossibleMoves(trailMap, p, slippery)
		var viableOptions []Point
		for _, o := range options {
			var beenThere bool
			for _, seg := range *mapped {
				if seg.Contains(o) {
					beenThere = true
				}
			}
			if !beenThere && !currentSegment.Contains(o) {
				viableOptions = append(viableOptions, o)
			}
		}

		if len(viableOptions) == 1 &&
			!MergingSegments(trailMap, p, *currentSegment) {
			p = viableOptions[0]
			currentSegment.Points = append(currentSegment.Points, p)
		} else {
			*mapped = append(*mapped, currentSegment)

			log.Printf("Finished segment %d with %d points (%d,%d) (%d,%d)",
				currentSegment.Id, len(currentSegment.Points),
				currentSegment.Points[0].X, currentSegment.Points[0].Y,
				p.X, p.Y)
			if len(viableOptions) == 0 {
				log.Printf("Perhaps we're done %d,%d", p.X, p.Y)
			}
			for _, exitPoint := range viableOptions {
				var knownSegment *PathSegment
				for _, seg := range *mapped {
					if seg.Contains(exitPoint) {
						knownSegment = seg
					}
				}

				if knownSegment == nil {
					currentSegment.Exits = append(currentSegment.Exits,
						FindSegment(trailMap, exitPoint, slippery, mapped))
				} else {
					currentSegment.Exits = append(currentSegment.Exits,
						knownSegment)
				}
			}
			break
		}
	}

	return currentSegment
}
