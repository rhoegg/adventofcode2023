/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0
output application/json

import * from Day16
var c = loadContraption("sample1.txt")
// var p1data = part1Data("puzzle-input.txt")
---
{
    // part1Data: p1data,
    // part1Energized: energized(p1data.atEnd),
    // part1Beams: sizeOf(p1data.atEnd.beams),
    // part1: sizeOf(p1data.atEnd.visited distinctBy $.location),
    part2Starts: part2Starts(loadContraption("sample1.txt"))
}