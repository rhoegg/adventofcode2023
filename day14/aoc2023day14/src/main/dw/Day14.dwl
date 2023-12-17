/**
* This module will be shared through your library, feel free to modify it as you please.
*
* You can try it out with the mapping on the src/test/dw directory.
*/
%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings
import * from dw::Crypto

type Platform = Array<Array<String>>
fun platform(filename) = lines(readUrl("classpath://$(filename)", "text/plain")) map (line) ->
    line splitBy ""

fun pretty(platform: Platform): Array<String> =
    platform map (row) -> row joinBy ""

fun getColumn(pattern, columnIndex) = 
    (pattern map (row) -> row[columnIndex])

fun transpose(pattern: Platform): Platform =
    pattern[0] map ((cell, i) -> getColumn(pattern, i))

fun reverse(pattern: Platform): Platform =
    pattern map (row) -> row[-1 to 0]

fun tiltNorth(platform: Platform): Platform = 
    // transpose, then tilt each row west, then transpose
    transpose(
        tiltWest(
            transpose(platform)))

fun tiltWest(platform: Platform): Platform =
    platform map (row) -> tiltRow(row)

fun tiltSouth(platform: Platform): Platform =
    // transpose, reverse, tilt, reverse, transpose
    transpose(
        reverse(
            tiltWest(
                reverse(
                    transpose(platform)))))

fun tiltEast(platform: Platform): Platform =
    // reverse, tilt, reverse
    reverse(
        tiltWest(
            reverse(platform)))
fun tiltRow(row: Array<String>): Array<String> = do {
    // get the first O pos
    var roundRockPosition = row indexOf "O"
    ---
    if (roundRockPosition == -1) row
    else do {
        // if there are any . to left, remove and append to end
        var rowParts = row splitAt roundRockPosition
        var precedingEmpties = rowParts[0] countTrailing "."
        var newRoundRockPosition = roundRockPosition - precedingEmpties
        var slideOneRock = (row take newRoundRockPosition) << "O"
        var remainder = ("." repeatItems precedingEmpties)
            ++ (rowParts[1] drop 1)
        ---
        // repeat after new O pos
        slideOneRock ++ tiltRow(remainder)
    }
}

fun countTrailing(strings: Array<String>, matching: String): Number = do {
    var matches = strings[-1 to 0] takeWhile ((item) -> item == matching)
    ---
    sizeOf(matches) default 0
}

fun repeatItems(item, count: Number): Array =
    if (count < 1) []
    else (1 to count) map item

fun score(platform: Platform): Number = do {
    var height = sizeOf(platform)
    var scores = platform map (row, index) ->
        (row filter (item) -> item == "O")
        map (height - index)
    ---
    scores sumBy (row) -> sum(row)
}

fun cycle(platform: Platform, count: Number, cache = {}): Platform = do {
    var platformCacheKey = cacheKey(platform)
    var cached = cache[platformCacheKey]
    ---
    if (cached != null) cached
    else do {
        // memoize
        var north = tiltNorth(platform)
        var west = tiltWest(north)
        var south = tiltSouth(west)
        var east = tiltEast(south)
        ---
        if (count < 1) platform
        else if (count == 1) east
        else if (platformCacheKey == cacheKey(east)) east
        else cycle(east, count - 1, cache ++ {(platformCacheKey): east})
    }
}

fun cacheKey(platform: Platform): String = do {
    var joinedRows = platform map (row) -> row joinBy ""
    ---
    MD5(joinedRows joinBy "")
}
