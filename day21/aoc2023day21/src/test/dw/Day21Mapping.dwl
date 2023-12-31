%dw 2.0
output application/json

import * from Day21
var garden = parseGarden("puzzle-input.txt")

---
{
    garden: garden,
    // oneStep: gardenStep(garden.plots, [garden.start]),
    // threeSteps: gardenWalk(garden.plots, garden.start, 3),
    // sixSteps: sizeOf(gardenWalk(garden.plots, garden.start, 6)),
    // part1: sizeOf(gardenWalk(garden.plots, garden.start, 64)),
    // part 2 extends to infinitely tiled map and many more steps!
    // part2start: infiniteGardenWalk({garden: garden.plots, cache: {}}, part2Start(garden.start, 50), 50),
    // part2working: part2Counts(garden, 196)
    part2working: findStablePatternStep(garden)
}
