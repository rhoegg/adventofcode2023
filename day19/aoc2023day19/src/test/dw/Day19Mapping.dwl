/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0
output application/json
import * from dw::core::Arrays
import * from dw::Runtime
import * from Day19

var myInput = parseInput(readData("puzzle-input.txt"))

---
{
    part1: part1(myInput)
}
