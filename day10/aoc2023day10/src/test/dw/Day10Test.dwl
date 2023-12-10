/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0
import * from Day10

output application/json
var tileMap = tiles(load("puzzle-input.txt"))
var start = findStart(tileMap)
var theFirstStep = firstStep(tileMap, start)
var loopPath = pathToStart(tileMap,
        [start move theFirstStep],
        start move theFirstStep,
        theFirstStep)
---
{
    directions: directions,
    start: start,
    firstStep: theFirstStep,
    secondStep: nextStep(tileMap,
        start move theFirstStep,
        oppositeDirection(theFirstStep)),
    part1: distanceToStart(tileMap, 1,
        start move theFirstStep,
       theFirstStep) / 2,
    // loopPath: loopPath,
    enclosed: countEnclosed(tileMap, loopPath)
}
