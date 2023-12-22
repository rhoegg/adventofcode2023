/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0
output application/json

import * from Day22
var bricks = parseBricks("puzzle-input.txt")
var afterGravity = applyGravity(bricks)
var part1Supported = afterGravity map (b) -> {
    index: b.index,
    supports: supportedBricks(b, afterGravity)
}
---
{
    // p1temp: bricks filter (b) -> canDrop(b, bricks)
    // gravity: afterGravity,
    // TAKES TOO LONG - redoing in go
    part1: sizeOf(part1Supported filter isEmpty($.supports))
}