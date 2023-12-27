package main

import (
	"log"
	"os"
	"strconv"
	"strings"
)

type GiantField struct {
	rows  []Row
	cache map[string]int
}

func LoadGiantField(filename string) (result GiantField) {
	inputdata, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	result.cache = make(map[string]int)

	for _, line := range strings.Split(string(inputdata), "\n") {
		parts := strings.Split(line, " ")
		var groups []int
		for _, item := range strings.Split(parts[1], ",") {
			num, err := strconv.Atoi(item)
			if err != nil {
				panic(err)
			}
			groups = append(groups, num)
		}
		result.rows = append(result.rows, Row{
			ConditionRecord: parts[0],
			GroupSizes:      groups,
		})
	}
	return result
}

func (f GiantField) Unfold() *GiantField {
	var result GiantField
	result.cache = make(map[string]int)

	for _, row := range f.rows {
		var conditionRecords []string
		var groupSizes []int
		for i := 0; i < 5; i++ {
			conditionRecords = append(conditionRecords, row.ConditionRecord)
			groupSizes = append(groupSizes, row.GroupSizes...)
		}
		result.rows = append(result.rows, Row{
			ConditionRecord: strings.Join(conditionRecords, "?"),
			GroupSizes:      groupSizes,
		})
	}
	return &result
}

func (f *GiantField) Combinations() int {
	sum := 0
	for _, row := range f.rows {
		combos := row.CountCombinations(&f.cache)
		log.Printf("(%d) row %s [%v]", combos, row.ConditionRecord, row.GroupSizes)
		sum += combos
	}
	return sum
}
