package main

import (
	"os"
	"slices"
	"strings"
)

type Platform struct {
	Dimensions Point
	RoundRocks []*Point
	CubeRocks  []Point
	pointIndex map[int]bool
}

func LoadPlatform(filename string) *Platform {
	inputdata, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	lines := strings.Split(string(inputdata), "\n")
	p := Platform{
		pointIndex: make(map[int]bool),
	}
	p.Dimensions.X = len(lines[0])
	p.Dimensions.Y = len(lines)
	p.indexBoundaries()
	for y, line := range lines {
		for x, c := range line {
			switch c {
			case 'O':
				rock := &Point{
					X: x,
					Y: y,
				}
				p.index(*rock)
				p.RoundRocks = append(p.RoundRocks, rock)
			case '#':
				rock := Point{
					X: x,
					Y: y,
				}
				p.index(rock)
				p.CubeRocks = append(p.CubeRocks, rock)
			}
		}
	}
	return &p
}

func (p *Platform) String() string {
	var lines []string
	for y := 0; y < p.Dimensions.Y; y++ {
		line := ""
		for x := 0; x < p.Dimensions.X; x++ {
			var isRoundRock bool
			for _, roundRock := range p.RoundRocks {
				if roundRock.X == x && roundRock.Y == y {
					isRoundRock = true
					break
				}
			}
			if isRoundRock {
				line += "O"
			} else if p.isFilled(Point{X: x, Y: y}) {
				line += "#"
			} else {
				line += "."
			}
		}
		lines = append(lines, line)
	}
	return strings.Join(lines, "\n")
}

func (p *Platform) indexKey(point Point) int {
	// move point to the positive direction by one first to allow -1 X or Y
	point.X += 1
	point.Y += 1
	return point.Y*(p.Dimensions.X+2) + point.X
	// found interesting functions (cantors and szudzik's) for another time
}
func (p *Platform) index(point Point) {
	p.pointIndex[p.indexKey(point)] = true
}
func (p *Platform) indexBoundaries() {
	for y := -1; y <= p.Dimensions.Y; y++ {
		// index left and right
		p.index(Point{-1, y})
		p.index(Point{X: p.Dimensions.X, Y: y})
	}
	for x := -1; x <= p.Dimensions.X; x++ {
		// index top and bottom
		p.index(Point{X: x, Y: -1})
		p.index(Point{X: x, Y: p.Dimensions.Y})
	}
}
func (p *Platform) isFilled(point Point) bool {
	return p.pointIndex[p.indexKey(point)]
}

func (p *Platform) relocate(roundRock *Point, destination Point) {
	p.pointIndex[p.indexKey(*roundRock)] = false
	roundRock.X = destination.X
	roundRock.Y = destination.Y
	p.index(*roundRock)
}
func (p *Platform) move(roundRock *Point, dir Direction) {
	next := dir.NextPoint(roundRock)
	for !p.isFilled(next) {
		p.relocate(roundRock, next)
		next = dir.NextPoint(roundRock)
	}
}

func (p *Platform) Tilt(dir Direction) {
	slices.SortFunc(p.RoundRocks, dir.PointSortFunc())
	for _, roundRock := range p.RoundRocks {
		p.move(roundRock, dir)
	}
}

func (p *Platform) TotalLoad() int {
	load := 0
	for _, roundRock := range p.RoundRocks {
		load += p.Dimensions.Y - roundRock.Y
	}
	return load
}
