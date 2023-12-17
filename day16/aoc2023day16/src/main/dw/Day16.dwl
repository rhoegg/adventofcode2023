/**
* This module will be shared through your library, feel free to modify it as you please.
*
* You can try it out with the mapping on the src/test/dw directory.
*/
%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings

type Point = {
    x: Number,
    y: Number
}

fun load(filename) = readUrl("classpath://$(filename)", "text/plain")

fun loadContraption(filename) = {
    contraption: lines(load(filename)),
    beams: [
        {
            location: {
                x: 0,
                y: 0
            },
            direction: "right"
        }
    ],
    visited: [
        {
            location: {
                x: 0,
                y: 0
            },
            direction: "right"
        }
    ]
}

fun part1Data(filename) = do {
    var state = loadContraption(filename)
    ---
    {
        start: state,
        // oneStep: advanceContraptionState(state),
        atEnd: advanceToComplete(state)
    }
}

fun advanceToComplete(contraptionState) = do {
    var next = advanceContraptionState(contraptionState)
    var nextValid = removeOutOfBounds(next) update {
        case beams at .beams -> beams filter (beam) ->
            contraptionState.visited every (visit) ->
                visit != beam
    }
    ---
    if (isEmpty(nextValid.beams))
        nextValid
    else
        advanceToComplete(nextValid)
}

fun contents(contraption: Array<String>, location: Point): String =
    contraption[location.y][location.x]

fun advanceContraptionState(contraptionState) = do {
    var newBeams = contraptionState.beams flatMap (beam) -> do {
        var encounteredObject = contraptionState.contraption contents beam.location
        var keepGoing = {
            location: beam.location move beam.direction,
            direction: beam.direction
        }
        ---
        encounteredObject match {
            case "." -> [keepGoing]
            case "/" -> [ do {
                var newDirection = beam.direction match {
                    case "left" -> "down"
                    case "right" -> "up"
                    case "up" -> "right"
                    case "down" -> "left"
                }
                ---
                {
                    location: beam.location move newDirection,
                    direction: newDirection
                }
            }]
            case "\\" -> [ do {
                var newDirection = beam.direction match {
                    case "left" -> "up"
                    case "right" -> "down"
                    case "up" -> "left"
                    case "down" -> "right"
                }
                ---
                {
                    location: beam.location move newDirection,
                    direction: newDirection
                }
            }]
            case "|" -> do {
                var splits = ["up", "down"] map (newDirection) -> {
                    location: beam.location move newDirection,
                    direction: newDirection
                }
                ---
                beam.direction match {
                    case "left" -> splits
                    case "right" -> splits
                    case "up" -> [keepGoing]
                    case "down" -> [keepGoing]
                }
            }
            case "-" -> do {
                var splits = ["left", "right"] map (newDirection) -> {
                    location: beam.location move newDirection,
                    direction: newDirection
                }
                ---
                beam.direction match {
                    case "left" -> [keepGoing]
                    case "right" -> [keepGoing]
                    case "up" -> splits
                    case "down" -> splits
                }
            }
        }
    }
    ---
    {
        contraption: contraptionState.contraption,
        beams: newBeams,
        visited: contraptionState.visited ++ newBeams
    }
}

fun move(pos: Point, direction: String): Point =
    direction match {
        case "left" -> { x: pos.x - 1, y: pos.y }
        case "right" -> { x: pos.x + 1, y: pos.y }
        case "up" -> {x: pos.x, y: pos.y - 1 }
        case "down" -> {x: pos.x, y: pos.y + 1 }
    }

fun removeOutOfBounds(contraptionState) = do {
    fun inBounds(loc) = 
        loc.x >= 0
        and
        loc.y >= 0
        and
        loc.x < sizeOf(contraptionState.contraption[0])
        and
        loc.y < sizeOf(contraptionState.contraption)
    ---
    contraptionState  update {
        case beams at .beams -> beams filter (beam) -> inBounds(beam.location)
        case visited at .visited -> visited filter (loc) -> inBounds(loc.location)
    }
}

fun energized(contraptionState) = do {
    var visited = contraptionState.visited 
        distinctBy $.location 
            map $.location
    ---
    contraptionState.contraption map (line: String, y) ->
        line mapString (c, x) -> 
            if (visited contains {x: x, y: y}) "#" 
            else "."
}

fun part2Starts(contraptionState) = ["right", "up", "left", "down"] flatMap (direction) -> 
        direction match {
            case "right" -> (0 to sizeOf(contraptionState.contraption) - 1) map (y) -> {
                location: {
                    x: 0,
                    y: y
                },
                direction: direction
            }
            case "up" -> (0 to sizeOf(contraptionState.contraption[0]) - 1) map (x) -> {
                location: {
                    x: x,
                    y: sizeOf(contraptionState.contraption) - 1
                },
                direction: direction
            }
            case "left" -> (0 to sizeOf(contraptionState.contraption) - 1) map (y) -> {
                location: {
                    x: sizeOf(contraptionState.contraption[0]) - 1,
                    y: y
                },
                direction: direction
            }
            case "down" -> (0 to sizeOf(contraptionState.contraption[0]) - 1) map (x) -> {
                location: {
                    x: x,
                    y: 0
                },
                direction: direction
            }
        }