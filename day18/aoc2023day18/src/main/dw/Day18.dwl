%dw 2.0
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

fun loadDigPlan(filename: String): Array<Instruction> = do {
    var data = readUrl("classpath://$(filename)", "text/plain") as String
    ---
    lines(data) map (line) -> parseInstruction(line)
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
        
fun measureArea(lagoonTrench: Array<DigAction>) = do {
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
