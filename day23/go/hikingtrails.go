package main

import (
	"log"
	"os"
	"strings"
)

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

func (s PathSegment) Equivalent(s2 PathSegment) bool {
	if s2.Id == s.Id {
		return false
	}
	matched := 0
	unmatched := 0
	for _, p := range s.Points {
		if s2.Contains(p) {
			matched += 1
		} else {
			unmatched += 1
		}
		if matched > 1 {
			return true
		}
		if unmatched > 2 {
			return false
		}
	}
	panic("segment equivalence has a bug")
	return false
}

func LeadsTo(destination int) bool {
	
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
	return FindSegment(rows, p, South, slippery, &mappedSegments)
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

func FindSegment(trailMap []string, start Point, dir Direction, slippery bool, mapped *[]*PathSegment) *PathSegment {
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

	for _, seg := range *mapped {
		if seg.Points[0] == start {
			// already mapped!
			currentSegment = seg
			log.Printf("found already mapped seg %d", seg.Id)
		}
	}
	p := start
	for {
		options := PossibleMoves(trailMap, p, slippery)
		var viableOptions []Point
		for _, o := range options {
			var beenThere bool
			for _, seg := range *mapped {
				if seg.Points[0] == o && !seg.Contains(p) {
					beenThere = true
					currentSegment.Exits = append(currentSegment.Exits, seg)
				}
			}
			if !beenThere && !currentSegment.Contains(o) &&
				(p != start || dir != o.DirectionOf(p)) {
				viableOptions = append(viableOptions, o)
			}
		}

		if p == start ||
			len(options) == 2 &&
				len(viableOptions) == 1 &&
				(!slippery || !MergingSegments(trailMap, p, *currentSegment)) {
			p = viableOptions[0]
			currentSegment.Points = append(currentSegment.Points, p)
		} else {
			*mapped = append(*mapped, currentSegment)

			log.Printf("Finished segment %d with %d points (%d,%d) (%d,%d)",
				currentSegment.Id, len(currentSegment.Points),
				currentSegment.Points[0].X, currentSegment.Points[0].Y,
				p.X, p.Y)
			for _, exitPoint := range viableOptions {
				var knownSegment *PathSegment
				for _, seg := range *mapped {
					//if seg.Contains(exitPoint) {
					if seg.Points[0] == exitPoint {
						knownSegment = seg
					}
					//}
				}

				if knownSegment == nil {
					currentSegment.Exits = append(currentSegment.Exits,
						FindSegment(trailMap, exitPoint, p.DirectionOf(exitPoint), slippery, mapped))
				} else {
					currentSegment.Exits = append(currentSegment.Exits,
						knownSegment)
				}
			}
			if len(currentSegment.Exits) == 0 {
				log.Printf("Perhaps we're done %d,%d", p.X, p.Y)
			}
			break
		}
	}

	return currentSegment
}

func RemoveRabbitTrails(trailhead *PathSegment, destination int) {

}
