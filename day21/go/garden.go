package main

type Garden struct {
	Rocks      map[string]struct{}
	Start      Point
	Dimensions Vector
}

func (g Garden) IsRock(p Point) bool {
	_, ok := g.Rocks[p.String()]
	return ok
}

func (g Garden) PlotsReachedFromStart(start Point, distance int) int {
	return len(g.PlotsReached([]Point{start}, distance))
}

func (g Garden) PlotsReached(starts []Point, distance int) []Point {
	if distance == 0 {
		return starts
	}

	reached := make(map[string]struct{})
	var nextSteps []Point
	for _, start := range starts {
		for _, dir := range []Direction{North, South, East, West} {
			next := dir.From(start)
			if !g.IsRock(next) {
				if _, ok := reached[next.String()]; !ok {
					reached[next.String()] = struct{}{}
					nextSteps = append(nextSteps, next)
				}
			}
		}
	}
	return g.PlotsReached(nextSteps, distance-1)
}
