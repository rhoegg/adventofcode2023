%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings

var sample1 = readUrl("classpath://sample1.txt", "text/plain") as String
var puzzleInput = readUrl("classpath://puzzleInput.txt", "text/plain") as String
var parts = sample1 splitBy "\n\n"
var seeds = parts[0] substringAfter "seeds: " 
    splitBy " " 
    map $ as Number
var part2seeds = do {
    var pairs = seeds divideBy 2
    var ranges = pairs map (pair) -> do {
        var start = pair[0]
        var length = pair[1]
        ---
        (start to start + length - 1) as Array
    }
    ---
    flatten(ranges)
}

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
        chosenRange ++ {sourceNumber: sourceNumber,
            mapped: sourceNumber - chosenRange.source + chosenRange.destination
        } 
    }
fun convert(source, conversionMap) =
    conversion(source, conversionMap).mapped