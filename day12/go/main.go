package main

import (
	"fmt"
	"log"
	"regexp"
	"strings"
)

func main() {
	// part 2 only
	giantField := LoadGiantField("puzzle-input.txt")
	log.Printf("parsed: %v", giantField)
	log.Printf("part 2: %d", giantField.Unfold().Combinations())
}

type Row struct {
	ConditionRecord string
	GroupSizes      []int
}

func (r Row) AllOperational() bool {
	allPeriods, err := regexp.MatchString("^\\.*$", r.ConditionRecord)
	if err != nil {
		panic(err)
	}
	return allPeriods
}

func (r Row) AnyDamaged() bool {
	return strings.Contains(r.ConditionRecord, "#")
}

func (r Row) CountCombinations(cache *map[string]int) int {
	return CountCombinationsForGroups(r.ConditionRecord, r.GroupSizes, cache)
}

func CountCombinationsForGroups(record string, sizes []int, cache *map[string]int) int {
	if len(sizes) == 0 {
		return 0
	}

	//memoize
	cacheKey := record + " " + fmt.Sprintf("%v", sizes)
	if cached, ok := (*cache)[cacheKey]; ok {
		//log.Printf("cache hit for %s", cacheKey)
		return cached
	}

	combosForFirstSize := Combinations(record, sizes[0])
	count := 0
	if len(sizes) == 1 {
		for _, prefix := range combosForFirstSize {
			suffix := record[len(prefix):]
			if !strings.Contains(suffix, "#") {
				count += 1
			}
		}
		return count
	}

	for _, prefix := range combosForFirstSize {
		minCharsForSuffix := len(sizes[1:]) * 2
		suffix := record[len(prefix):]
		if len(suffix) >= minCharsForSuffix && suffix[0] != '#' {
			count += CountCombinationsForGroups(suffix[1:], sizes[1:], cache)
			//log.Printf("Counted %d for %s/%s %v", count, prefix, suffix, sizes[1:])
		}
	}

	(*cache)[cacheKey] = count
	return count
}

func Combinations(record string, size int) (result []string) {
	if len(record) < size {
		return result
	}
	if len(record)-len(strings.TrimLeft(record, "#")) > size {
		// too many damaged in a row
		return result
	}
	switch record[0] {
	case '.':
		for _, combo := range Combinations(record[1:], size) {
			result = append(result, "."+combo)
		}
	case '#':
		chunk := record[:size]
		if !strings.Contains(chunk, ".") {
			// all ? must be #
			result = append(result, strings.Repeat("#", size))
		}
	case '?':
		result = append(result, Combinations("."+record[1:], size)...)
		result = append(result, Combinations("#"+record[1:], size)...)
	default:
		panic("unsupported condition record character in " + record)
	}
	return result
}
