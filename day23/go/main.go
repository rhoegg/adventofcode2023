package main

import (
	"fmt"
	"log"
	"strconv"
	"strings"
)

func main() {
	//var ids []string

	//trail := ParseHikingTrails("puzzle-input.txt", true)
	//distance, route := LongestPath(trail)
	//for _, id := range route {
	//	ids = append(ids, strconv.Itoa(id))
	//}
	//log.Printf("Part 1 %d: %s", distance, strings.Join(ids, ","))

	trail2 := ParseHikingTrails("puzzle-input.txt", false)
	log.Printf("trail %d", trail2.Id)

	sorted := TopologicalSort(trail2)
	destination := sorted[len(sorted)-1].Id
	log.Printf("Part 2 %d", trail2.LongestPathRecursive(destination))
}

func LongestPath(trail *PathSegment) (int, []int) {
	distances := make(map[int]int)
	routes := make(map[int][]int)
	// initialize trailhead to the actual length instead of 0 because there is only one start
	// and the segment length is sunk cost
	distances[trail.Id] = len(trail.Points) - 1 // not counting starting position
	var finishes []*PathSegment
	sorted := TopologicalSort(trail)
	destination := sorted[len(sorted)-1].Id
	//trail.PruneRabbitTrails(destination)
	sorted = TopologicalSort(trail)

	for _, seg := range sorted {
		if len(seg.Edges) == 0 {
			p := seg.Points[len(seg.Points)-1]
			log.Printf("no exits %d (%d,%d)", seg.Id, p.X, p.Y)
			finishes = append(finishes, seg)
		}
		for _, successor := range seg.Edges {
			// use the longest route here,
			candidate := distances[seg.Id] + len(successor.Points)
			if candidate > distances[successor.Id] {
				distances[successor.Id] = candidate
				routes[successor.Id] = append(routes[seg.Id], seg.Id)
			}
		}
	}
	//var maxId int
	//var maxDistance int
	//for _, seg := range finishes {
	//	if distances[seg.Id] > maxDistance {
	//		maxId = seg.Id
	//		maxDistance = distances[seg.Id]
	//	}
	//}
	for id, dist := range distances {
		log.Printf("distance (%d): %d", id, dist)
	}
	// path must lead to the end, which is the last seg with no exits. So that's the one we want

	return distances[destination], routes[destination]
}

func AuditTrail(trail *PathSegment) string {
	var nodes []string
	for _, seg := range TopologicalSort(trail) {
		var exitIds []string
		for _, exit := range seg.Edges {
			exitIds = append(exitIds, strconv.Itoa(exit.Id))
		}
		nodes = append(nodes, fmt.Sprintf("Node %d (%d,%d): %s",
			seg.Id, seg.Points[0].X, seg.Points[0].Y, strings.Join(exitIds, ",")))
	}
	return strings.Join(nodes, "\n")
}

func SortAndTrim(trail *PathSegment) (result []*PathSegment) {
	nodes := TopologicalSort(trail)
	wantedNodes := make(map[int]struct{})
	destination := nodes[len(nodes)-1]
	var sources []*PathSegment
	sources = append(sources, destination)
	for len(sources) > 0 {
		log.Printf("Trim checking %d", len(sources))
		for _, source := range sources {
			wantedNodes[source.Id] = struct{}{}
		}
		var newSources []*PathSegment
		for _, oldSource := range sources {
			for _, node := range nodes {
				for _, nodeExit := range node.Edges {
					if nodeExit == oldSource {
						newSources = append(newSources, nodeExit)
					}
				}
			}
		}
		sources = newSources
	}
	for _, node := range nodes { // already sorted
		if _, ok := wantedNodes[node.Id]; ok {
			result = append(result, node)
		}
	}
	return result
}

func LogSegments(segments []*PathSegment) {
	for _, n := range segments {
		var exits []string
		for _, e := range n.Edges {
			exits = append(exits, strconv.Itoa(e.Id))
		}
		log.Printf("Seg %d -> %s", n.Id, strings.Join(exits, ","))
	}
}
