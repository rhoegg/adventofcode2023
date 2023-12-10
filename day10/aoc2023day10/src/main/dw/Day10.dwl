/**
* This module will be shared through your library, feel free to modify it as you please.
*
* You can try it out with the mapping on the src/test/dw directory.
*/
%dw 2.0
import firstWith, indexWhere, sumBy from dw::core::Arrays

fun load(filename) = 
    readUrl("classpath://$(filename)", "text/plain")

fun tiles(text) = do {
    var lines = text splitBy "\n"
    ---
    lines
}

fun findStart(tiles) = do {
    var y = tiles indexWhere (row) ->
        row contains "S"
    var x = tiles[y] indexOf "S"
    ---
    {
        x: x,
        y: y
    }
}

var directions = ("0" to "3") map $ as String
fun oppositeDirection(direction) = 
    (direction as Number + 2 mod 4) as String

/**
* Gives connections for a tile, in a string containing numerals between 0 and 3
* North: 0
* East: 1
* South: 2
* West: 3
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `tile` | String | The tile as described in the challenge
* |===
*
*/
fun connections(tile) = tile match {
    case "|" -> "02"
    case "-" -> "13"
    case "L" -> "01"
    case "J" -> "03"
    case "7" -> "23"
    case "F" -> "12"
    else -> ""
}

fun tileAt(tileMap, pos) =
    tileMap[pos.y][pos.x]

fun move(pos, direction) = direction match {
    case "0" -> {
        x: pos.x,
        y: pos.y - 1
    }
    case "1" -> {
        x: pos.x + 1,
        y: pos.y
    }
    case "2" -> {
        x: pos.x,
        y: pos.y + 1
    }
    case "3" -> {
        x: pos.x - 1,
        y: pos.y
    }
}

fun firstStep(tileMap, pos) = do {
    directions firstWith (direction) -> do {
        var nextPos = pos move direction
        var tile = tileMap tileAt nextPos
        var c = connections(tile)
        ---
        c contains oppositeDirection(direction)
    }
}

fun nextStep(tileMap, pos, from) = do {
    var nextConnections = connections(tileMap tileAt pos)
    ---
    if (nextConnections[0] == from)
        nextConnections[1]
    else
        nextConnections[0]
}

fun distanceToStart(tileMap, steps, pos, from) = do {
    var nextDirection = nextStep(tileMap,
        pos,
        oppositeDirection(from))
    var nextPos = pos move nextDirection
    var nextTile = tileMap tileAt nextPos
    ---
    if (nextTile == "S")
        steps + 1
    else
        distanceToStart(tileMap, steps + 1, nextPos, nextDirection)    
}

fun pathToStart(tileMap, path, pos, from) = do {
    var nextDirection = nextStep(tileMap,
        pos,
        oppositeDirection(from))
    var nextPos = pos move nextDirection
    var nextTile = tileMap tileAt nextPos
    ---
    if (nextTile == "S")
        path << nextPos
    else
        pathToStart(tileMap, path << nextPos, nextPos, nextDirection)
}

// top corners don't count for even odd raycasting
fun isHorizontalEdge(tileMap, pos) = do {
    var tile = tileMap tileAt pos
    var northPos = pos move "0"
    var southPos = pos move "2"
    var northTile = tileMap tileAt northPos
    var thisConnections = connections(tile)
    var northConnections = connections(tileMap tileAt northPos)
    var southConnections = connections(tileMap tileAt southPos)
    ---
    if (northTile == "S") false
    else (tile == "-")
        or
        (tile == "S")
        or (
            ((southConnections contains "0") and (thisConnections contains "2"))
            and
            (! (northConnections contains "2") or (! (thisConnections contains "0")))
        ) 
}

// even odd raycasting to find enclosed points
fun countEnclosed(tileMap, loopPath) = do {
    var rows = tileMap map (row, y) ->
        (row splitBy "") map (tile, x) ->
            {
                pos: {
                    x: x,
                    y: y
                },
                tile: tile,
                loop: loopPath contains {
                    x: x,
                    y: y
                }
            }
    var rayCasts = rows map (row, index) ->
        row reduce (point, status = {
            x: 0,
            enclosed: 0,
            crossings: 0
        }) -> log("row $(index)", {
            x: status.x + 1,
            enclosed: status.enclosed +
                if ((status.crossings mod 2) == 1 and ! point.loop)
                    1
                else
                    0,
            crossings: status.crossings + 
                if (log(point).loop and (! log(isHorizontalEdge(tileMap, point.pos))))
                    1
                else
                    0
        })
    ---
    rayCasts sumBy $.enclosed
}
    