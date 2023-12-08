/**
* This module will be shared through your library, feel free to modify it as you please.
*
* You can try it out with the mapping on the src/test/dw directory.
*/
%dw 2.0
import fail from dw::Runtime
import * from dw::core::Arrays

fun parseNode(nodeText) = do {
    var node = nodeText splitBy " = "
    var source = node[0]
    var destinations = node[1] match /\((\w+), (\w+)\)/
    ---
    {
        (source): {
            L: destinations[1],
            R: destinations[2]
        }
    }
}

fun parseMaps(filename) = do {
    var docs = readUrl("classpath://$(filename)", "text/plain") splitBy "\n\n"
    var directions = docs[0]
    var nodes = docs[1] splitBy "\n"
    ---
    {
        directions: directions,
        nodes: {(nodes map parseNode($))}
    }
}

fun part2Target(start) = start[0 to 1] ++ "Z"

fun stepsFrom(maps, startLocation, cumulativeSteps=0) = 
    if (startLocation == null) fail("where is startLocation? $(cumulativeSteps)")
    else
    if (log(startLocation) == "ZZZ")
        cumulativeSteps
    else do {
        var nextDirectionIndex = cumulativeSteps mod sizeOf(maps.directions) 
        var nextDirection = maps.directions[nextDirectionIndex]
        var nextLocation = maps.nodes[startLocation][nextDirection]
        ---
        stepsFrom(maps, nextLocation, cumulativeSteps + 1)
    }
fun stepsToAnyZ(maps, startLocation, cumulativeSteps=0) = 
    if (startLocation == null) fail("where is startLocation? $(cumulativeSteps)")
    else
    if (startLocation endsWith "Z")
        cumulativeSteps
    else do {
        var nextDirectionIndex = cumulativeSteps mod sizeOf(maps.directions) 
        var nextDirection = maps.directions[nextDirectionIndex]
        var nextLocation = maps.nodes[startLocation][nextDirection]
        ---
        stepsToAnyZ(maps, nextLocation, cumulativeSteps + 1)
    }

//modified euclidean
fun gcd(a: Number, b: Number) =
    if (b == 0) a
        else gcd(b, a mod b)
fun lcm(a: Number, b: Number) =
        (a / gcd(a, b)) * b

fun badGhostStepsFrom(maps, startLocations, cumulativeSteps = 0) =
    // if (startLocations == null) fail("where is startLocation? $(cumulativeSteps)")
    // else
    if (log(startLocations) every (location) -> location endsWith "Z")
        cumulativeSteps
    else do {
        var nextDirectionIndex = cumulativeSteps mod sizeOf(maps.directions) 
        var nextDirection = maps.directions[nextDirectionIndex]
        var nextLocations = startLocations map (location) ->
            maps.nodes[location default "bug"][nextDirection]
        ---
        badGhostStepsFrom(maps, nextLocations, cumulativeSteps + 1)
    }
