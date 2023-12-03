package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
	"unicode"
)

type Gear struct {
	x, y         int
	part1, part2 int
}
type Part struct {
	Number     int
	y          int
	begin, end int
}
type Engine struct {
	Lines []string
}

func NewEngine(filename string) Engine {
	inputData, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	engine := &Engine{}
	for _, line := range strings.Split(string(inputData), "\n") {
		engine.Lines = append(engine.Lines, line)
	}
	return *engine
}

func (g Gear) Ratio() int {
	return g.part1 * g.part2
}

func (e Engine) printPartNumberCandidate(line, begin, end int) {
	checkLine := e.Lines[line]
	start, finish := begin, end
	if start > 0 {
		start -= 1
	}
	if finish < (len(checkLine)) {
		finish += 1
	}
	if line > 0 {
		checkLine = e.Lines[line-1]
		fmt.Println(checkLine[start:finish])
	}
	fmt.Println(e.Lines[line][start:finish])
	if line < (len(e.Lines) - 1) {
		checkLine = e.Lines[line+1]
		fmt.Println(checkLine[start:finish])
	}
}

func (e Engine) checkPartNumber(line, begin, end int) bool {
	start, finish := begin, end
	if start > 0 {
		start -= 1
	}
	if finish < (len(e.Lines[line])) {
		finish += 1
	}
	if line > 0 { // check north
		checkLine := e.Lines[line-1]
		for i := start; i < finish; i++ {
			if checkLine[i] != '.' {
				return true
			}
		}
	}
	if line < (len(e.Lines) - 1) { // check south
		checkLine := e.Lines[line+1]
		for i := start; i < finish; i++ {
			if checkLine[i] != '.' {
				return true
			}
		}
	}
	checkLine := e.Lines[line]
	if begin > 0 { // check west
		if checkLine[start] != '.' {
			return true
		}
	}
	if end < (len(e.Lines[line]) - 1) { // check east
		if checkLine[finish-1] != '.' {
			return true
		}
	}
	return false
}

func (e Engine) Parts() (partNumbers []Part) {
	for i := range e.Lines {
		line := e.Lines[i]
		isNumber := false
		var numStart int
		for j, c := range line {
			if unicode.IsDigit(c) {
				if !isNumber {
					isNumber = true
					numStart = j
				}
			} else if isNumber { // ended a number
				isNumber = false
				// check and maybe add
				if e.checkPartNumber(i, numStart, j) {
					partNumber, err := strconv.Atoi(line[numStart:j])
					if err != nil {
						panic(err)
					}
					partNumbers = append(partNumbers, Part{
						Number: partNumber,
						y:      i,
						begin:  numStart,
						end:    j - 1,
					})
				}
			}
		}
		if isNumber { // number at the end, check and maybe add
			if e.checkPartNumber(i, numStart, len(line)) {
				partNumber, err := strconv.Atoi(line[numStart:])
				if err != nil {
					panic(err)
				}
				partNumbers = append(partNumbers, Part{
					Number: partNumber,
					y:      i,
					begin:  numStart,
					end:    len(line) - 1,
				})
			}
		}
	}
	return
}

func (e Engine) getAdjacentParts(x, y int) (parts []Part) {
	// brute force search the parts
	for _, part := range e.Parts() {
		dy := part.y - y
		if dy >= -1 && dy <= 1 {
			// vertically possible
			if x >= (part.begin-1) && x <= (part.end+1) {
				// adjacent
				parts = append(parts, part)
			}
		}
	}
	return
}

func (e Engine) Gears() (gears []Gear) {
	for i, line := range e.Lines {
		for j, c := range line {
			if c == '*' {
				gear := Gear{x: j, y: i}
				parts := e.getAdjacentParts(gear.x, gear.y)
				if len(parts) == 2 {
					gear.part1, gear.part2 = parts[0].Number, parts[1].Number
					gears = append(gears, gear)
				}
			}
		}
	}
	return
}

func main() {
	engine := NewEngine("input.txt")
	part1sum := 0
	parts := engine.Parts()
	for _, part := range parts {
		part1sum += part.Number
	}
	var partNumbers []string
	for _, part := range parts {
		partNumbers = append(partNumbers, strconv.Itoa(part.Number))
	}
	//fmt.Printf("Part numbers: %s\n", strings.Join(partNumbers, ", "))
	fmt.Printf("Part 1: %d\n", part1sum)

	part2sum := 0
	for _, gear := range engine.Gears() {
		log.Printf("gear %d,%d: %d/%d\n", gear.x, gear.y, gear.part1, gear.part2)
		part2sum += gear.Ratio()
	}
	fmt.Printf("Part 2: %d\n", part2sum)
}
