package main

import (
	"fmt"
	"os"
	"slices"
	"strings"
)

type PathSegment struct {
	Id     int
	Points []Point
	Edges  []*PathSegment
}

func (s *PathSegment) String() string {
	p1, p2 := s.Points[0], s.Points[len(s.Points)-1]
	if p2.X == p1.X && p2.Y < p1.Y {
		p1, p2 = p2, p1
	} else if p2.X < p1.X {
		p1, p2 = p2, p1
	}
	return fmt.Sprintf("%d,%d %d,%d", p1.X, p1.Y, p2.X, p2.Y)
}

func (s *PathSegment) Contains(p Point) bool {
	for _, visited := range s.Points {
		if visited == p {
			return true
		}
	}
	return false
}

func (s *PathSegment) Connects(s2 *PathSegment) bool {
	return s.Points[0] == s2.Points[0] ||
		s.Points[0] == s2.Points[len(s2.Points)-1] ||
		s.Points[len(s.Points)-1] == s2.Points[0] ||
		s.Points[len(s.Points)-1] == s2.Points[len(s2.Points)-1]
}

func (s *PathSegment) Junction(s2 *PathSegment) Point {
	if s.Points[0] == s2.Points[0] ||
		s.Points[0] == s2.Points[len(s2.Points)-1] {
		return s.Points[0]
	}
	if s.Points[len(s.Points)-1] == s2.Points[0] ||
		s.Points[len(s.Points)-1] == s2.Points[len(s2.Points)-1] {
		return s.Points[len(s.Points)-1]
	}
	panic("no junction between segments")
}

func (s *PathSegment) Find(id int) *PathSegment {
	return s.find(id, nil)
}

func (s *PathSegment) Equivalent(s2 *PathSegment) bool {
	return len(s.Points) == len(s2.Points) &&
		(s.Points[0] == s2.Points[0] || s.Points[0] == s2.Points[len(s2.Points)-1]) &&
		(s.Points[len(s.Points)-1] == s2.Points[len(s2.Points)-1] || s.Points[len(s.Points)-1] == s2.Points[0])
}

func (s *PathSegment) find(id int, visited []int) *PathSegment {
	if s.Id == id {
		return s
	}
	for _, exit := range s.Edges {
		if !slices.Contains(visited, exit.Id) {
			found := exit.find(id, append(slices.Clone(visited), s.Id))
			if found != nil {
				return found
			}
		}
	}
	return nil
}

func (s *PathSegment) LeadsTo(destination int) bool {
	return s.leadsTo(destination, nil)
}

func (s *PathSegment) leadsTo(destination int, visited []int) bool {
	if s.Id == destination {
		return true
	}
	for _, next := range s.Edges {
		if !slices.Contains(visited, next.Id) &&
			next.leadsTo(destination, append(slices.Clone(visited), next.Id)) {
			return true
		}
	}
	return false
}

func ParseHikingTrails(filename string, slippery bool) *PathSegment {
	inputdata, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	rows := strings.Split(string(inputdata), "\n")
	p := Point{X: 1, Y: 0}
	//var mappedSegments []*PathSegment
	//return FindSegment(rows, p, South, slippery, &mappedSegments)
	return ExploreHikingTrails(rows, p, South, false)
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

// Rebuilding trail parser for part 2
func ExploreHikingTrails(trailMap []string, start Point, dir Direction, slippery bool) *PathSegment {
	id := 0
	remainingToExplore := []Vector{{Location: start, Direction: dir}}
	var found []*PathSegment
	// vectors don't go in unless they need to be explored
	exploredAlready := make(map[string]struct{}) // e.g. "S1,0"
	for len(remainingToExplore) > 0 {
		next := remainingToExplore[0]
		remainingToExplore = remainingToExplore[1:]
		segment := PathSegment{
			Id:     id,
			Points: []Point{next.Location},
		}
		id += 1

		// advance until intersection
		for {
			// advance
			p := next.Move(1)
			segment.Points = append(segment.Points, p)
			// check all directions
			var options []Vector
			for _, nextDir := range []Direction{North, East, South, West} {
				if nextDir != next.Direction.Opposite() &&
					CanMove(trailMap, p, nextDir, slippery) {
					options = append(options, Vector{
						Location:  p,
						Direction: nextDir,
					})
				}
			}
			if len(options) != 1 {
				// finish the segment
				found = append(found, &segment)
				for _, option := range options {
					if _, ok := exploredAlready[option.String()]; !ok {
						exploredAlready[option.String()] = struct{}{}
						remainingToExplore = append(remainingToExplore, option)
					}
				}
				break
			} else {
				next = options[0]
			}
		}
	}
	// prune duplicates?
	var doomed []*PathSegment
	for _, seg := range found {
		if !slices.Contains(doomed, seg) {
			for _, seg2 := range found {
				if seg.Id != seg2.Id && seg.Equivalent(seg2) {
					doomed = append(doomed, seg2)
				}
			}
		}
	}
	var segments []*PathSegment
	for _, s := range found {
		if !slices.Contains(doomed, s) {
			segments = append(segments, s)
		}
	}
	// wire up edges
	for _, s := range segments {
		for _, other := range segments {
			if other.Id != s.Id && s.Connects(other) {
				s.Edges = append(s.Edges, other)
			}
		}
	}
	return segments[0]
}
