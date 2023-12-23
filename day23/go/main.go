package main

import (
	"log"
	"strconv"
	"strings"
)

func main() {
	var ids []string

	//trail := ParseHikingTrails("puzzle-input.txt", true)
	//distance, route := LongestPath(trail)
	//for _, id := range route {
	//	ids = append(ids, strconv.Itoa(id))
	//}
	//log.Printf("Part 1 %d: %s", distance, strings.Join(ids, ","))

	trail2 := ParseHikingTrails("sample1.txt", false)
	distance2, route2 := LongestPath(trail2)
	ids = nil
	for _, id := range route2 {
		ids = append(ids, strconv.Itoa(id))
	}
	log.Printf("Part 2 %d: %s", distance2, strings.Join(ids, ","))
	// I don't get the right answer for the sample yet, and mine is too low.
	// I think my FindSegment function is failing to connect all the possible edges to the node graph
	// wait... another possibility is that the part 2 requirement made this graph "cyclic"?
}

func LongestPath(trail *PathSegment) (int, []int) {
	distances := make(map[int]int)
	routes := make(map[int][]int)
	// initialize trailhead to the actual length instead of 0 because there is only one start
	// and the segment length is sunk cost
	distances[trail.Id] = len(trail.Points) - 1 // not counting starting position
	var finishes []*PathSegment
	for _, seg := range TopologicalSort(trail) {
		if len(seg.Exits) == 0 {
			p := seg.Points[len(seg.Points)-1]
			log.Printf("no exits %d (%d,%d)", seg.Id, p.X, p.Y)
			finishes = append(finishes, seg)
		}
		for _, successor := range seg.Exits {
			// distances[successor] = max(existing value, path through seg)
			candidate := distances[seg.Id] + len(successor.Points)
			if candidate > distances[successor.Id] {
				distances[successor.Id] = candidate
				routes[successor.Id] = append(routes[seg.Id], seg.Id)
			}
		}
	}
	var maxId int
	var maxDistance int
	for _, seg := range finishes {
		if distances[seg.Id] > maxDistance {
			maxId = seg.Id
			maxDistance = distances[seg.Id]
		}
	}
	//for id, dist := range distances {
	//	log.Printf("distance (%d): %d", id, dist)
	//}
	// path must lead to the end, which is the seg with no exits. So that's the one we want
	return distances[maxId], routes[maxId]
}

func TopologicalSort(start *PathSegment) (sorted []*PathSegment) {
	visited := make(map[int]struct{})
	var visit func(s *PathSegment)
	visit = func(s *PathSegment) {
		if _, ok := visited[s.Id]; !ok {
			visited[s.Id] = struct{}{}
			for _, successor := range s.Exits {
				visit(successor)
			}
			// prepend
			sorted = append([]*PathSegment{s}, sorted...)
		}
	}
	visit(start)
	return sorted
}
