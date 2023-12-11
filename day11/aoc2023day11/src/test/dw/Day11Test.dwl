/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0
output application/json

import * from Day11
var spaceMap = parseSpaceMap("puzzle-input.txt")
var galaxies = findGalaxies(spaceMap)
---
{
    //distances: manhattanDistances(galaxies[0], galaxies[1 to -1]),
    part1: part1(galaxies),
    // part2paths: expandedPaths("sample1.txt", 1000000),
    part2: part2("puzzle-input.txt", 1000000)
}