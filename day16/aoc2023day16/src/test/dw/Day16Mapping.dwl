%dw 2.0
output application/json

import * from Day16

var inputFile = "sample1.txt"
var c = loadContraption(inputFile)
var p1data = part1Data(inputFile)
---
{
    // part1Data: p1data,
    // part1Energized: energized(p1data.atEnd),
    // part1Beams: sizeOf(p1data.atEnd.beams),
    part1: sizeOf(p1data.atEnd.visited distinctBy $.location),
    part2Starts: part2Starts(c),
    part2attempt: allVisitedPoints(c.contraption, c.beams[0]) // memoizable
}