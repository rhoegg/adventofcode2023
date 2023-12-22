package main

import (
	"container/heap"
	"fmt"
	"log"
)

type PathState struct {
	Position      Point
	Direction     Direction
	Last          *PathState
	StraightSteps int8
	HeatLoss      int16
	index         int
}

type VisitedKey struct {
	Position      Point
	Direction     Direction
	StraightSteps int8
}

type PriorityQueue []*PathState

func (pq PriorityQueue) Len() int { return len(pq) }
func (pq PriorityQueue) Less(i, j int) bool {
	return pq[i].HeatLoss < pq[j].HeatLoss
}
func (pq PriorityQueue) Swap(i, j int) {
	pq[i], pq[j] = pq[j], pq[i]
	pq[i].index = i
	pq[j].index = j
}
func (pq *PriorityQueue) Push(x any) {
	n := len(*pq)
	state := x.(*PathState)
	state.index = n
	*pq = append(*pq, state)
}
func (pq *PriorityQueue) Pop() any {
	old := *pq
	n := len(old)
	state := old[n-1]
	old[n-1] = nil // prevent memory leak
	state.index = -1
	*pq = old[0 : n-1]
	return state
}

func (pq *PriorityQueue) Contains(p Point, d Direction) bool {
	for _, ps := range *pq {
		if ps.Position == p && ps.Direction == d {
			return true
		}
	}
	return false
}

func PathOrigin(p Point) *PathState {
	return &PathState{Position: p}
}

func FindPathToFactory(island GearIsland) PathState {
	pq := make(PriorityQueue, 0)
	heap.Init(&pq)
	state := PathOrigin(LavaPool())
	visited := make(map[VisitedKey]int16)
	i := 0
	h := 0
	for {
		if state.Position == island.Factory { //|| state.HeatLoss > 210
			return *state
		}
		// generate all next steps and put in pq
		var pos Point
		for _, dir := range []Direction{North, South, East, West} {
			pos = state.Position.MoveOne(dir)
			if island.InBounds(pos) &&
				(!state.Direction.IsBackwards(dir)) &&
				(state.Direction != dir || state.StraightSteps < 3) {

				nextState := PathState{
					Position:      pos,
					Direction:     dir,
					Last:          state,
					StraightSteps: 1,
					HeatLoss:      state.HeatLoss + island.MeasureHeatLoss(pos),
				}
				if nextState.Direction == state.Direction {
					nextState.StraightSteps = state.StraightSteps + 1
				}

				oldHeatLoss, beenThere := visited[nextState.VisitedKey()]
				if !beenThere || oldHeatLoss > nextState.HeatLoss {
					visited[nextState.VisitedKey()] = nextState.HeatLoss
					if i += 1; i%100000 == 0 {
						log.Printf("(%d %d %d) Exploring %d,%d %s (%d)", i, h, len(visited), nextState.Position.X, nextState.Position.Y, nextState.Direction, nextState.HeatLoss)
					}
					heap.Push(&pq, &nextState)
					h += 1
				}
			}
		}
		// take next state from pq
		state = heap.Pop(&pq).(*PathState)
		h -= 1
	}
}

func FindUltraCruciblePath(island GearIsland) PathState {
	pq := make(PriorityQueue, 0)
	heap.Init(&pq)
	state := PathOrigin(LavaPool())
	visited := make(map[VisitedKey]int16)
	i := 0
	h := 0
	for {
		if state.Position == island.Factory { //|| state.HeatLoss > 210
			return *state
		}
		// generate all next steps and put in pq
		var pos Point
		for _, dir := range []Direction{North, South, East, West} {
			if state.Direction == dir {
				pos = state.Position.Move(dir, 1)
			} else {
				pos = state.Position.Move(dir, 4)
			}
			if island.InBounds(pos) &&
				(!state.Direction.IsBackwards(dir)) &&
				(state.Direction != dir || state.StraightSteps < 10) {

				nextState := PathState{
					Position:      pos,
					Direction:     dir,
					Last:          state,
					StraightSteps: 4,
					HeatLoss:      state.HeatLoss + island.MeasureHeatLoss(pos),
				}
				if nextState.Direction == state.Direction {
					nextState.StraightSteps = state.StraightSteps + 1
				}
				if state.Direction != dir {
					nextState.HeatLoss +=
						island.MeasureHeatLoss(state.Position.Move(dir, 1)) +
							island.MeasureHeatLoss(state.Position.Move(dir, 2)) +
							island.MeasureHeatLoss(state.Position.Move(dir, 3))
				}

				oldHeatLoss, beenThere := visited[nextState.VisitedKey()]
				if !beenThere || oldHeatLoss > nextState.HeatLoss {
					visited[nextState.VisitedKey()] = nextState.HeatLoss
					if i += 1; i%100000 == 0 {
						log.Printf("(%d %d %d) Exploring %d,%d %s (%d)", i, h, len(visited), nextState.Position.X, nextState.Position.Y, nextState.Direction, nextState.HeatLoss)
					}
					heap.Push(&pq, &nextState)
					h += 1
				}
			}
		}
		// take next state from pq
		state = heap.Pop(&pq).(*PathState)
		h -= 1
	}
}

func (ps PathState) PrettyTrail() (lines []string) {
	if ps.Last != nil {
		lines = append(lines, ps.Last.PrettyTrail()...)
	}
	lines = append(lines, ps.Pretty())
	return lines
}

func (ps PathState) Pretty() string {
	return fmt.Sprintf("%d [%d, %d] %s ", ps.HeatLoss, ps.Position.X, ps.Position.Y, ps.Direction)
}

func (ps PathState) OnTrail(p Point) bool {
	if ps.Last == nil {
		return false
	}
	if ps.Last.Position == p {
		return true
	}
	return ps.Last.OnTrail(p)
}

func (ps PathState) VisitedKey() VisitedKey {
	return VisitedKey{
		Position:      ps.Position,
		Direction:     ps.Direction,
		StraightSteps: ps.StraightSteps,
	}
}
