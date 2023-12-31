package main

import (
	"fmt"
	"log"
	"os"
	"strings"
)

func main() {
	garden := LoadGarden("puzzle-input.txt")
	log.Printf("after 6 steps %d", garden.PlotsReachedFromStart(garden.Start, 6))
	log.Printf("after 64 steps %d", garden.PlotsReachedFromStart(garden.Start, 64))
	// Part 2
	goal := 26501365
	log.Printf("steps ito farthest garden at goal: %d", goal%garden.Dimensions.X)
	// will be 65 steps from the center on horizontal and vertical extremes,
	// which exactly matches the steps to get out of the center garden
	// we will be 65 steps from the corner on all the diagonal edges
	log.Printf("garden lengths covered by goal: %d", goal/garden.Dimensions.X)
}

func LoadGarden(filename string) Garden {
	inputdata, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	rocks := make(map[string]struct{})
	var start *Point
	lines := strings.Split(string(inputdata), "\n")
	for y, line := range lines {
		for x, c := range line {
			switch c {
			case '.': // nothing
			case '#':
				rocks[Point{X: x, Y: y}.String()] = struct{}{}
			case 'S':
				start = &Point{X: x, Y: y}
			default:
				panic(fmt.Sprintf("unsupported garden character %v", c))
			}
		}
	}
	if start == nil {
		panic(fmt.Sprintf("could not find start position in file %s", filename))
	}
	return Garden{
		Dimensions: Vector{X: len(lines[0]), Y: len(lines)},
		Start:      *start,
		Rocks:      rocks,
	}
}
