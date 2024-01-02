%dw 2.0

import * from dw::core::Strings

type Point = {
    x: Number,
    y: Number,
    z: Number
}

type Hailstone = {
    position: Point,
    velocity: Point
}

fun parsePoint(text) = do {
    var numbers = (text splitBy ", ") map trim($) as Number
    ---
    {
        x: numbers[0],
        y: numbers[1],
        z: numbers[2]
    }
}

fun parseHailstone(text: String): Hailstone = do {
        var parts = text splitBy " @ "
        ---
        {
            position: parsePoint(parts[0]),
            velocity: parsePoint(parts[1])
        }
    }

fun load(filename: String): Array<Hailstone> =
    (lines(readUrl("classpath://$(filename)", "text/plain")) 
        map (line) -> parseHailstone(line)) as Array<Hailstone> // why is this coercion needed?

fun countIntersectionXY(hailstones: Array<Hailstone>, min: Number, max: Number) = 
    sum(pairs(hailstones) map (pair) -> do {
        // by = -ax + c, need to negate x2-x1
        var x1 = pair[0].position.x
        var y1 = pair[0].position.y
        var a1 = pair[0].velocity.y
        var b1 = -pair[0].velocity.x

        var x3 = pair[1].position.x
        var y3 = pair[1].position.y
        var a2 = pair[1].velocity.y
        var b2 = -pair[1].velocity.x
        var determinant = a1 * b2 - a2 * b1
        ---
        if (determinant == 0) 0
        else do {
            var c1 = a1 * x1 + b1 * y1
            var c2 = a2 * x3 + b2 * y3
            var x = (b2 * c1 - b1 * c2) / determinant
            var xInFuture = ((x - x1 > 0) == (b1 < 0)) and ((x - x3 > 0) == (b2 < 0))
            ---
            if (xInFuture and x >= min and x <= max) do {
                var y = (a1 * c2 - a2 * c1) / determinant
                var yInFuture = ((y - y1 > 0) == (a1 > 0)) and ((y - y3 > 0) == (a2 > 0))
                ---
                if (yInFuture and y >= min and y <= max) do {
                    var forlog = log({x: x, y: y})
                    ---
                    1
                } else 0
            } else 0
        }
    })


// tail recursive because of the size of the input
fun pairs(a: Array, acc: Array<Array> = []): Array<Array> = do {
    var first = a[0]
    var remaining = a[1 to -1]
    ---
    if(sizeOf(a) < 2) acc
    else pairs(remaining, acc ++ (remaining map [first, $]))
}

fun part1(filename: String, min: Number, max: Number) =
    countIntersectionXY(load(filename), min, max)