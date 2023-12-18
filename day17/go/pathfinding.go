package main

import (
	"container/heap"
	"fmt"
	"log"
)

type PathState struct {
	Position      Point
	Direction     Direction
	Trail         []PathState
	StraightSteps int
	HeatLoss      int
	index         int
}

type Vector struct {
	Position  Point
	Direction Direction
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

func PathOrigin(p Point) PathState {
	return PathState{Position: p}
}

func FindPathToFactory(island GearIsland) PathState {
	pq := make(PriorityQueue, 0)
	heap.Init(&pq)
	state := PathOrigin(LavaPool())
	visited := make(map[Vector]int)
	i := 0
	for {
		if state.Position == island.Factory {
			return state
		}

		if i += 1; i%10000 == 0 {
			log.Printf("(%d) Exploring %d,%d %s (%d %d)", i, state.Position.X, state.Position.Y, state.Direction, len(state.Trail), state.HeatLoss)
		}
		visited[Vector{Position: state.Position, Direction: state.Direction}] = state.HeatLoss
		var newTrail []PathState
		for _, ps := range state.Trail {
			newTrail = append(newTrail, ps)
		}
		newTrail = append(newTrail, PathState{
			Position:      state.Position,
			Direction:     state.Direction,
			StraightSteps: state.StraightSteps,
			HeatLoss:      state.HeatLoss,
		})
		// generate all next steps and put in pq
		for _, dir := range []Direction{North, South, East, West} {
			pos := state.Position.Move(dir)
			if island.InBounds(pos) &&
				(!state.Direction.IsBackwards(dir)) &&
				(state.Direction != dir || state.StraightSteps < 3) &&
				!state.OnTrail(pos) {

				newHeatLoss := state.HeatLoss + island.MeasureHeatLoss(pos)
				oldHeatLoss, beenThere := visited[Vector{Position: pos, Direction: dir}]

				if !beenThere || newHeatLoss < oldHeatLoss {
					nextState := PathState{
						Position:      pos,
						Direction:     dir,
						Trail:         newTrail,
						StraightSteps: 1,
						HeatLoss:      newHeatLoss,
					}
					if nextState.Direction == state.Direction {
						nextState.StraightSteps = state.StraightSteps + 1
					}
					heap.Push(&pq, &nextState)
				}
			}
		}
		// take next state from pq
		state = *heap.Pop(&pq).(*PathState)
		//log.Printf("Trying path %s", PrettyState(state))
	}
}

func (ps PathState) PrettyTrail() (lines []string) {
	for _, state := range ps.Trail {
		lines = append(lines, state.Pretty())
	}
	return lines
}

func (ps PathState) Pretty() string {
	return fmt.Sprintf("%d [%d, %d] %s ", ps.HeatLoss, ps.Position.X, ps.Position.Y, ps.Direction)
}

func (ps PathState) OnTrail(p Point) bool {
	for _, pastState := range ps.Trail {
		if p == pastState.Position {
			return true
		}
	}
	return false
}
