/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0
output application/json

import * from Day9
---
{
    part1: sum(oasisHistoryLines("puzzle-input.txt") map predict($)[-1]),
    part2: sum(oasisHistoryLines("puzzle-input.txt") map $[-1 to 0] map predict($)[-1])
}