/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0
output application/json

import * from Day20

var begin = initModuleStates(
    loadModuleConfiguration("puzzle-input.txt"))
---
{
    //begin: begin,
    part1: part1(begin)
}