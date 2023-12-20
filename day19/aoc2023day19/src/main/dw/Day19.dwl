%dw 2.0
import * from dw::Runtime
import * from dw::core::Arrays
import * from dw::core::Objects
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
    condition?: PartRatingPredicate,
    ruleDescriptor: {
        constraint: String, // less or greater or all
        target: String,
        ratingLetter?: String,
        threshold?: Number
    },
    target: String
}

type PartRatingPredicate = (PartRating) -> Boolean

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
        ruleDescriptor: do {
            var all = isEmpty(parts[1])
            ---
            {
                constraint: if (all) "all"
                    else if (parts[0][1] == ">") "greater"
                    else "less",
                target: parts[-1],
                (ratingLetter: parts[0][0]) if (! all),
                (threshold: parts[0][2 to -1] as Number) if (! all)
            }
        },
        target: parts[-1]
    }
}

fun parseCondition(conditionText: String): PartRatingPredicate = do {
    var threshold = conditionText[2 to -1] as Number
    var ratingLetter = conditionText[0]
    ---
    conditionText[1] match {
            case ">" -> (rating: PartRating) -> rating[ratingLetter] > threshold
            else -> (rating: PartRating) -> rating[ratingLetter] < threshold 
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

fun runWorkflow(workflow: Workflow, partRating: PartRating): String = do {
    var matchedRule = workflow.rules firstWith (rule) ->
        (rule.condition == null) or rule.condition(partRating)
    ---
    matchedRule.target default fail("no matched rule")
}

fun runWorkflows(workflows: Object, partRating: PartRating, name: String = "in"): { result: String, partRating: PartRating } = do {
    var workflow = workflows[name] as Workflow
    var target = runWorkflow(workflow, partRating)
    var result = {partRating: partRating}
    ---
    target match {
        case "A" -> result ++ {result: target}
        case "R" -> result ++ {result: target}
        else -> runWorkflows(workflows, partRating, target)
    }
}

fun part1(myInput) = do {
    var workflowResults = myInput.partRatings map (partRating) -> 
        runWorkflows(myInput.workflows, partRating)
    var accepted = workflowResults filter (result) -> result.result == "A"
    var acceptedRatingSums = accepted map (result) -> 
        sum(result.partRating pluck (ratingValue, category) -> ratingValue)
    ---
    sum(acceptedRatingSums)
}


var part2MaxRanges = {
    x: { min: 1, max: 4000 },
    m: { min: 1, max: 4000 },
    a: { min: 1, max: 4000 },
    s: { min: 1, max: 4000 }
}

fun findAcceptedRanges(workflows: Object, ranges: Array): Array = 
    findRuleRanges(workflows, true, ranges)

fun findRuleRanges(workflows: Object, filterRejected: Boolean, ranges: Array): Array = do {
    var acceptedSplit = ranges partition (range) ->
        range.target == "A" or (! filterRejected and range.target == "R")
    var acceptedRanges = acceptedSplit.success
    var workingRanges = acceptedSplit.failure
        filter (range) ->
            (! filterRejected) or (range.target != "R")
    var resolveRanges = workingRanges flatMap (range) -> do {
        var workflow = workflows[range.target]
        // flatMap rules, take subset of starting range that matches and produce range
        ---
        (workflow.rules reduce (rule, acc = {available: range.ranges, nextRanges: []}) -> do {
            var ratingLetter = log(workflow.name, rule.ruleDescriptor).ratingLetter
            var declaredRange = log("in " ++ rule.ruleDescriptor.target default "end", acc.available) mergeWith (
                rule.ruleDescriptor.constraint match {
                    case "less" -> {
                        (ratingLetter): {
                            min: 1,
                            max: rule.ruleDescriptor.threshold - 1
                        }
                    }
                    case "greater" -> {
                        (ratingLetter): {
                            min: rule.ruleDescriptor.threshold + 1,
                            max: 4000
                        }
                    }
                    else -> {}
                }
            )
            var newRanges = 
                if (rule.ruleDescriptor.constraint == "all")
                    acc.available
                else
                    acc.available mergeWith {
                        (ratingLetter): {
                            min: max([
                                acc.available[ratingLetter].min,
                                declaredRange[ratingLetter].min
                            ]),
                            max: min([
                                acc.available[ratingLetter].max,
                                declaredRange[ratingLetter].max
                            ])
                        }
                    }
            var availableRanges = 
                if (rule.ruleDescriptor.constraint == "all")
                    acc.available
                else
                    acc.available mergeWith (
                        rule.ruleDescriptor.constraint match {
                            case "less" -> {
                                (ratingLetter): {
                                    min: declaredRange[ratingLetter].max + 1,
                                    max: acc.available[ratingLetter].max
                                }
                            }
                            case "greater" -> {
                                (ratingLetter): {
                                    min: acc.available[ratingLetter].min,
                                    max: declaredRange[ratingLetter].min - 1
                                }
                            }
                            else -> {}
                        }
                    )
            ---
            {
                available: log("out " ++ rule.ruleDescriptor.target default "end", availableRanges),
                nextRanges: acc.nextRanges << {
                    ranges: newRanges,
                    target: rule.ruleDescriptor.target
                }
            }
        }).nextRanges
    }
    ---
    if (isEmpty(resolveRanges)) acceptedRanges
    else acceptedRanges ++ findRuleRanges(workflows, filterRejected, resolveRanges)
}

fun intersect(r1, r2) = {
    min: max([r1.min, r2.min]),
    max: min([r1.max, r2.max])
}

fun countRange(r) = r.max - r.min + 1

// look at the evil input sjd{s<1082:A,m>261:A,m<97:R,A}
fun part2(myInput) = do {
    // find intersection ranges and multiply
    var ruleRanges = findRuleRanges(myInput.workflows, true, [{ranges: part2MaxRanges, target: "in"}])
    var ruleCounts = (ruleRanges reduce (ruleRange, acc={counts:[], available: part2MaxRanges}) -> do {
            var range = ruleRange.ranges
            var count = (range pluck (r) -> countRange(r))
                                reduce (i, p = 1) -> i * p
            ---
            {
                counts: acc.counts << if (ruleRange.target == "A") count else 0,
                ranges: (acc.ranges default []) << range,
                available: {
                    x: intersect(range.x, acc.available.x),
                    m: intersect(range.m, acc.available.m),
                    a: intersect(range.a, acc.available.a),
                    s: intersect(range.s, acc.available.s),
                }
            }
        })

    ---
    {
        solution: sum(ruleCounts.counts),
        counts: ruleCounts
    }

}
