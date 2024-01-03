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
                    var forlog = log("part 1", {x: x, y: y})
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

fun part2(filename: String) = do {
    var hailstones = load(filename)
    // used pencil and paper -- for any hailstone line, x and y only, we have:
    // -x*vy + y*vx = y1*vx - y1*vx1 + y*vx1 - x1*vy - x1*vy1 + x*vy1
    // since the left side will be the same for every line, we have 4 unknowns:
    // vx, vy, x, y
    // so we can make a system of linear equations to determine unknowns like this:
    // y1*vx - y1*vx1 + y*vx1 - x1*vy - x1*vy1 + x*vy1 = 
    // y2*vx - y2*vx2 + y*vx2 - x2*vy - x2*vy2 + x*vy2
    var fourPairs = pairs(hailstones)[0 to 3]
    var matrix = fourPairs map (p) -> coefficients(p[0], p[1])
    var transformed = gaussianElimination(matrix, 0)
    var vy = transformed[3][4] / transformed[3][3]
    var y = (transformed[2][4] - transformed[2][3] * vy) / transformed[2][2]
    var vx = (transformed[1][4] - transformed[1][3] * vy - transformed[1][2] * y) / transformed[1][1]
    var x = (transformed[0][4] - transformed[0][3] * vy - transformed[0][2] * y - transformed[0][1] * vx) / transformed[0][0]
    var t1 = (hailstones[0].position.x - x) / (vx - hailstones[0].velocity.x)
    var t2 = (hailstones[1].position.x - x) / (vx - hailstones[1].velocity.x)
    // vz = (t1*vz1 - z1 - t2*vz2 + z*2) / (t1 - t2)
    // WRONG -- one minus sigh!
    // vz = (z1 - z2 + t1*vz1 - t2*vz2) / (t1 - t2)
    var vz = (hailstones[0].position.z - hailstones[1].position.z + t1*hailstones[0].velocity.z - t2*hailstones[1].velocity.z) / (t1 - t2)
    // z = t1(vz1 - vz) + z1
    var z = t1 * (hailstones[0].velocity.z - vz) + hailstones[0].position.z
    ---
    {
        vy: vy,
        y: y,
        vx: vx,
        x: x,
        vz: vz,
        z: z,
        t1: t1,
        part2: x + y + z
    }
}

/**
* Gives coefficients for a linear equation describing a line that intersects the two given hailstones
* x(vy1-vy2) - vx(y1-y2) - y(vx1-vx2) + vy(x1-x2) = x1vy1 - y1vx1 + y2vx2 - x2vy2
* ax         + bvx       + cy         + dvy       = e
*/
fun coefficients(h1: Hailstone, h2: Hailstone): Array<Number> = do {
    var a = h1.velocity.y - h2.velocity.y
    var b = h2.position.y - h1.position.y // inverted
    var c = h2.velocity.x - h1.velocity.x // inverted
    var d = h1.position.x - h2.position.x
    var e = 
        h1.position.x * h1.velocity.y - h1.position.y * h1.velocity.x + 
        h2.position.y * h2.velocity.x - h2.position.x * h2.velocity.y
    ---
    [a, b, c, d, e]
}

fun trajectory(h1: Hailstone, h2: Hailstone): Hailstone = do {
    var p = relativePosition(h1, h2)
    var v = relativeVelocity(h1, h2)
    var t = 1
    ---
    {
        position: {
            x: h1.position.x + t*h1.velocity.x,
            y: h1.position.y + t*h1.velocity.y,
            z: h1.position.z + t*h1.velocity.z
        },
        velocity: {
            x: p.x + v.x + t*h1.velocity.x,
            y: p.y + v.y + t*h1.velocity.y,
            z: p.z + v.z + t*h1.velocity.z
        }
    }
}

fun gaussianElimination(matrix: Array<Array<Number>>, col: Number): Array<Array<Number>> = 
    if (col == sizeOf(matrix) - 1) matrix
    else do {
        var pivot = matrix[col][col]
        var onePass = matrix[0 to col] ++ (matrix[col+1 to -1] map (row, i) -> do {
            var ratio = row[col] / pivot
            ---
            row map (n, j) -> if (j < col) n else n - ratio * matrix[col][j]
        })
        ---
        if (col == sizeOf(matrix) - 1) onePass
        else gaussianElimination(onePass, col + 1)
    }

fun relativePosition(h1: Hailstone, h2: Hailstone): Point = {
    x: h2.position.x-h1.position.x,
    y: h2.position.y-h1.position.y,
    z: h2.position.z-h1.position.z
}
fun relativeVelocity(h1: Hailstone, h2: Hailstone): Point =
    {
        x: h2.velocity.x-h1.velocity.x,
        y: h2.velocity.y-h1.velocity.y,
        z: h2.velocity.z-h1.velocity.z
    }