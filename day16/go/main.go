package main

import (
	"fmt"
	"log"
	"os"
	"strings"
)

func main() {
	verbose := false
	contraption := LoadContraption("puzzle-input.txt")
	p1Start := Beam{Direction: East}
	//visited := contraption.BeamPath(p1Start)
	visited := contraption.FindEnergized(p1Start)
	log.Printf("Part 1 solution: %d", len(visited))
	if verbose {
		log.Printf("part 1 map:\n%s", contraption.PrintEnergized(visited))
	}

	possibleBeams := contraption.PossibleEdgeBeams()
	log.Printf("part 2 starts: %d", len(possibleBeams))
	maxVisited := 0

	for _, b := range possibleBeams {
		clear(contraption.beamMemory)
		energized := contraption.FindEnergized(b)
		log.Printf("beam %s: %d", b, len(energized))
		if len(energized) > maxVisited {
			maxVisited = len(energized)
		}
	}
	log.Printf("Part 2 solution: %d", maxVisited)

	energized := contraption.FindEnergized(Beam{Location: Point{X: 3, Y: 0}, Direction: South})
	log.Printf("3,0 S: %d", len(energized))
	energized = contraption.FindEnergized(Beam{Location: Point{X: 3, Y: 0}, Direction: South})
	log.Printf("3,0 S: %d", len(energized))
	clear(contraption.beamMemory)
	energized = contraption.FindEnergized(Beam{Location: Point{X: 3, Y: 0}, Direction: South})
	log.Printf("3,0 S: %d", len(energized))
	//fmt.Println(contraption.PrintEnergized(energized))
}

func LoadContraption(filename string) Contraption {
	inputdata, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	lines := strings.Split(string(inputdata), "\n")
	contraption := Contraption{
		Dimensions: Point{X: len(lines[0]), Y: len(lines)},
		Components: make(map[int]map[int]func(Direction) []Direction),
		beamMemory: make(map[string][]Beam),
	}
	for y, line := range lines {
		contraption.Components[y] = make(map[int]func(Direction) []Direction)
		for x, c := range line {
			switch c {
			case '.':
				contraption.Components[y][x] = EmptySpace
			case '\\':
				contraption.Components[y][x] = LeftMirror
			case '/':
				contraption.Components[y][x] = RightMirror
			case '|':
				contraption.Components[y][x] = VerticalSplitter
			case '-':
				contraption.Components[y][x] = HorizontalSplitter
			default:
				panic(fmt.Sprintf("unsupported contraption character at %d,%d: %s", x, y, c))
			}
		}
	}
	return contraption
}
