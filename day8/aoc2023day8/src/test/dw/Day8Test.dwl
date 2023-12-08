/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0
import * from dw::core::Objects
output application/json

import * from Day8

var maps = parseMaps("puzzle-input.txt")
var ghostStartNodes = keySet(maps.nodes) filter ($ endsWith "A")
---
{
    // part1: stepsFrom(maps, "AAA"),
    part2Start: ghostStartNodes,
    part2: log(ghostStartNodes map (startNode) ->
        {
            startNode: startNode,
            steps: stepsToAnyZ(maps, startNode) 
        }
    ) map $.steps reduce (steps, aggregateSteps) ->
        lcm(steps, aggregateSteps)
       
}
