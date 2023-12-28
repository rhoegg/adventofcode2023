/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0
output application/json

import * from Day14
var part1Platform = platform("puzzle-input.txt")
---
{
    platform: pretty(part1Platform),
    reversed: pretty(reverse(part1Platform)),
    tiltedNorth: pretty(tiltNorth(part1Platform)),
    part1: score(tiltNorth(part1Platform)),
    part2: score(cycle(part1Platform, 1))
    // ,
    // part2: pretty(cycle(part1Platform, 1000000000))
}