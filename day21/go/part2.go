package main

import (
	"log"
	"math"
)

func part2(garden Garden, goal int) {
	// Part 2
	stepsFromCorner := goal % garden.Dimensions.X
	fullGardenLengths := goal / garden.Dimensions.X
	log.Printf("steps ito farthest garden at goal: %d", stepsFromCorner)
	// will be 65 steps from the center on horizontal and vertical extremes,
	// which exactly matches the steps to get out of the center garden
	log.Printf("garden lengths covered by goal: %d", fullGardenLengths)

	blackoutEven := garden.PlotsReachedFromStart(garden.Start, garden.Dimensions.X-1)
	blackoutOdd := garden.PlotsReachedFromStart(garden.Start, garden.Dimensions.X)

	log.Printf("blackout counts at %d: odd %d even %d", garden.Dimensions.X, blackoutOdd, blackoutEven)

	//evenPlots := garden.PlotsReached([]Point{Point{X: 0, Y: 0}}, stepsFromCorner-1)
	//log.Printf("from corner even (%d) :\n%s", stepsFromCorner-1, garden.PrintWithPoints(evenPlots))
	//oddPlots := garden.PlotsReached([]Point{Point{X: 0, Y: 0}}, stepsFromCorner-1)
	//oddPlots := garden.PlotsReached([]Point{garden.Start}, 25)
	//log.Printf("from corner odd (%d) :\n%s", stepsFromCorner, garden.PrintWithPoints(oddPlots))
	// we will be 65 steps from the corner on all the diagonal edges
	//fromNorthWestOdd := garden.PlotsReachedFromStart(
	//	Point{X: 0, Y: 0}, stepsFromCorner-2)
	//fromNorthEastOdd := garden.PlotsReachedFromStart(
	//	Point{X: garden.Dimensions.X - 1, Y: 0}, stepsFromCorner-2)
	//fromSouthWestOdd := garden.PlotsReachedFromStart(
	//	Point{X: 0, Y: garden.Dimensions.Y - 1}, stepsFromCorner-2)
	//fromSouthEastOdd := garden.PlotsReachedFromStart(
	//	Point{X: garden.Dimensions.X - 1, Y: garden.Dimensions.Y - 1}, stepsFromCorner-2)
	//log.Printf("corner reached after %d: %d %d %d %d", stepsFromCorner, fromNorthWestOdd, fromNorthEastOdd, fromSouthWestOdd, fromSouthEastOdd)
	//fromNorthWestEven := garden.PlotsReachedFromStart(
	//	Point{X: 0, Y: 0}, stepsFromCorner-1)
	//fromNorthEastEven := garden.PlotsReachedFromStart(
	//	Point{X: garden.Dimensions.X - 1, Y: 0}, stepsFromCorner-1)
	//fromSouthWestEven := garden.PlotsReachedFromStart(
	//	Point{X: 0, Y: garden.Dimensions.Y - 1}, stepsFromCorner-1)
	//fromSouthEastEven := garden.PlotsReachedFromStart(
	//	Point{X: garden.Dimensions.X - 1, Y: garden.Dimensions.Y - 1}, stepsFromCorner-1)
	//log.Printf("corner reached after %d: %d %d %d %d", stepsFromCorner-1, fromNorthWestEven, fromNorthEastEven, fromSouthWestEven, fromSouthEastEven)
	// blackouts are full garden lengths
	oddBlackoutGardens := int64(math.Pow(float64(fullGardenLengths), 2))
	evenBlackoutGardens := int64(math.Pow(float64(fullGardenLengths+1), 2))
	totalOddCorners := blackoutOdd - garden.PlotsReachedFromStart(garden.Start, stepsFromCorner-1)
	totalEvenCorners := blackoutEven - garden.PlotsReachedFromStart(garden.Start, stepsFromCorner)

	log.Printf("odd/even blackout gardens: %d %d", oddBlackoutGardens, evenBlackoutGardens)
	log.Printf("garden lengths %d", fullGardenLengths)
	reachable := oddBlackoutGardens*blackoutOdd +
		evenBlackoutGardens*blackoutEven -
		(int64(fullGardenLengths+1) * totalEvenCorners) +
		(int64(fullGardenLengths) * totalOddCorners)
	log.Printf("reachable for part 2 = %d (%d-%d+%d)", reachable,
		oddBlackoutGardens*blackoutOdd+evenBlackoutGardens*blackoutEven,
		(int64(fullGardenLengths+1) * totalEvenCorners),
		(int64(fullGardenLengths) * totalOddCorners))
	// this is  too low 3164411023
	// too high 630129838528695
	//          630129824772393
	log.Printf("after full %d", garden.PlotsReachedFromStart(garden.Start, garden.Dimensions.X-1))
	log.Printf("after half %d", garden.PlotsReachedFromStart(garden.Start, stepsFromCorner))
	plots := garden.PlotsReached([]Point{garden.Start}, 8)
	log.Printf("half garden\n%s", garden.PrintWithPoints(plots))

}
