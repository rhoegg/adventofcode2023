/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0
output application/json

import * from Day7
---
{
    game: game,
    // firstCardRanks: game map cardRank($.hand[0]),
    // typedHands: typedHands,
    rankedHands: rankedHands,
    totalWinnings: totalWinnings,
    jokersTotalWinnings: jokersTotalWinnings
}