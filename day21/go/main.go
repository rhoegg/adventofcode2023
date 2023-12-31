package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	garden := LoadGarden("puzzle-input.txt")
	//log.Printf("after 7 steps %d", garden.PlotsReachedFromStart(garden.Start, 7))
	//log.Printf("after 8 steps %d", garden.PlotsReachedFromStart(garden.Start, 8))

	part2(garden, 26501365)
	//part2(garden, 1180148)
	//part2(garden, 25)
	//part2(garden, 42)
	//part2(garden, 59)
	//part2(garden, 76)
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
