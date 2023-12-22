/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0
output application/json

import * from Day18

var trench = plotTrench(loadDigPlan("puzzle-input.txt"))
---
{
    // digPlan: loadDigPlan("sample1.txt"),
    // trench: trench,
    part1: sizeOf(measureAreaLaboriouslySlow(trench))
}
