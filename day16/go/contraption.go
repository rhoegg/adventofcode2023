package main

import (
	"slices"
	"strings"
)

type Contraption struct {
	Components map[int]map[int]func(Direction) []Direction
	Dimensions Point
	beamMemory map[string][]Beam
}

func (c Contraption) PossibleEdgeBeams() (result []Beam) {
	for y := 0; y < c.Dimensions.Y; y++ {
		// east and west edges
		result = append(result, Beam{
			Location:  Point{X: 0, Y: y},
			Direction: East,
		})
		result = append(result, Beam{
			Location:  Point{X: c.Dimensions.X - 1, Y: y},
			Direction: West,
		})
	}
	for x := 0; x < c.Dimensions.X; x++ {
		// north and south edges
		result = append(result, Beam{
			Location:  Point{X: x, Y: 0},
			Direction: South,
		})
		result = append(result, Beam{
			Location:  Point{X: x, Y: c.Dimensions.Y - 1},
			Direction: North,
		})
	}
	return result
}

func (c Contraption) InBounds(p Point) bool {
	return p.X >= 0 && p.X < c.Dimensions.X && p.Y >= 0 && p.Y < c.Dimensions.Y
}
func (c Contraption) FindEnergized(b Beam) []Point {
	path := c.traceBeam(b, nil)
	var energized []Point
	for _, pathBeam := range path {
		if !slices.Contains(energized, pathBeam.Location) {
			energized = append(energized, pathBeam.Location)
		}
	}
	return energized
}

func (c Contraption) traceBeam(b Beam, traveled []Beam) []Beam {
	if slices.Contains(traveled, b) {
		return nil
	}
	if path, ok := c.beamMemory[b.String()]; ok {
		//log.Printf("cache hit %s", b)
		return path
	}
	//log.Printf("tracing %s", b)
	beam := b
	var path []Beam
	for c.InBounds(beam.Location) {
		component := c.Components[beam.Location.Y][beam.Location.X]
		directions := component(beam.Direction)
		if len(directions) == 0 {
			break
		}
		if len(directions) > 1 {
			//log.Printf("splitting beam at %d,%d", beam.Location.X, beam.Location.Y)
			nextBeam := Beam{
				Location:  beam.Location,
				Direction: directions[1],
			}.Forward()
			traced := c.traceBeam(nextBeam, traveled)
			for _, p := range traced {
				if !slices.Contains(path, p) {
					path = append(path, p)
				}
			}
		}
		traveled = append(traveled, beam)
		beam = Beam{
			Location:  beam.Location,
			Direction: directions[0],
		}.Forward()
		if slices.Contains(traveled, beam) {
			break
		}
	}
	c.beamMemory[b.String()] = path
	for _, pastBeam := range traveled {
		if !slices.Contains(path, pastBeam) {
			path = append(path, pastBeam)
		}
	}
	return path
}

func (c Contraption) BeamPath(b Beam) []Point {
	pendingBeams := []Beam{b}
	var visited []Beam
	for len(pendingBeams) > 0 {
		beam := pendingBeams[0]
		pendingBeams = pendingBeams[1:]
		if c.InBounds(beam.Location) {
			visited = append(visited, beam)

			component := c.Components[beam.Location.Y][beam.Location.X]
			directions := component(beam.Direction)
			for _, d := range directions {
				nextBeam := Beam{
					Location:  beam.Location,
					Direction: d,
				}.Forward()
				if !slices.Contains(visited, nextBeam) {
					pendingBeams = append(pendingBeams, nextBeam)
				}
			}
		}
	}
	var visitedPoints []Point
	for _, beam := range visited {
		if !slices.ContainsFunc(visitedPoints, func(p Point) bool {
			return p == beam.Location
		}) {
			visitedPoints = append(visitedPoints, beam.Location)
		}
	}
	return visitedPoints
}

func EmptySpace(d Direction) []Direction {
	return []Direction{d}
}

func LeftMirror(d Direction) []Direction {
	switch d {
	case North:
		return []Direction{West}
	case South:
		return []Direction{East}
	case East:
		return []Direction{South}
	case West:
		return []Direction{North}
	default:
		return nil
	}
}

func RightMirror(d Direction) []Direction {
	switch d {
	case North:
		return []Direction{East}
	case South:
		return []Direction{West}
	case East:
		return []Direction{North}
	case West:
		return []Direction{South}
	default:
		return nil
	}
}

func VerticalSplitter(d Direction) []Direction {
	switch d {
	case North:
		return []Direction{d}
	case South:
		return []Direction{d}
	case East:
		return []Direction{North, South}
	case West:
		return []Direction{North, South}
	default:
		return nil
	}
}

func HorizontalSplitter(d Direction) []Direction {
	switch d {
	case North:
		return []Direction{East, West}
	case South:
		return []Direction{East, West}
	case East:
		return []Direction{d}
	case West:
		return []Direction{d}
	default:
		return nil
	}
}

func (c Contraption) PrintEnergized(energized []Point) string {
	var lines []string
	for y := 0; y < c.Dimensions.Y; y++ {
		line := ""
		for x := 0; x < c.Dimensions.X; x++ {
			c := "."
			for _, p := range energized {
				if p.X == x && p.Y == y {
					c = "#"
				}
			}
			line += c
		}
		lines = append(lines, line)
	}
	return strings.Join(lines, "\n")
}
