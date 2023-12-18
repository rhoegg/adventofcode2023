package main

import (
	"os"
	"strconv"
	"strings"
)

type GearIsland struct {
	Map     [][]int
	Factory Point
}

func LavaPool() Point {
	return Point{X: 0, Y: 0}
}

func LoadGearIsland(filename string) GearIsland {
	inputdata, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}

	var mapLines [][]int
	for _, line := range strings.Split(string(inputdata), "\n") {
		row := strings.Split(line, "")
		var heats []int
		for _, heatText := range row {
			i, _ := strconv.Atoi(heatText)
			heats = append(heats, i)
		}
		mapLines = append(mapLines, heats)
	}

	return GearIsland{
		Map: mapLines,
		Factory: Point{
			X: len(mapLines[0]) - 1,
			Y: len(mapLines) - 1,
		},
	}
}

func (gi GearIsland) InBounds(p Point) bool {
	return (p.X >= 0) &&
		(p.X < len(gi.Map[0])) &&
		(p.Y >= 0) &&
		(p.Y < len(gi.Map))
}

func (gi GearIsland) MeasureHeatLoss(p Point) int {
	return gi.Map[p.Y][p.X]
}
