/**
* This module will be shared through your library, feel free to modify it as you please.
*
* You can try it out with the mapping on the src/test/dw directory.
*/
%dw 2.0
import some, sumBy from dw::core::Arrays

fun loadImage(filename) =
    readUrl("classpath://$(filename)", "text/plain")

fun parseSpaceMap(filename) = do {
    var originalMap = loadImage(filename) splitBy "\n"
    var emptyColumns = findEmptyColumns(originalMap)
    var emptyRows = findEmptyRows(originalMap)
    ---
    expandRows(
        originalMap map expandColumns($, emptyColumns),
        emptyRows)
}

fun findEmptyColumns(spaceMap) = do {
    var columnInfo = spaceMap[0] splitBy "" map (loc, col) -> {
        column: col,
        hasGalaxies: (spaceMap map (row) -> row[col]) some (point) ->
            point == "#"
    }
    ---
    columnInfo filter (! $.hasGalaxies) map $.column
}

fun findEmptyRows(spaceMap) = do {
    var rowInfo = spaceMap map (row, index) -> {
        row: index,
        hasGalaxies: row splitBy "" some (point) -> point == "#"
    }
    ---
    rowInfo filter (! $.hasGalaxies) map $.row
}

fun expandColumns(row, emptyColumns) = do {
    var expandedPoints = row splitBy "" 
        map (point, index) ->
            if (emptyColumns contains index)
                point ++ point
            else
                point
    ---
    expandedPoints joinBy ""
}

fun expandRows(spaceMap, emptyRows) =
    spaceMap flatMap (row, index) ->
        if (emptyRows contains index)
            [row, row]
        else
            row

fun findGalaxies(spaceMap) = do {
    var points = spaceMap flatMap (row, y) ->
        (row splitBy "") map (loc, x) -> {
            location: {
                x: x,
                y: y
            },
            occupant: loc
        }
    var galaxyPoints = points filter (point) -> point.occupant == "#"
    ---
    galaxyPoints map $.location
}

fun manhattanDistances(point, points) =
    points map (destination) ->
        manhattanDistance(destination, point)

fun manhattanDistance(p1, p2) =
    abs(p1.x - p2.x) + abs(p1.y - p2.y)

fun part1(galaxies) = do {
    var distances = (0 to sizeOf(galaxies) - 2) flatMap (galaxyNum) ->
        manhattanDistances(galaxies[galaxyNum], galaxies[(galaxyNum + 1) to -1])
    ---
    distances sumBy $
}

fun expandedPaths(filename, expansion) = do {
    var originalMap = loadImage(filename) splitBy "\n"
    var emptyColumns = findEmptyColumns(originalMap)
    var emptyRows = findEmptyRows(originalMap)
    var galaxies = findGalaxies(originalMap)
    var paths = (0 to sizeOf(galaxies) - 2) flatMap (galaxyNum) ->
        galaxies[(galaxyNum + 1) to -1] map (destination) ->
            {
                start: galaxies[galaxyNum],
                end: destination
            }

    ---
    paths map (path: Object) -> do {
        var apparentDistance = manhattanDistance(path.start, path.end)
        var westCol = min([path.start.x as Number, path.end.x as Number])
        var eastCol = max([path.start.x as Number, path.end.x as Number])
        var northRow = min([path.start.y as Number, path.end.y as Number])
        var southRow = max([path.start.y as Number, path.end.y as Number])
        var eastWestGaps = emptyColumns filter (emptyColumn) ->
                emptyColumn <= eastCol
                and
                emptyColumn >= westCol
        var northSouthGaps = emptyRows filter (emptyRow) ->
                emptyRow <= southRow
                and
                emptyRow >= northRow
        ---
        {
            path: path,
            columnGaps: sizeOf(eastWestGaps),
            rowGaps: sizeOf(northSouthGaps),
            apparentDistance: apparentDistance,
            realDistance: apparentDistance +
                (expansion - 1) * (sizeOf(eastWestGaps) + sizeOf(northSouthGaps))
        }
    }
}

fun part2(filename, expansion) = sum(
    expandedPaths(filename, expansion) map (path) ->
        path.realDistance
    )
