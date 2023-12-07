/**
* This module will be shared through your library, feel free to modify it as you please.
*
* You can try it out with the mapping on the src/test/dw directory.
*/
%dw 2.0
import * from dw::core::Strings

var racesData = readUrl("classpath://puzzleInput.txt", "text/plain")
    splitBy "\n"

var raceResults = do {
    var times = words(racesData[0] substringAfter "Time: ")
    var distances = words(racesData[1] substringAfter "Distance: ")
    ---
    times zip distances
        map (pair) -> {
            time: pair[0] as Number,
            recordDistance: pair[1] as Number
        }
}

var raceOptions = raceResults map (raceResult) ->
    raceResult ++ {
        options: (0 to raceResult.time) map (buttonTime) -> do {
            var duration = raceResult.time - buttonTime
            var speed = buttonTime
            ---
            {
                duration: duration,
                speed: speed,
                distance: duration * speed
            }
        }
    }

var part2raceResults = do {
    var times = words(racesData[0] substringAfter "Time: ")
    var distances = words(racesData[1] substringAfter "Distance: ")
    ---
    {
        time: (times joinBy "") as Number,
        distance: (distances joinBy "") as Number
    }
}

// range is zeros of a quadratic equation
// n(t-n) = d
// tn - n^2 - d = 0
// n^2 - tn + d = 0
fun winningRange(result) = do {
    var discriminant = (result.time pow 2) - (4 * result.distance)
    var lowerBound = (result.time - sqrt(discriminant)) / 2
    var upperBound = (result.time + sqrt(discriminant)) / 2
    ---
    {
        lower: ceil(lowerBound),
        upper: floor(upperBound),
    } then (range) -> range ++ {
        size: range.upper - range.lower + 1
    }
    
}

fun countWinningOptions(race) =
    sizeOf(
        race.options filter (option) ->
            option.distance > race.recordDistance
    )