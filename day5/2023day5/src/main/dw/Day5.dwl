%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings

var sample1 = readUrl("classpath://sample1.txt", "text/plain") as String
var puzzleInput = readUrl("classpath://puzzleInput.txt", "text/plain") as String
var parts = puzzleInput splitBy "\n\n"
var seeds = parts[0] substringAfter "seeds: " 
    splitBy " " 
    map $ as Number

fun parseMap(mapText) = do {
    var lines = mapText splitBy "\n"
    ---
    {
        name: lines[0] substringBeforeLast " map:",
        ranges: lines drop 1 map (line) -> do {
            var tokens = line splitBy " "
            ---
            {
                destination: tokens[0] as Number,
                source: tokens[1] as Number,
                length: tokens[2] as Number
            }
        }
    }
}

var conversionMaps = parts drop 1 map parseMap($)

fun conversion(source, conversionMap) =
    source map (sourceNumber) ->  do {
        var matchedRange = conversionMap.ranges firstWith (range) ->
            sourceNumber >= range.source and
                sourceNumber < range.source + range.length
        var chosenRange = matchedRange default {
            destination: sourceNumber,
            source: sourceNumber,
            length: 1
        }
        ---
        chosenRange ++ {
            sourceNumber: sourceNumber,
            mapped: sourceNumber - chosenRange.source + chosenRange.destination
        } 
    }

fun reverseConversion(destination, conversionMap) =
    destination map (destinationNumber) ->  do {
        var matchedRange = conversionMap.ranges firstWith (range) ->
            destinationNumber >= range.destination and
                destinationNumber < range.destination + range.length
        var chosenRange = matchedRange default {
            destination: destinationNumber,
            source: destinationNumber,
            length: 1
        }
        ---
        chosenRange ++ {
            destinationNumber: destinationNumber,
            mapped: destinationNumber - chosenRange.destination + chosenRange.source
        } then ($.mapped)
    }

fun convert(source, conversionMap) =
    conversion(source, conversionMap).mapped

fun part2RelevantInputs(range) =
    range.ranges flatMap (range) ->
            [range.source, range.source + range.length - 1]

var part2RelevantSeeds = do {
    var relevantInputs = conversionMaps[-1 to 0] reduce (conversionMap, destinations = []) ->
        part2RelevantInputs(conversionMap) ++ reverseConversion(destinations, conversionMap)
    var seedRanges = seeds divideBy 2 map {
        min: $[0],
        max: $[0] + $[1] - 1
    }
    ---
    relevantInputs filter (candidate) ->
        seedRanges some (seedRange) ->
            candidate >= seedRange.min and candidate <= seedRange.max
            
    
}
