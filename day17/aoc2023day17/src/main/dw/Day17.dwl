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

type PathState = {
    location: Point,
    direction: String,
    trail?: Array<PathState>,
    straightSteps: Number,
    heatLoss: Number
}

type GearIsland = {
    map: Array<String>,
    factory: Point
}

fun load(filename) = readUrl("classpath://$(filename)", "text/plain")

fun gearIsland(filename: String): GearIsland = do { 
    var rows = lines(load(filename)) as Array<String>
    ---
    {
        map: rows,
        factory: {
            x: sizeOf(rows[0]) - 1,
            y: sizeOf(rows) - 1
        }
    }
}

fun move(location: Point, direction, distance=1) = do {
    direction match {
        case "east" -> location update {
            case x at .x -> x + distance
        }
        case "west" -> location update {
            case x at .x -> x - distance
        }
        case "north" -> location update {
            case y at .y -> y - distance
        }
        case "south" -> location update {
            case y at .y -> y + distance
        }
    }
}

fun fromLavaPool(): PathState = {
    location: { x: 0, y: 0 },
    direction: "start",
    trail: [],
    straightSteps: 0,
    heatLoss: 0
}

fun findLowestHeatLossPathToFactory(gearIsland: GearIsland, pathState: PathState, paths: Array<PathState> = []) =
    // are we at the end?
    if (pathState.location == gearIsland.factory) pathState
    // else if (sizeOf(pathState.trail) > 16) pathState // temporary shortening
    else do {
        // generate all next steps and put in paths
        var steps = ["north", "south", "east", "west"] flatMap (direction) -> do {
            var position = move(pathState.location, direction)
            var straightSteps = 1 + if (direction == pathState.direction) pathState.straightSteps else 0
            ---
            if (isBackwards(pathState.direction, direction)) []
            else if (! inBounds(gearIsland, position)) []
            else if (direction == pathState.direction and (pathState.straightSteps == 3)) []
            else if (pathState.trail some (trailStep) -> trailStep.location == position) []
            else {
                location: position,
                direction: direction,
                trail: pathState.trail << (pathState - "trail"),
                straightSteps: straightSteps,
                heatLoss: pathState.heatLoss + measureHeatLoss(gearIsland, position)
            }
        }
        // add to paths and sort (like a priority queue)
        var sortedPaths = ((paths ++ steps) orderBy (step) -> step.heatLoss) splitAt 1
        var forLog = log(pathState.location ++ {heatLoss: pathState.heatLoss})
        var nextStep = sortedPaths.l[0]
        var newPaths = sortedPaths.r
        ---
        findLowestHeatLossPathToFactory(gearIsland, nextStep, newPaths)
    }

fun isBackwards(dir1: String, dir2: String): Boolean =
    dir1 match {
        case "north" -> (dir2 == "south")
        case "south" -> (dir2 == "north")
        case "east" -> (dir2 == "west")
        case "west" -> (dir2 == "east")
        else -> false // e.g. "start"
    }

fun inBounds(gearIsland: GearIsland, position: Point): Boolean = 
    (position.x >= 0) and (position.x < sizeOf(gearIsland.map[0]))
    and
    (position.y >= 0) and (position.y < sizeOf(gearIsland.map))

fun measureHeatLoss(gearIsland: GearIsland, location: Point): Number =
    gearIsland.map[location.y][location.x] as Number


fun findPathForUltraCrucible(gearIsland: GearIsland, pathState: PathState, paths: Array<PathState> = []) =
    // are we at the end?
    if (pathState.location == gearIsland.factory) pathState
    else do {
        // generate all next steps and put in paths
        var steps = ["north", "south", "east", "west"] flatMap (direction) -> do {
            // determine ultra crucible next steps
            var position = 
                if (direction == pathState.direction) move(pathState.location, direction)
                else move(pathState.location, direction, 4)
            var straightSteps = 1 + (if (direction == pathState.direction) pathState.straightSteps else 3)
            ---
            if (isBackwards(pathState.direction, direction)) []
            else if (! inBounds(gearIsland, position)) []
            else if (direction == pathState.direction and (pathState.straightSteps == 10)) []
            else if (pathState.trail some (trailStep) -> trailStep.location == position) []
            else {
                location: position,
                direction: direction,
                trail: pathState.trail << (pathState - "trail"), // account for leap
                straightSteps: straightSteps,
                heatLoss: pathState.heatLoss + measureHeatLoss(gearIsland, position) // account for leap
            }
        }
        // add to paths and sort (like a priority queue)
        var sortedPaths = ((paths ++ steps) orderBy (step) -> step.heatLoss) splitAt 1
        var nextStep = sortedPaths.l[0]
        var newPaths = sortedPaths.r
        ---
        findLowestHeatLossPathToFactory(gearIsland, nextStep, newPaths)
    }