/**
* This module will be shared through your library, feel free to modify it as you please.
*
* You can try it out with the mapping on the src/test/dw directory.
*/
%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings
import * from dw::Runtime

type InitializationStep = {
    label: String,
    box: Number,
    operation: String,
    focalLength?: Number
}

type Lens = {label: String, focalLength: Number}

fun loadInitializationSequence(filename) =
    readUrl("classpath://$(filename)", "text/plain") splitBy ","

fun hash(text: String): Number = do {
    var chars = text splitBy ""
    ---
    chars reduce (c, currentValue=0) ->
        (currentValue + charCode(c)) * 17 mod 256
}

fun part1(sequence: Array<String>): Number =
    sum(sequence map hash($))

fun hashmap(sequence: Array<String>): Array<InitializationStep> =
    sequence map (stepText) -> do {
        var parsedSequence = stepText match /(\w+)(\W)(\d)?/
        var label = parsedSequence[1]
        var box = hash(label)
        var operation = parsedSequence[2]
        var focalLengthText = parsedSequence[3]
        ---
        {
            label: label,
            box: box,
            operation: operation,
            (focalLength: focalLengthText as Number) if (focalLengthText != null)
        }
    }

fun initializeLPF(sequence: Array<String>): Array<{box: Number, lenses: Array<Lens>}> = do {
    var instructions = hashmap(sequence)
    fun emptyBox(number) = {
        box: number,
        lenses: []
    }
    ---
    instructions reduce (instruction, boxes=[]) -> do {
        var box = (boxes firstWith (b) ->
             b.box == instruction.box) default emptyBox(instruction.box)
        var oldLens = box.lenses 
                firstWith (lens: Lens) ->
                    lens.label == instruction.label

        var updatedLenses = instruction.operation match {
            case "-" -> box.lenses - oldLens
            case "=" -> 
                if (oldLens == null) 
                    box.lenses << {
                        label: instruction.label,
                        focalLength: instruction.focalLength as Number
                    }
                else 
                    box.lenses map (lens) ->
                        if (lens.label == instruction.label) {
                            label: lens.label,
                            focalLength: instruction.focalLength
                        } else lens
            else -> fail("unrecognized operation $(instruction.operation)", box.lenses)
        }
        ---
        (boxes - box) << {
            box: box.box,
            lenses: updatedLenses
        }
    }
}

fun initializationCheck(boxes) =
    sum(
        boxes flatMap (box) ->
            box.lenses map (lens, lensIndex) ->
                (box.box + 1) * (lensIndex + 1) * lens.focalLength
    )