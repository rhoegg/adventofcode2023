/**
* This module will be shared through your library, feel free to modify it as you please.
*
* You can try it out with the mapping on the src/test/dw directory.
*/
%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings

fun loadPatterns(filename) = 
    readUrl("classpath://$(filename)", "text/plain")
        splitBy "\n\n"

fun parsePattern(text) = lines(text)

fun part1Data(filename) = do {
    var patterns = loadPatterns(filename) map (patternText) -> 
        parsePattern(patternText)
    ---
    patterns map (pattern) -> {
        pattern: pattern,
        transposed: transpose(pattern),
        verticalReflection: findVerticalReflectionPosition(pattern),
        horizontalReflection: findHorizontalReflectionPosition(pattern),
        score: summarize(pattern)
    }
}

fun part1(filename) = part1Data(filename) sumBy $.score

fun part2Data(filename) = part1Data(filename) map (patternInfo) -> do {
    var oldReflections = [patternInfo.verticalReflection, patternInfo.horizontalReflection]
    var candidates = smudgeChecks(patternInfo.pattern)
    var smudgedAndFixed = (
        candidates firstWith (newPattern) ->
            [0, 0] != [
                findVerticalReflectionPositionBesides(newPattern, oldReflections[0]), 
                findHorizontalReflectionPositionBesides(newPattern, oldReflections[1])]
    ) default []
    var newReflections = [
        findVerticalReflectionPositionBesides(smudgedAndFixed, oldReflections[0]), 
        findHorizontalReflectionPositionBesides(smudgedAndFixed, oldReflections[1])
    ]
    var newScore =
        if (newReflections[0] != oldReflections[0] and newReflections[0] > 0)
            sizeOf(transpose(smudgedAndFixed) take newReflections[0])
        else
            100 * sizeOf(smudgedAndFixed take newReflections[1])
    ---
    patternInfo - "transposed" ++ {
        smudgedAndFixed: smudgedAndFixed,
        newReflections: newReflections,
        newScore: newScore
    }
}

fun part2(filename) = part2Data(filename) sumBy $.newScore


fun getColumn(pattern, columnIndex) = 
    (pattern map (line) -> line[columnIndex])
        joinBy ""

fun transpose(pattern: Array<String>) =
    pattern[0] splitBy "" 
        map ((c, i) -> getColumn(pattern, i))

fun findVerticalReflectionPosition(pattern) =
   findHorizontalReflectionPosition(transpose(pattern))

fun findHorizontalReflectionPosition(pattern) =
    ((1 to sizeOf(pattern) - 1) firstWith (rowIndex) -> do {
        var topRows = (pattern take rowIndex)[-1 to 0]
        var bottomRows = pattern drop rowIndex
        ---
        topRows zip bottomRows every (pair) ->
            pair[0] == pair[1]
    }) default 0

fun findVerticalReflectionPositionBesides(pattern, index) =
    findHorizontalReflectionPositionBesides(transpose(pattern), index)

fun findHorizontalReflectionPositionBesides(pattern, index) = 
    ((1 to sizeOf(pattern) - 1) firstWith (rowIndex) -> do {
        var topRows = (pattern take rowIndex)[-1 to 0]
        var bottomRows = pattern drop rowIndex
        ---
        rowIndex != index
        and
        (
            topRows zip bottomRows every (pair) ->
                pair[0] == pair[1]
        )
    }) default 0

fun summarize(pattern: Array<String>): Number = do {
    var scoreColumns = 
        transpose(pattern) take findVerticalReflectionPosition(pattern)
    var scoreRows =
        pattern take findHorizontalReflectionPosition(pattern)
    ---
    sizeOf(scoreColumns) + 100 * sizeOf(scoreRows)
}

fun flip(c) =
    // swap ash for rock and vice versa
    c match {
        case "#" -> "."
        case "." -> "#"
    }

fun smudgeChecks(pattern: Array<String>): Array<Array<String>> =
    pattern flatMap (row, rowIndex) ->
        (row splitBy "") map(c, colIndex) ->
            replaceSmudge(pattern, rowIndex, colIndex, flip(c))

fun replaceSmudge(pattern, y, x, newValue) =
    pattern map (row, rowIndex) ->
        if (rowIndex == y) do {
            var parts = (row splitBy "") splitAt x
            ---
            parts.l << newValue ++ (parts.r drop 1)
        } joinBy ""
        else row
            