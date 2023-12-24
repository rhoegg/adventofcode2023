%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings

type Point = {
    x: Number,
    y: Number
}

fun move(pos: Point, direction: String): Point =
    direction match {
        case "north" -> { x: pos.x - 1, y: pos.y }
        case "east" -> { x: pos.x + 1, y: pos.y }
        case "south" -> {x: pos.x, y: pos.y - 1 }
        case "west" -> {x: pos.x, y: pos.y + 1 }
    }

fun load(filename) =
    readUrl("classpath://$(filename)", "text/plain")

fun parseGarden(filename) = do {
    var plots = lines(load(filename))
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
