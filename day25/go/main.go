package main

import (
	"fmt"
	"log"
	"math/rand"
	"slices"
	"strings"
)

func main() {
	components := ParseWiringDiagram("puzzle-input.txt")
	log.Printf("Loaded %d components", len(components))
	//for _, c := range components {
	//	log.Printf("%s: %s", c.Name, strings.Join(c.Wires, " "))
	//}
	log.Printf("Part 1: %d", Part1(components))
}

func Part1(components []Component) int {

	var cuts [3]Edge
	ok := false
	for !ok {
		source, sink, criticalPaths := FindThreeCriticalPaths(components)
		log.Printf("(%s - %s) %d %d %d", source, sink, len(criticalPaths[0]), len(criticalPaths[1]), len(criticalPaths[2]))
		// follow each path, cutting a segment until there's no path except the other two, remembering the cut segment
		cuts, ok = FindCuts(components, source, sink, criticalPaths)
		log.Printf("cuts %s %s %s", cuts[0], cuts[1], cuts[2])
		// cut all three, measure the reachable from source and sink, and multiply
		sourceReachable := ReachableWithCuts(components, source, cuts)
		log.Printf("source %s can reach %d", source, sourceReachable)
		sinkReachable := ReachableWithCuts(components, sink, cuts)
		log.Printf("sink %s can reach %d", sink, sinkReachable)
		return sourceReachable * sinkReachable
	}
	return 0
}

func FindThreeCriticalPaths(components []Component) (source, sink string, paths [3][]Edge) {
	wiring := make(map[string]*Component)
	for i := range components {
		c := components[i]
		wiring[c.Name] = &c
	}
	for i := 1; ; i++ {
		// find two points that have no more than three shortest paths
		sourceIndex, destIndex := rand.Intn(len(components)), rand.Intn(len(components))
		for sourceIndex == destIndex {
			sourceIndex, destIndex = rand.Intn(len(components)), rand.Intn(len(components))
		}
		source = components[sourceIndex].Name
		sink = components[destIndex].Name
		log.Printf("Trying %s - %s", source, sink)
		firstPath := DijkstraShortestPath(wiring, source, sink)
		logPath("Path 1", firstPath)
		blocked := slices.Clone(firstPath)
		secondPath := DijkstraShortestRemainingPath(wiring, source, sink, blocked)
		if secondPath == nil {
			panic(fmt.Sprintf("unable to find second path for %s - %s", source, sink))
		}
		logPath("Path 2", secondPath)
		blocked = append(blocked, secondPath...)
		thirdPath := DijkstraShortestRemainingPath(wiring, source, sink, blocked)
		if thirdPath == nil {
			panic(fmt.Sprintf("unable to find third path for %s - %s", source, sink))
		}
		logPath("Path 3", thirdPath)
		blocked = append(blocked, thirdPath...)
		fourthPath := DijkstraShortestRemainingPath(wiring, source, sink, blocked)
		if fourthPath == nil {
			log.Printf("Found three critical paths in %d tries", i)
			return source, sink, [3][]Edge{firstPath, secondPath, thirdPath}
		}
		if i > 1000 {
			panic("aborting because unable to find three critical paths")
		}
	}
}

func FindCuts(components []Component, source, sink string, paths [3][]Edge) (result [3]Edge, ok bool) {
	wiring := make(map[string]*Component)
	for i := range components {
		c := components[i]
		wiring[c.Name] = &c
	}

	ok = true
	for i := range paths {
		var blocked []Edge
		// block other two paths
		for j := range paths {
			if j != i {
				blocked = append(blocked, paths[j]...)
			}
		}
		foundCut := false
		for _, edge := range paths[i] {
			// cut
			blocked = append(blocked, edge)
			path := DijkstraShortestRemainingPath(wiring, source, sink, blocked)
			if path == nil {
				result[i] = edge
				foundCut = true
				break
			}
			// put back
			blocked = blocked[0 : len(blocked)-1]
		}
		if !foundCut {
			logPath("problem path", paths[i])
			ok = false
		}
	}
	return result, ok
}

func ReachableWithCuts(components []Component, source string, cuts [3]Edge) int {
	wiring := make(map[string]*Component)
	for i := range components {
		c := components[i]
		wiring[c.Name] = &c
	}
	var blockedEdges []Edge
	for _, c := range cuts {
		blockedEdges = append(blockedEdges, c)
	}
	return Reachable(wiring, source, blockedEdges)
}

func logPath(prefix string, path []Edge) {
	var steps []string
	for _, e := range path {
		steps = append(steps, e.String())
	}
	log.Printf("%s %s", prefix, strings.Join(steps, " "))
}
