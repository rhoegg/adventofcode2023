/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0 
output application/json
import * from dw::core::Arrays
import * from Day12

var difficulty = do {
        var counts = parseConditionRecords("puzzle-input.txt") map (record) ->
            sizeOf(record.conditionRecord filter (c) -> c == "?") 
        ---
        ((counts groupBy $) pluck (items, count) -> {
            difficulty: count as Number,
            count: sizeOf(items)
        }) orderBy $.difficulty
    }
---
{
    // part1: part1("sample1.txt"),
    part2: part2("sample1.txt")
}