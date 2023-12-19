/**
* This module will be shared through your library, feel free to modify it as you please.
*
* You can try it out with the mapping on the src/test/dw directory.
*/
%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings

type PartRating = {
    x: Number,
    m: Number,
    a: Number,
    s: Number
}

type Workflow = {
    name: String,
    rules: Array<WorkflowRule>
}

type WorkflowRule = {
    condition?: (PartRating) -> Boolean,
    target: String
}

fun readData(filename) =
    readUrl("classpath://$(filename)", "text/plain")

fun parseInput(data) = do {
    var chunks = data splitBy "\n\n"
    ---
    {
        workflows: parseWorkflows(chunks[0]),
        partRatings: parsePartRatings(chunks[1])
    }
}

fun parseWorkflows(chunk: String) = {(
        lines(chunk) map (line) -> do {
            var name = line substringBefore "{"
            var rules = (line substringAfter "{")[0 to -2] splitBy "," map (ruleText) ->
                parseWorkflowRule(ruleText)
            ---
            {
                (name): {
                    name: name,
                    rules: rules
                }
            }
        }
)}


fun parseWorkflowRule(ruleText: String): WorkflowRule = do {
    var parts = ruleText splitBy ":"
    ---
    {
        (condition: parseCondition(parts[0])) if (! isEmpty(parts[1])),
        target: parts[-1]
    }
}

fun parseCondition(conditionText) = do {
    var threshold = conditionText[2 to -1] as Number
    var ratingLetter = conditionText[0]
    ---
    {
        rating: ratingLetter,
        operation: conditionText[1] match {
            case ">" -> (rating: PartRating) -> rating[ratingLetter] > threshold
            else -> (rating: PartRating) -> rating[ratingLetter] < threshold 
        },
        threshold: threshold
    }
}

fun parsePartRatings(chunk: String): Array<PartRating> =
    lines(chunk) map (line) -> do {
        var ratings = line[1 to -2] splitBy ","
        var x = (ratings[0] splitBy "=")[1]
        var m = (ratings[1] splitBy "=")[1]
        var a = (ratings[2] splitBy "=")[1]
        var s = (ratings[3] splitBy "=")[1]
        ---
        {
            x: x,
            m: m,
            a: a,
            s: s
        } mapObject (($$): $ as Number)
    }

fun startingWorkflow(workflows) =
    workflows.in