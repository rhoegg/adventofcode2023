%dw 2.0
import every from dw::core::Arrays
output application/json

var lines = puzzleInput splitBy "\n"
var bag = {
    red: 12,
    green: 13,
    blue: 14
}

fun parseRounds(rounds) = rounds map (roundText) -> do {
    var rounds = roundText splitBy ", "
    
    ---
    {(
        rounds map (round) ->
        round splitBy " "
        then (roundParts) ->
            { (roundParts[1]): roundParts[0] as Number}
    )}
}

fun parseGames(lines) =
    lines map (line) ->
        line splitBy ": "
        then (game) ->
            {
                game: (game[0] splitBy " ")[-1] as Number,
                rounds: parseRounds(game[1] splitBy "; ")
            }

fun isPossible(round, bag) =
    (round.red default 0) <= bag.red
    and (round.green default 0) <= bag.green
    and (round.blue default 0) <= bag.blue

fun minimumBag(game) =
    {
        red: max(game.rounds map ($.red default 0)),
        green: max(game.rounds map ($.green default 0)),
        blue: max(game.rounds map ($.blue default 0))
    }

var games = parseGames(lines) map (game) ->
    game ++ {
        possible: game.rounds every (round) ->
            round isPossible bag 
    }
---
{
    part1: sum(
        (games filter (game) -> game.possible) 
            map (game) -> game.game
    ),
    part2: sum(
        (games map (game) -> minimumBag(game)) 
            map (bag) -> bag.red * bag.green * bag.blue
    )
}
