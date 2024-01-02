%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings
import * from dw::util::Timer

type Point = {
    x: Number,
    y: Number,
    z: Number
}

type Brick = {
    p1: Point,
    p2: Point,
    index: Number
}

type Vector = Point

fun load(filename) =
    readUrl("classpath://$(filename)", "text/plain")

fun parseBricks(filename) = lines(load(filename)) map (line, index) -> do {
    var brickEnds = line splitBy "~" map (brickEnd) ->
        brickEnd splitBy ","
    var points = brickEnds map (p) -> {
        x: p[0] as Number,
        y: p[1] as Number,
        z: p[2] as Number
    }
    var orderedPoints = points orderBy $.z orderBy $.y orderBy $.x
    ---
    {
        p1: orderedPoints[0],
        p2: orderedPoints[1],
        index: index
    }
}

fun move(p: Point, v: Vector): Point =
    {
        x: p.x + v.x,
        y: p.y + v.y,
        z: p.z + v.z
    }

fun drop(brick: Brick, distance:Number=1): Brick =
    brick update {
        case p at .p1 -> move(p, {x: 0, y: 0, z: -1 * distance})
        case p at .p2 -> move(p, {x: 0, y: 0, z: -1 * distance})
    }

fun allPoints(brick: Brick): Array<Point> =
    (brick.p1.x to brick.p2.x) as Array flatMap (x) ->
        (brick.p1.y to brick.p2.y) flatMap (y) ->
            (brick.p1.z to brick.p2.z) map (z) ->
                { x: x, y: y, z: z }

fun intersectsBrick(p: Point, b: Brick): Boolean =
    (p.x >= b.p1.x and p.x <= b.p2.x)
    and
    (p.y >= b.p1.y and p.y <= b.p2.y)
    and
    (p.z >= b.p1.z and p.z <= b.p2.z)

fun collides(b1: Brick, b2: Brick): Boolean =
    allPoints(b1) some (p) -> p intersectsBrick b2

fun canDrop(b: Brick, bricks: Array<Brick>): Boolean = do {
    var zoneBricks = (bricks filter (b2) ->
        [b2.p1.z, b2.p2.z] every (z) ->
            z <= (max([b.p1.z, b.p2.z]) as Number)
            and
            z >= min([b.p1.z, b.p2.z]) as Number - 1)
    ---
    (b.p1.z > 1 and b.p2.z > 1)
    and
    (! ((zoneBricks - b) some (b2) -> drop(b) collides b2))
}

fun dropMax(b: Brick, bricks: Array<Brick>): Brick = do {
    var brickBottom = min([b.p1.z, b.p2.z]) as Number
    var lowerBricks = bricks filter (brick) -> max([brick.p1.z, brick.p2.z]) < brickBottom
    var highestFloor = max(lowerBricks flatMap (brick) -> [brick.p1.z, brick.p2.z]) default brickBottom
    var knownDropDistance = brickBottom - highestFloor
    var dropped = drop(b, knownDropDistance)
    fun dropMore(brick) =
        if (! canDrop(brick, bricks)) brick
        else dropMore(drop(brick, 1))
    ---
    dropMore(dropped)
}
    

fun applyGravity(bricks: Array<Brick>, count=0): Array<Brick> = do {
    var timedFilter = duration(
        () -> ((bricks filter (b) -> canDrop(b, bricks))
           orderBy (brick) -> min([brick.p1.z, brick.p2.z]))
    )
    var hoverBricks = timedFilter.result
       
    var forLog = log("falling check $(timedFilter.time)", 1)
    var wholeThing = duration( () ->
        if (isEmpty(hoverBricks)) bricks
        // else if (count>2) bricks
        else do {
            var timedDrop = duration(() -> hoverBricks map (b) -> dropMax(b, bricks))
            var dropped = timedDrop.result
            var forLog2 = log("drop check $(timedDrop.time)", sizeOf(dropped))
            var updatedArray = duration(() -> (bricks -- hoverBricks) ++ dropped)
            var forLog3 = log("update array $(updatedArray.time)", sizeOf(updatedArray))
            ---
            // applyGravity(updatedArray.result, count+1)
            updatedArray.result
        }
    )
    var forLog2 = log("whole thing $(wholeThing.time)", 1)
    ---
    wholeThing.result
}

fun applyGravity2(bricks: Array<Brick>, count=0): Array<Brick> = do {
    var afterDrop = bricks map (b) -> dropMax(b, bricks)
    ---
    if (afterDrop == bricks) afterDrop
    else if (count>2) afterDrop
    else applyGravity2(afterDrop, count+1)
}

fun supportedBricks(b: Brick, bricks: Array<Brick>): Array<Brick> = do {
    var otherBricks = (bricks - b) 
    ---
    otherBricks filter (b2) -> (canDrop(b2, otherBricks))   
}