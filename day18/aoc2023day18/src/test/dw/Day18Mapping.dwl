/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0
output application/json

import * from Day18

var plan = loadDigPlan("puzzle-input.txt")
var part2Plan = loadDigPlanPart2("puzzle-input.txt")
var trench = plotTrench(plan)
---
{
    // digPlan: loadDigPlan("sample1.txt"),
    // trench: trench,
    // part1: sizeOf(measureAreaLaboriouslySlow(trench))
    part2Working: measureAreaShoelace(plan),
    // part2Plan: part2Plan
    part2: measureAreaShoelace(part2Plan)
}
