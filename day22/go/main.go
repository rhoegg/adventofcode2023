package main

import (
	"log"
	"os"
	"strconv"
	"strings"
)

func main() {
	bc := ParseBricks("puzzle-input.txt")
	bc.ApplyGravity()
	Part1(bc)
	Part2(bc)
}

func ParseBricks(filename string) BrickColumn {
	inputdata, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	var bricks []*Brick
	for _, line := range strings.Split(string(inputdata), "\n") {
		ends := strings.Split(line, "~")
		b := Brick{
			End1: ParsePoint(ends[0]),
			End2: ParsePoint(ends[1]),
		}
		if b.End2.Z < b.End1.Z {
			b.End1.Z, b.End2.Z = b.End2.Z, b.End1.Z
		}
		bricks = append(bricks, &b)
	}
	return BrickColumn{Bricks: bricks}
}

func ParsePoint(text string) Point {
	coords := strings.Split(text, ",")
	x, err := strconv.Atoi(coords[0])
	if err != nil {
		panic(err)
	}
	y, err := strconv.Atoi(coords[1])
	if err != nil {
		panic(err)
	}
	z, err := strconv.Atoi(coords[2])
	if err != nil {
		panic(err)
	}
	return Point{X: x, Y: y, Z: z}
}

func ShowVerticalBricks(bc BrickColumn) {
	for _, b := range bc.Bricks {
		if b.End1.Z != b.End2.Z {
			log.Printf("vertical brick %s", b)
		}
	}
}

func Part1(bc BrickColumn) {
	var canDisintegrate []*Brick
	for _, b := range bc.Bricks {
		if bc.CanDisintegrate(b) {
			canDisintegrate = append(canDisintegrate, b)
		}
	}
	log.Printf("Part 1: %d", len(canDisintegrate))
}

func Part2(bc BrickColumn) {
	totalDropped := 0
	for _, b := range bc.Bricks {
		whatIf := bc.CloneWithout(b)
		dropped := whatIf.ApplyGravity()
		log.Printf("Disintegrated %s, dropped %d", b, dropped)
		totalDropped += dropped
	}
	log.Printf("Part 2: %d", totalDropped)
}
