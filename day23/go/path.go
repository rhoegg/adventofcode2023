package main

import (
	"log"
	"slices"
	"strconv"
	"strings"
)

func (s *PathSegment) PruneRabbitTrails(destination int) {
	toPrune := []*PathSegment{s}

	pruned := make(map[int]struct{})
	for len(toPrune) > 0 {
		target := toPrune[0]
		pruned[target.Id] = struct{}{}
		toPrune = toPrune[1:]
		var newExits []*PathSegment
		for _, exit := range target.Edges {
			if exit.LeadsTo(destination) {
				newExits = append(newExits, exit)
				if _, ok := pruned[exit.Id]; !ok {
					toPrune = append(toPrune, exit)
				}
			}
		}
		target.Edges = newExits
	}
}

func TopologicalSort(start *PathSegment) (sorted []*PathSegment) {
	visited := make(map[int]struct{})
	var visit func(s *PathSegment)
	visit = func(s *PathSegment) {
		if _, ok := visited[s.Id]; !ok {
			visited[s.Id] = struct{}{}
			for _, successor := range s.Edges {
				visit(successor)
			}
			// prepend
			sorted = append([]*PathSegment{s}, sorted...)
		}
	}
	visit(start)
	return sorted
}

func (s *PathSegment) LongestPathRecursive(destination int) int {
	length, path := s.longestPathRecursive(destination, nil, nil)
	if path[len(path)-1] == destination {
		var nodes []string
		var lengths []string
		var paths []string
		for _, id := range path {
			nodes = append(nodes, strconv.Itoa(id))
			lengths = append(lengths, strconv.Itoa(len(s.Find(id).Points)))
			paths = append(paths, s.Find(id).String())
		}
		log.Printf("longest path %s", strings.Join(nodes, " "))
		log.Printf("lengths %s", strings.Join(lengths, " "))
		log.Printf("path %s", strings.Join(paths, " - "))
		return length - 1 // for start
	}
	return 0
}

func (s *PathSegment) longestPathRecursive(destination int, visitedSegments []int, visitedPoints []Point) (int, []int) {
	if s.Id == destination {
		return len(s.Points), []int{s.Id}
	}
	maxLength := 0
	var longestPath []int
	for _, exit := range s.Edges {
		if !slices.Contains(visitedSegments, exit.Id) {
			junction := s.Junction(exit)
			if !slices.Contains(visitedPoints, junction) {
				nextVisitedPoints := slices.Clone(visitedPoints)
				for _, p := range []Point{s.Points[0], s.Points[len(s.Points)-1]} {
					if !slices.Contains(visitedPoints, p) {
						nextVisitedPoints = append(nextVisitedPoints, p)
					}
				}
				thisEdgeVisited := append(slices.Clone(visitedSegments), s.Id)
				length, path := exit.longestPathRecursive(destination, thisEdgeVisited, nextVisitedPoints)
				if path[len(path)-1] == destination && length > maxLength {
					maxLength = length
					longestPath = path
				}
			}
		}
	}
	return len(s.Points) + maxLength - 1, append([]int{s.Id}, longestPath...)
}
