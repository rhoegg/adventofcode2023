/**
* This module will be shared through your library, feel free to modify it as you please.
*
* You can try it out with the mapping on the src/test/dw directory.
*/
%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings
import * from dw::core::Objects

fun parseConditionRecords(filename) = do {
    var lines = readUrl("classpath://$(filename)", "text/plain") splitBy "\n"
    ---
    lines map (line) -> do {
        var parts = line splitBy " "
        ---
        {
            conditionRecord: parts[0],
            damagedGroups: parts[1] splitBy "," map $ as Number
        }
    }
}

fun parseConditionRecordsFolded(filename) = parseConditionRecords(filename) map (conditionRecord) -> {
    conditionRecord: ((1 to 5) map conditionRecord.conditionRecord) joinBy "?",
    damagedGroups: (1 to 5) flatMap conditionRecord.damagedGroups
}

fun damageGroupSizes(candidateConditionRecord) =
    candidateConditionRecord splitBy "." 
        filter (! isEmpty($))
            map sizeOf($)

//TODO: part 2 rewrite with memoize - need two params: remaining condition record, and remaining group sizes
fun possibleArrangements(conditionRecord, damagedGroups) =
    allArrangements([conditionRecord], damagedGroups) filter (candidate) -> 
        damageGroupSizes(candidate) == damagedGroups


fun part2CacheKey(target, prefix, suffix) = do {
    var relevantPrefix = prefix substringAfterLast '.'
    ---
    "$(target joinBy ',')|$(relevantPrefix)$(suffix)"
}

fun countMatchingArrangements(target: Array<Number>, cache: Object, prefix: String, suffix: String) = do {
    cache[log(part2CacheKey(target, prefix, suffix))] default 
    if (isEmpty(suffix remove '.'))
        if (target == damageGroupSizes(prefix)) 1 else 0
    else if (prefix contains repeat("#", max(target) as Number + 1))
        // prune prefixes that already contain invalid groups
        0
    else do {
        var chunkEnd = ((suffix find "?")[1] default sizeOf(suffix)) - 1
        var chunk = suffix[0 to chunkEnd]
        var nextPrefixes = [ // new values of prefix, both ways
            prefix ++ chunk replace '?' with '.',
            prefix ++ chunk replace '?' with '#'
        ]
        var newSuffix = suffix[chunkEnd + 1 to -1] default '' // remainder after chunks removed
        var damageArrangements = countMatchingArrangements(target, cache, nextPrefixes[0], log(nextPrefixes[0], newSuffix))
        var newCache = cache ++ { (part2CacheKey(target, nextPrefixes[0], newSuffix)): damageArrangements }
        ---
        // watch out for tail recursion here? chunking might have shrunk stack depth enough
        damageArrangements
        + countMatchingArrangements(target, newCache, nextPrefixes[1], newSuffix)
    }
}

fun allArrangements(conditionRecords, damagedGroups) =
    if (conditionRecords every (conditionRecord) -> ! (conditionRecord contains "?"))
        conditionRecords
    else 
        allArrangements(
            (conditionRecords) flatMap (conditionRecord) -> do {
                if (conditionRecord contains "?")
                    [
                        (conditionRecord substringBefore "?") ++ "." ++ (conditionRecord substringAfter "?"),
                        (conditionRecord substringBefore "?" ++ "#" ++ (conditionRecord substringAfter "?"))
                    ]
                else [conditionRecord]
            } filter (candidate) -> do {
                    var qualifier = (candidate ++ "?") substringBefore "?"
                    var qualifierGroups = damageGroupSizes(qualifier)
                    var compareGroups = if (qualifier endsWith "#")
                            qualifierGroups[0 to -2] default []
                        else qualifierGroups
                    ---
                    // groups so far are ok
                    compareGroups zip damagedGroups every $[0] == $[1]
                    and
                    // prune the combinations that create oversized damage groups
                    ! (candidate contains repeat("#", max(damagedGroups) as Number + 1))
                    // TODO: prune the candidates with too many groups of each size
                    // and
                    // allGroupSizeCountsAreSmaller(qualifierGroups, damagedGroups)
                }
            , damagedGroups)

fun allGroupSizeCountsAreSmaller(g1, g2) = do {
    var g1Sizes = g1 groupBy $ mapObject (members, size) ->
        { (size): sizeOf(members) }
    var g2Sizes = g2 groupBy $ mapObject (members, size) ->
        { (size): sizeOf(members) }
    ---
    g1Sizes everyEntry (count, size) -> count <= (g2Sizes[size] default 0)
}

fun part1(filename) = do {
    var arrangements = parseConditionRecords(filename) map (parsedRecord) -> {
        record: parsedRecord.conditionRecord,
        items: possibleArrangements(parsedRecord.conditionRecord, parsedRecord.damagedGroups)
    }
    ---
    {
        items: arrangements map $.items,
        solution: sum(arrangements map log($.record, sizeOf($.items)))
    }
    
}

fun part2(filename) = do {
    var arrangementCounts = parseConditionRecordsFolded(log("part2 starting ", filename))
        map (parsedRecord) ->
            countMatchingArrangements(parsedRecord.damagedGroups, {}, "", log("starting", parsedRecord.conditionRecord))
    ---
    arrangementCounts
}