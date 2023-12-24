package main

import (
	"fmt"
	"log"
	"slices"
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

	trail2 := ParseHikingTrails("puzzle-input.txt", false)
	distance2, route2 := LongestPath(trail2)
	ids = nil
	for _, id := range route2 {
		ids = append(ids, strconv.Itoa(id))
	}
	log.Printf("same path algorithm as part 1: %d", distance2)
	log.Printf("Part 2 trail %s", AuditTrail(trail2))
	log.Printf("complete trail: %d, trimmed %d",
		len(TopologicalSort(trail2)), len(SortAndTrim(trail2)))
	//distance2 = LongestPathBruteForce(trail2)
	log.Printf("Part 2 %d", distance2)
	// Notes after pausing on Part 2. These are resolved now
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
	//for id, dist := range distances {
	//	log.Printf("distance (%d): %d", id, dist)
	//}
	// path must lead to the end, which is the last seg with no exits. So that's the one we want
	nodes := TopologicalSort(trail)
	endNode := nodes[len(nodes)-1]
	return distances[endNode.Id], routes[endNode.Id]
}

// needs to account for duplicate nodes (I generated separate nodes for reverse paths)
func LongestPathBruteForce(trail *PathSegment) int {
	distances := make(map[int]int)
	distances[trail.Id] = len(trail.Points) - 1
	visited := make(map[int]struct{})
	paths := make(map[int][]PathSegment)
	allNodes := TopologicalSort(trail)

	var findLongestPath func(node *PathSegment, currentDistance int, currentPath []PathSegment)
	findLongestPath = func(node *PathSegment, currentDistance int, currentPath []PathSegment) {
		if _, ok := visited[node.Id]; ok {
			return
		}
		var reverse *PathSegment
		for _, other := range allNodes {
			if other.Equivalent(*node) {
				if _, okReverse := visited[other.Id]; okReverse {
					return
				}
				reverse = other
			}
		}
		visited[node.Id] = struct{}{}
		if reverse != nil {
			visited[reverse.Id] = struct{}{}
		}

		if distances[node.Id] < currentDistance {
			distances[node.Id] = currentDistance
			paths[node.Id] = currentPath
		}
		for _, exit := range node.Exits {
			findLongestPath(exit, currentDistance+len(exit.Points), append(slices.Clone(currentPath), *exit))
		}
		delete(visited, node.Id)
		if reverse != nil {
			delete(visited, reverse.Id)
		}
	}
	findLongestPath(trail, distances[trail.Id], []PathSegment{*trail})
	var maxId int
	maxDistance := 0
	for id := range distances {
		if distances[id] > maxDistance {
			maxId = id
			maxDistance = distances[id]
		}
	}
	var pathIds []string
	for _, node := range paths[maxId] {
		pathIds = append(pathIds, strconv.Itoa(node.Id))
	}
	log.Printf("Longest path is %d: %s", maxId, strings.Join(pathIds, ","))

	//return distances[maxId]
	log.Println("But we don't want that one! We want the exit segment!")
	exitNode := allNodes[len(allNodes)-1]
	for _, node := range paths[exitNode.Id] {
		pathIds = append(pathIds, strconv.Itoa(node.Id))
	}
	// FIXME: the saved path seems wrong even though the distance is right
	log.Printf("Exit path is %d: %s", exitNode.Id, strings.Join(pathIds, ","))
	return distances[exitNode.Id]
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

func AuditTrail(trail *PathSegment) string {
	var nodes []string
	for _, seg := range TopologicalSort(trail) {
		var exitIds []string
		for _, exit := range seg.Exits {
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
				for _, nodeExit := range node.Exits {
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
