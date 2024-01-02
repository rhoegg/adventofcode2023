%dw 2.0
output application/json

import * from Day24
---
{
    part1: part1("sample1.txt", 7, 27),
    // part1: part1("puzzle-input.txt", 200000000000000, 400000000000000),
    part2: part2("sample1.txt")
}
