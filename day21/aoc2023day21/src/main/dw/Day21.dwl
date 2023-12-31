%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings
import * from dw::core::Objects

type Point = {
    x: Number,
    y: Number
}

fun pointName(p: Point): String = "$(p.x),$(p.y)"

type Tile = {
    position: Point,
    reached: Array<Point>,
    startDistance: Number
}

fun move(pos: Point, direction: String): Point =
    direction match {
        case "north" -> { x: pos.x - 1, y: pos.y }
        case "east" -> { x: pos.x + 1, y: pos.y }
        case "south" -> {x: pos.x, y: pos.y - 1 }
        case "west" -> {x: pos.x, y: pos.y + 1 }
    }

fun combineTiles(tiles: Array<Tile>): Array<Tile> = do {
    var grouped = tiles groupBy (t) -> pointName(t.position)
    ---
    grouped pluck (samePositionTiles) -> {
        position: samePositionTiles[0].position,
        reached: flatten(samePositionTiles map $.reached) distinctBy $,
        startDistance: max(samePositionTiles map $.startDistance) as Number
    }
}

fun load(filename) =
    readUrl("classpath://$(filename)", "text/plain")

fun parseGarden(filename): {plots: Array<String>, start: Point} = do {
    var plots: Array<String> = lines(load(filename)) as Array<String>
    var startLine = 
        (plots map (line, y) -> { y: y, line: line })
            firstWith (lineInfo) -> lineInfo.line contains "S"
    var start: Point = {
        x: (startLine.line splitBy "") as Array indexOf "S",
        y: startLine.y as Number
    }
    ---
    {
        plots: plots,
        start: start
    }
}

fun printTile(garden: Array<String>, t: Tile): String = do {
    var header = "Tile $(pointName(t.position))"
    fun printLine(line: String, y: Number): String =
        (
            (line splitBy "") map (c, x) ->
                if (t.reached contains {x: x, y: y}) "O" else c
        ) joinBy ""
    ---
    (garden map (line, y) -> printLine(line, y)) joinBy "\n"
}

fun part2Start(p: Point, distance: Number): Array<Tile> = [
    {
        position: {x: 0, y: 0},
        reached: [p],
        startDistance: distance
    }
]

fun gardenStep(garden: Array<String>, from: Array<Point>): Array<Point> = do {
    // flatMap froms to possible tos
   var possibles = from flatMap (position) ->
        ["north", "east", "south", "west"] map (dir) ->
            move(position, dir)
    ---
    possibles filter (p) -> garden[p.y][p.x] != "#"
}
 
fun gardenWalk(garden: Array<String>, start: Point, distance: Number): Array<Point> = do {
    var finalState = (1 to distance) reduce (i, acc={positions: [start]}) ->
        {
            positions: gardenStep(garden, acc.positions) distinctBy $
        }
    ---
    finalState.positions
}

fun infiniteGardenWalk(env: {garden: Array<String>, cache: Object}, fromTiles: Array<Tile>, distance: Number): Array<Tile> = do {
    if (distance == 0) do {
        var forlog = log("cache size", sizeOf(env.cache))
        ---
        fromTiles
    }
    else do {
        // var forlog = if (distance > 4) log("cache size $(distance), tiles: ", sizeOf(fromTiles))
        //     else log(printTile(env.garden, fromTiles[0]))
        var width = sizeOf(env.garden[0])
        var height = sizeOf(env.garden)
        var oneStep = fromTiles reduce (fromTile: Tile, acc = {cache: env.cache, tiles: []}) -> do {
            var starts = fromTile.reached orderBy $.y orderBy $.x
            // memoize gardenStep
            // possibly can also memoize number of steps for a tile given starting pos
            var cacheKey = (starts map pointName($)) joinBy " "
            // var forlog = if (acc.cache[cacheKey] == null) log("cache miss", 0) else log("cache hit", 0)
            var advancePoints = acc.cache[cacheKey] default do {
                var nexts = (gardenStep(env.garden, starts) distinctBy $)
                var tiledPoints = {
                    here: nexts filter (p) -> 
                        p.x >= 0 and p.y >= 0 
                        and 
                        p.x < width and p.y < height,
                    north: nexts filter (p) -> p.y < 0,
                    south: nexts filter (p) -> p.y >= height,
                    east: nexts filter (p) -> p.x >= width,
                    west: nexts filter (p) -> p.x < 0
                }
                ---
                tiledPoints mapObject (points, direction) ->
                {
                    (direction): points map (p) -> {
                        x: (width + p.x) mod width,
                        y: (height + p.y) mod height
                    }
                }
            }
            var newTiles = advancePoints pluck (reached: Array<Point>, tilePosition: Point): Tile -> {
                position: tilePosition match {
                    case "here" -> fromTile.position
                    case "north" -> {x: fromTile.position.x, y: fromTile.position.y - 1}
                    case "south" -> {x: fromTile.position.x, y: fromTile.position.y + 1}
                    case "east" -> {x: fromTile.position.x + 1, y: fromTile.position.y}
                    case "west" -> {x: fromTile.position.x - 1, y: fromTile.position.y}
                },
                reached: reached,
                startDistance: 
                    if (tilePosition == "here") fromTile.startDistance
                    else distance
            }
            ---
            {
                cache: acc.cache mergeWith {
                    (cacheKey): advancePoints
                },
                tiles: acc.tiles ++ (newTiles filter (t) -> (! isEmpty(t.reached)))
            }
        }
        var nextEnv = env mergeWith {
            cache: oneStep.cache
        }
        ---
        infiniteGardenWalk(nextEnv, combineTiles(oneStep.tiles), distance - 1)
    }
}

fun part2Counts(garden, distance: Number) = do {
    var tiles = infiniteGardenWalk({garden: garden.plots, cache: {}}, part2Start(garden.start, distance), distance)
    ---
    {
        tiles: sizeOf(tiles),
        reached: sizeOf(flatten(tiles map $.reached))
    }
}

fun part2Expansion(garden) = do {
    var steps = (0 to 2) map (n) -> ceil(n * sizeOf(garden.plots) + (sizeOf(garden.plots)/2))
    var stepCounts = steps map (n) -> part2Counts(garden, n).reached
    var reachableIncreases = (stepCounts zip stepCounts[1 to -1]) map (pair) ->
        pair[1] - pair[0]
    ---
    {
        reachableCounts: stepCounts,
        firstDerivative: reachableIncreases,
        secondDerivative: (reachableIncreases zip reachableIncreases[1 to -1]) map (pair) ->
            pair[1] - pair[0]
    }
}

fun findStablePatternStep(garden) = findStablePatternStep(garden, null, [])
fun findStablePatternStep(garden, currentPositions, history) = do {
    var starts = currentPositions default [garden.start]
    var next = gardenStep(garden.plots, starts) distinctBy $
    var nextMap = printTile(garden.plots, {position: {x: 0, y: 0}, reached: next, startDistance: 100})
    ---
    if (sizeOf(history) > 3 and (history contains nextMap)) {
        steps: sizeOf(history),
        lastFew: history[-3 to -1] map ($ splitBy "\n")
    }
    else if (sizeOf(history) > 50) do {
        var forlog1 = log(0)
        ---
        { steps: 50, canceled: true }
    }
    else findStablePatternStep(garden, next, history << nextMap)
}