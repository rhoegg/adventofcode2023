package main

import (
	"cmp"
	"log"
)

func main() {
	filename := "puzzle-input.txt"
	platform := LoadPlatform(filename)
	log.Printf("Loaded %dx%d platform, %d cube rocks and %d round rocks",
		platform.Dimensions.X, platform.Dimensions.Y, len(platform.CubeRocks), len(platform.RoundRocks))
	platform.Tilt(North)
	log.Println(platform)
	log.Printf("Part 1 Total load %d\n", platform.TotalLoad())

	platform = LoadPlatform(filename)
	cycles := 1000000000
	states := make(map[string]int)
	loads := make(map[int]int)
	for {
		if _, ok := states[platform.RockPositions()]; ok {
			break
		}
		states[platform.RockPositions()] = platform.CycleCount
		platform.Cycle()
		if platform.CycleCount%1000000 == 0 {
			log.Printf("completed %d cycles", platform.CycleCount)
		}
		if platform.CycleCount%1000 == 0 {
			log.Printf("cycle %d total load %d", platform.CycleCount, platform.TotalLoad())
		}
		loads[platform.CycleCount] = platform.TotalLoad()
	}
	cycleStart := states[platform.RockPositions()]
	repeatLength := (platform.CycleCount - cycleStart)
	log.Printf("repeated state %d after %d cycles, total load is %d", cycleStart, platform.CycleCount, platform.TotalLoad())

	lastCycle := (cycles-cycleStart)%repeatLength + cycleStart
	log.Printf("after %d cycles we should be repeating cycle %d with total load %d", cycles, lastCycle, loads[lastCycle])
	//log.Printf("%d cycles total load %d\n", cycles, platform.TotalLoad())
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
