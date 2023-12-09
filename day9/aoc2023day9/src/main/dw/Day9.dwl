/**
* This module will be shared through your library, feel free to modify it as you please.
*
* You can try it out with the mapping on the src/test/dw directory.
*/
%dw 2.0
import * from dw::core::Arrays

fun oasisHistoryLines(filename) = do {
    var lines = readUrl("classpath://$(filename)", "text/plain") splitBy "\n"
    ---
    lines map (line) ->
        line splitBy " " 
            map (value) -> value as Number
}

fun predict(historyLine) = do {
    var prime = differences(historyLine)
    var complete = (prime every (value) -> value == 0)
    ---
    historyLine << (
        historyLine[-1] + 
            if (complete) prime[-1]
            else predict(prime)[-1]
    )
}


fun differences(historyStep) =
    historyStep drop 1
        zip historyStep
            map (pair) -> pair[0] - pair[1]
