%dw 2.0
import * from Day5
output application/json
---
{
    seeds: seeds,
    part2seeds: part2seeds,
    seedToSoil: seeds convert parseMap(parts[1]),
    minLocation: min(
        conversionMaps reduce (conversionMap, source = seeds) ->
            source convert conversionMap
    ),
    // each source range needs to check one number per destination range, recurse
    part2badperfornance: min(
        conversionMaps reduce (conversionMap, source = part2seeds) ->
            source convert log(conversionMap)
    )
}
