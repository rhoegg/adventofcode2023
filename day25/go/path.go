package main

import (
	"container/heap"
	"fmt"
	"slices"
)

type PathInfo struct {
	components []Component
	indexes    map[string]int
	distances  [][]int
	previous   [][]string
}

type Edge struct {
	Component1, Component2 string
}

func (e Edge) String() string {
	return fmt.Sprintf("%s-%s", e.Component1, e.Component2)
}

func (e Edge) Connected(component string) bool {
	return e.Component1 == component || e.Component2 == component
}

func NormalizeEdge(c1, c2 string) Edge {
	if c2 < c1 {
		c1, c2 = c2, c1
	}
	return Edge{Component1: c1, Component2: c2}
}

func (c Component) Edges() (result []Edge) {
	for _, w := range c.Wires {
		result = append(result, NormalizeEdge(c.Name, w))
	}
	return result
}

/**
 * The paths are just slice of Edge
 */
type MinHeap [][]Edge

func (h MinHeap) Len() int           { return len(h) }
func (h MinHeap) Less(i, j int) bool { return len(h[i]) < len(h[j]) } // weight is one per hop
func (h MinHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }

func (h *MinHeap) Push(x interface{}) {
	*h = append(*h, x.([]Edge))
}

func (h *MinHeap) Pop() interface{} {
	old := *h
	n := len(old)
	x := old[n-1]
	*h = old[0 : n-1]
	return x
}

func (pi *PathInfo) Path(source, destination string) []Edge {
	sourceIndex := pi.indexes[source]
	destIndex := pi.indexes[destination]
	if pi.previous[sourceIndex][destIndex] == "" {
		return nil
	}
	var result []Edge
	pos := destination
	for pos != source {
		destIndex = pi.indexes[pos]
		pos = pi.previous[sourceIndex][destIndex]
		result = append(result, Edge{
			Component1: pos,
			Component2: pi.components[destIndex].Name,
		})
	}
	return result
}

func ComputePaths(components []Component) *PathInfo {

	indexes := make(map[string]int)
	for i, c := range components {
		indexes[c.Name] = i
	}
	// all-pairs shortest paths - floyd warshall
	// score each edge by how many paths include it
	var distances [][]int
	var previous [][]string
	for i := 0; i < len(components); i++ {
		var row []int
		var prevRow []string
		var edgeCountRow []int
		for j := 0; j < len(components); j++ {
			row = append(row, len(components)+1)
			prevRow = append(prevRow, "")
			edgeCountRow = append(edgeCountRow, 0)
		}
		distances = append(distances, row)
		previous = append(previous, prevRow)
	}
	for _, c := range components {
		for _, w := range c.Wires {
			distances[indexes[c.Name]][indexes[w]] = 1
			previous[indexes[c.Name]][indexes[w]] = c.Name
		}
		distances[indexes[c.Name]][indexes[c.Name]] = 0
		previous[indexes[c.Name]][indexes[c.Name]] = c.Name
	}
	for k := 0; k < len(components); k++ {
		for i := 0; i < len(components); i++ {
			for j := 0; j < len(components); j++ {
				if distances[i][j] > distances[i][k]+distances[k][j] {
					distances[i][j] = distances[i][k] + distances[k][j]
					previous[i][j] = previous[k][j]
				}
			}
		}
	}

	return &PathInfo{
		components: components,
		indexes:    indexes,
		distances:  distances,
		previous:   previous,
	}
}

func DijkstraShortestPath(wiring map[string]*Component, source, sink string) []Edge {
	return DijkstraShortestRemainingPath(wiring, source, sink, nil)
}

func DijkstraShortestRemainingPath(wiring map[string]*Component, source, sink string, blocked []Edge) []Edge {
	var h MinHeap
	heap.Init(&h)
	visited := make(map[string]struct{})
	for _, e := range blocked {
		visited[e.String()] = struct{}{}
	}
	for _, e := range wiring[source].Edges() {
		if _, ok := visited[e.String()]; !ok {
			heap.Push(&h, []Edge{e}) // new path starting at edge e
			//visited[e.String()] = struct{}{}
			// don't mark the trailheads as visited yet! need to try them below
		}
	}

	for len(h) > 0 {
		thisPath := heap.Pop(&h).([]Edge)
		lastEdge := thisPath[len(thisPath)-1]
		if _, ok := visited[lastEdge.String()]; ok {
			// let's not redo it
			continue
		}
		visited[lastEdge.String()] = struct{}{}
		// not tracking which end of the edge so let's just try both
		for _, componentName := range []string{lastEdge.Component1, lastEdge.Component2} {
			if componentName == sink {
				// hooray!
				return thisPath
			}

			for _, nextEdge := range wiring[componentName].Edges() {
				if nextEdge.Connected(source) {
					continue
				}
				if _, ok := visited[nextEdge.String()]; !ok {
					path := slices.Clone(thisPath)
					heap.Push(&h, append(path, nextEdge))
				}
			}
		}
	}
	return nil
}

func Reachable(wiring map[string]*Component, source string, blocked []Edge) int {
	blocked = slices.Clone(blocked)
	frontier := []string{source}
	var reached []string
	for len(frontier) > 0 {
		next := frontier[0]
		if !slices.Contains(reached, next) {
			reached = append(reached, next)
		}
		frontier = frontier[1:]
		component := wiring[next]
		for _, e := range component.Edges() {
			if !slices.Contains(blocked, e) {
				for _, c := range []string{e.Component1, e.Component2} {
					if c != component.Name && !slices.Contains(reached, c) {
						frontier = append(frontier, c)
					}
				}
			}
		}
	}
	return len(reached)
}
