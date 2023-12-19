/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0
output application/json
import * from dw::core::Arrays
import * from Day19

var myInput = parseInput(readData("sample1.txt"))
var start = startingWorkflow(myInput.workflows)
---
// THE PLAN: reduce this below until we reach a target of A or R for each part rating
// - filter for A's
// add up the 4 ratings for each, and sum for the part 1 solution!
myInput.partRatings map (partRating) -> do {
    var matchedRule = startingWorkflow(myInput.workflows).rules firstWith (rule) ->
        (rule.condition == null) or rule.condition(partRating)
    ---
    matchedRule.target
}