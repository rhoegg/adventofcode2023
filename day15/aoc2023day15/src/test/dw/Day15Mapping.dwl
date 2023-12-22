/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0
output application/json

import * from Day15

var inputSequence = loadInitializationSequence("puzzle-input.txt")
---
{
    inputSequence: inputSequence,
    part1: part1(inputSequence),
    part2: initializationCheck(initializeLPF(inputSequence))
}