/**
* This module will be shared through your library, feel free to modify it as you please.
*
* You can try it out with the mapping on the src/test/dw directory.
*/
%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings
import * from dw::core::Numbers

var game = readUrl("classpath://puzzle-input.txt", "text/plain")
    splitBy "\n"
    map do {
        var lineWords = words($)
        ---
        {
            hand: lineWords[0],
            bid: lineWords[1] as Number
        }
    }

var cardRanks = "AKQJT98765432"
var jokerCardRanks = "AKQT98765432J"

fun cardRank(card) = (cardRanks find card)[0]
fun jokerCardRank(card) = (jokerCardRanks find card)[0]

fun replaceJokers(hand) = do {
    var handWithoutJacks = hand filter $ != "J"
    var bestCardToReplace = 
        (handWithoutJacks groupBy $ pluck $ maxBy sizeOf($))[0]
        default "A"
    ---
    hand replace "J" with(log(hand, bestCardToReplace))
}
fun handType(hand, jokers=false) = do {
    var playableHand =
        if (jokers)
            replaceJokers(hand)
        else
            hand
    var cardGroups = playableHand splitBy "" groupBy $
    var cardCounts = (
        cardGroups pluck (cards, card) -> {
            card: card,
            count: sizeOf(cards)
        }
    ) orderBy (-1 * $.count) 
    ---
    cardCounts match {
        case cardCounts if (cardCounts[0].count == 5) -> {
            name: "Five of a kind",
            value: 6
        }
        case cardCounts if (cardCounts[0].count == 4) -> {
            name: "Four of a kind",
            value: 5
        }
        case cardCounts if (cardCounts[0].count == 3 and cardCounts[1].count == 2) -> {
            name: "Full house",
            value: 4
        }
        case cardCounts if (cardCounts[0].count == 3) -> {
            name: "Three of a kind",
            value: 3
        }
        case cardCounts if (cardCounts[0].count == 2 and cardCounts[1].count == 2) -> {
            name: "Two pair",
            value: 2
        }
        case cardCounts if (cardCounts[0].count == 2) -> {
            name: "One pair",
            value: 1
        }
        else -> {
            name: "High card",
            value: 0
        }
    }
}

var typedHands = game map (play) -> 
        play ++ {
            handType: handType(play.hand)
        }

var jokerTypedHands = game map (play) ->
        play ++ {
            handType: handType(play.hand, true)
        }

fun secondOrderingRule(hand, jokers=false) = do {
    var encodedCards = hand splitBy "" map (card) ->
        if (jokers)
            toHex(jokerCardRank(card))
        else
            toHex(cardRank(card))
    ---
    encodedCards joinBy ""
}

var rankedHands = do {
    var secondOrdering = typedHands orderBy secondOrderingRule($.hand)
    ---
    secondOrdering[-1 to 0] orderBy $.handType.value
} map (play, index) -> play ++ {
    rank: index + 1
}

var totalWinnings = rankedHands sumBy (rankedHand) ->
    rankedHand.rank * rankedHand.bid

var jokersRankedHands = do {
    var secondOrdering = jokerTypedHands orderBy secondOrderingRule($.hand, true)
    ---
    secondOrdering[-1 to 0] orderBy $.handType.value
} map (play, index) -> play ++ {
    rank: index + 1
}

var jokersTotalWinnings = jokersRankedHands sumBy (rankedHand) ->
    rankedHand.rank * rankedHand.bid