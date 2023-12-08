/**
* This module will be shared through your library, feel free to modify it as you please.
*
* You can try it out with the mapping on the src/test/dw directory.
*/
%dw 2.0

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

fun stepsFrom(maps, startLocation, cumulativeSteps=0) = 
    if (startLocation == "ZZZ")
        cumulativeSteps
    else do {
        var nextDirectionIndex = cumulativeSteps mod sizeOf(maps.directions) 
        var nextDirection = maps.directions[nextDirectionIndex]
        var nextLocation = maps.nodes[log(startLocation)][nextDirection]
        ---
        stepsFrom(maps, nextLocation, cumulativeSteps + 1)
    }

