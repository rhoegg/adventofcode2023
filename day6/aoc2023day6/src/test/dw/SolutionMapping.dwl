/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0
output application/json

import * from Solution
---
{
    part1: raceOptions map countWinningOptions($) 
        reduce (item, acc) -> 
            item * acc,
    part2: winningRange(part2raceResults)
}
