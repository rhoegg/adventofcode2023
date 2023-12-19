package main

import (
	"os"
	"strconv"
	"strings"
)

type GearIsland struct {
	Map     [][]int16
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

	var mapLines [][]int16
	for _, line := range strings.Split(string(inputdata), "\n") {
		row := strings.Split(line, "")
		var heats []int16
		for _, heatText := range row {
			i, _ := strconv.Atoi(heatText)
			heats = append(heats, int16(i))
		}
		mapLines = append(mapLines, heats)
	}

	return GearIsland{
		Map: mapLines,
		Factory: Point{
			X: int16(len(mapLines[0])) - 1,
			Y: int16(len(mapLines)) - 1,
		},
	}
}

func (gi GearIsland) InBounds(p Point) bool {
	return (p.X >= 0) &&
		(p.X < int16(len(gi.Map[0]))) &&
		(p.Y >= 0) &&
		(p.Y < int16(len(gi.Map)))
}

func (gi GearIsland) MeasureHeatLoss(p Point) int16 {
	return gi.Map[p.Y][p.X]
}
