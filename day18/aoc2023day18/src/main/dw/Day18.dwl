%dw 2.0
import * from dw::core::Arrays
import fromHex from dw::core::Numbers
import * from dw::core::Strings

type Instruction = {
    direction: String,
    distance: Number,
    color: String
}

type DigAction = {
    direction: String,
    color: String,
    point: Point,
    ordinal?: String
}

type Point = {
    x: Number,
    y: Number
}

type Segment = {
    begin: Point,
    end: Point
}

// defining down as positive and right as positive
fun move(location: Point, direction, distance: Number=1) = do {
    direction match {
        case "R" -> location update {
            case x at .x -> x + distance
        }
        case "L" -> location update {
            case x at .x -> x - distance
        }
        case "U" -> location update {
            case y at .y -> y - distance
        }
        case "D" -> location update {
            case y at .y -> y + distance
        }
    }
}

var origin = {x: 0, y: 0}

fun parseInstruction(line: String): Instruction = do {
    var parts = line splitBy " "
    ---
    {
        direction: parts[0],
        distance: parts[1] as Number,
        color: parts[2][1 to -2]
    }
}

fun parseInstruction2(line: String): Instruction = do {
    var parts = line splitBy " "
    var color = parts[2][1 to -2]
    ---
    {
        direction: color[-1] match {
            case "0" -> "R"
            case "1" -> "D"
            case "2" -> "L"
            case "3" -> "U"
            else -> ""
        },
        distance: fromHex(color[1 to -2]),
        color: color
    }
}

fun loadDigPlan(filename: String): Array<Instruction> = do {
    var data = readUrl("classpath://$(filename)", "text/plain") as String
    ---
    lines(data) map (line) -> parseInstruction(line)
}

fun loadDigPlanPart2(filename: String): Array<Instruction> = do {
    var data = readUrl("classpath://$(filename)", "text/plain") as String
    ---
    lines(data) map (line) -> parseInstruction2(line)
}

fun plotTrench(digPlan: Array<Instruction>): Array<DigAction> =
    digPlan reduce (instruction, path=[]) -> do {
        var last = path[-1].point default origin
        ---
        path ++ (
            (0 to instruction.distance) map (distance) -> {
                direction: instruction.direction,
                color: instruction.color,
                point: move(last, instruction.direction, distance),
                ordinal: if (distance == 0) "first"
                    else if (distance == instruction.distance) "last"
                    else "middle"
            }
        )
    }
        
fun measureAreaLaboriouslySlow(lagoonTrench: Array<DigAction>) = do {
    var minCorner = {
        x: min(lagoonTrench map $.point.x) default 0,
        y: min(lagoonTrench map $.point.y) default 0
    }
    var maxCorner = {
        x: max(lagoonTrench map $.point.x) default 0,
        y: max(lagoonTrench map $.point.y) default 0
    }
    var edgeActions = lagoonTrench filter (action) ->
        (["D", "U"] contains action.direction)
        and
        (! (action.direction == "D" and action.ordinal == "first"))
        and
        (! (action.direction == "U" and action.ordinal == "last"))
    var edgePoints = edgeActions map $.point
    var lagoonPoints = (minCorner.y to maxCorner.y) as Array flatMap (y) -> do {
        var filled = (minCorner.x to maxCorner.x) reduce (x, acc={crossed: 0, excavated: []}) -> do {
            // line crossing interior detection
            var p = {x: x, y: y}
            ---
            if (edgePoints contains p)
                {
                    crossed: acc.crossed + 1,
                    excavated: acc.excavated << log("edge", p)
                }
            // TODO: add non-edge trench points
            else if ((lagoonTrench map $.point) contains p)
                {
                    crossed: acc.crossed,
                    excavated: acc.excavated << log("trench", p)
                }
            else 
                {
                    crossed: acc.crossed,
                    excavated:
                        if ((acc.crossed mod 2) == 1) // interior
                            acc.excavated << log("interior", p)
                        else                          // exterior
                            acc.excavated

                }
        }
            
        ---
        filled.excavated
    }
    ---
    lagoonPoints
}

fun measureAreaEvenOddWithSegments(instructions: Array<Instruction>) = do {

    var s = segments(instructions) partition (segment) ->
        (segment.begin.y == segment.end.y)
    var horizontalSegments = s.success
    var verticalSegments = s.failure orderBy $.begin.y
    var verticalPositions = verticalSegments map $.begin.y distinctBy $ orderBy $
    var verticalChunks = verticalPositions zip verticalPositions[1 to -1]
    ---
    // try with rectangles
    // start with segment (x1,y1),(x1,y2)
    verticalChunks reduce (yLimits, acc = {limit: [], rectangles: []}) -> do {
        // scan only x values where segment at x intersects y2
        var collisionSegments = (verticalSegments filter (s) -> s includesY yLimits[1])
            orderBy ($.begin.x)
        
        ---
        {
            limit: acc.limit << yLimits[1],
            rectangles: acc.rectangles << (collisionSegments zip collisionSegments[1 to -1])
        }
        // odd rectangles count (interior), even rectangles don't (exterior)
        // keep rectangles around so we can account for segment overlap before computing area
    }
}

fun measureAreaShoelace(instructions: Array<Instruction>) = do {
    var vertices = segments(instructions) map $.begin
    var withPrevious = vertices zip shiftForward(vertices) map (pair) ->
        {
            vertex: pair[0],
            previous: pair[1]
        }
    var withNext = withPrevious zip shiftBackward(vertices) map (pair) ->
        pair[0] ++ {
            next: pair[1]
        }
    var shoelaceSum = sum(withNext map (v) -> (v.vertex.x * ((v.next.y default 0) - v.previous.y)))
    // shoelace algorithmproduces doubled area if counterclockwise, or negative doubled area if clockwise
    var shoelaceArea = log("shoelace", abs(shoelaceSum) / 2)
    // have to account for perimeter, assume clockwise direction
    // var directions = instructions map $.direction
    // var corners = (directions zip shiftBackward(directions)) map ($[0] ++ $[1])
    // var lefts = segments(instructions filter ($.direction == "L"))
    // var downs = segments(instructions filter ($.direction == "D"))
    // var leftArea = sum(lefts map length($)-1)
    // var downArea = sum(downs map length($)-1)
    // var cornerCount = sizeOf(corners filter (c) -> ["RD", "DL", "LD", "LU"] contains c)
    // the long way around above would have worked! segments has an off by one error for perimeter
    // var perimeter = log("perimeter", sum(segments(instructions) map length($))) //wrong, 63!
    
    var perimeter = log("perimeter", sum(instructions map $.distance))
    var picksInterior = shoelaceArea - (perimeter / 2) + 1
    ---
    // shoelaceArea + leftArea + downArea + cornerCount// off by one for puzzle input! AARGH!
    perimeter + picksInterior
}

fun segments(digPlan: Array<Instruction>): Array<Segment> =
    digPlan reduce (instruction, path=[]) -> do {
        var last = path[-1].end default origin
        ---
        path << {
            begin: last,
            end: move(last, instruction.direction, instruction.distance)
        }
    }

fun normalizeSegment(s: Segment): Segment =
    if (s.begin.y < s.end.y or s.begin.x < s.end.x) s
    else {
        begin: s.end,
        end: s.begin
    }

fun includesY(verticalSegment: Segment, y: Number): Boolean = do {
    var normalized = normalizeSegment(verticalSegment)
    ---
    // exclude top vertex and include bottom
    normalized.begin.y < y 
        and normalized.end.y >= y
}

fun shiftForward<ItemType>(items: Array<ItemType>): Array<ItemType> =
    items[-1] >> items[0 to -2]

fun shiftBackward<ItemType>(items: Array<ItemType>): Array<ItemType> =
    items[1 to -1] << items[0]

fun length(s: Segment) =
    abs((s.begin.x - s.end.x + 1) * (s.begin.y - s.end.y + 1))