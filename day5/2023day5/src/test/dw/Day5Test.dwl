%dw 2.0
import * from Day5
output application/json
---
{
    seeds: seeds,
    seedToSoil: seeds convert parseMap(parts[1]),
    minLocation: min(
        conversionMaps reduce (conversionMap, source = seeds) ->
            source convert conversionMap
    ),
    maps: conversionMaps[-1],
    humidityToLocationInputs: part2RelevantInputs(conversionMaps[-1]),
    temperatureToHumidityInputs:
        part2RelevantInputs(conversionMaps[-2]) ++ 
        reverseConversion(part2RelevantInputs(conversionMaps[-1]), conversionMaps[-2]),
    part2Maps: conversionMaps[-1 to 0].name,
    part2RelevantSeeds: part2RelevantSeeds,
    part2MinLocation: min(
        conversionMaps reduce (conversionMap, source = part2RelevantSeeds) ->
            source convert conversionMap
    )
}
