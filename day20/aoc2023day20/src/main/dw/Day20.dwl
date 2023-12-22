%dw 2.0

import * from dw::core::Arrays
import * from dw::core::Strings
import * from dw::core::Objects

fun load(filename) = readUrl("classpath://$(filename)", "text/plain")

fun loadModuleConfiguration(filename) = do {
    var moduleConfigs = lines(load(filename)) map (line) -> do {
        var parts = line splitBy " -> "
        var moduleType = parts[0] match {
            case name matches /(\W)\w+/  -> name[1]
            else -> "none"
        }
        ---
        {
            moduleType: moduleType,
            name: if (moduleType == "none") parts[0] else parts[0][1 to -1],
            destinations: parts[1] splitBy ", "
        }
    }
    ---
    {(moduleConfigs map (config) -> {
        (config.name): config
    })}
}

fun initModuleStates(modules) =
    modules mapObject (module, name) -> {
        (name): if (module.moduleType == "%") module ++ {state: false}
            else if (module.moduleType == "&") module ++ do {
                var sources = (modules pluck $) 
                    filter (sourceModule) -> 
                        sourceModule.destinations contains module.name
                ---
                memory: {(sources map (source) -> {(source.name): 0})}
            }
            else module
    }

fun sendPulse(pulseState: {modules: Object, new: Array<Object>, all?: Array<Object>}) = 
    if (isEmpty(pulseState.new)) pulseState
    else if ((pulseState.count default 0) > 50) pulseState
    else do {
        var pulse = pulseState.new[0]
        var pending = pulseState.new drop 1
        var moduleInfo = pulseState.modules[pulse.module] default {}
        // new module state here
        var newModuleState = moduleInfo.moduleType match {
                case "%" -> // flip flop
                    moduleInfo mergeWith 
                        if (pulse.pulse.pulse == 1) {} // high pulse nothing happens
                        else {state: ! moduleInfo.state } // toggle
                case "&" -> // conjunction
                    moduleInfo update {
                        case mem at .memory -> mem mergeWith { (pulse.pulse.module): pulse.pulse.pulse }
                    }
                else -> moduleInfo
            }
        var newPulses = pulse match {
            case p if (p.module == "broadcaster") ->
                newModuleState.destinations map (destination) ->
                    { module: destination, pulse: p }
            case p if (newModuleState.moduleType == "%") -> 
                if (p.pulse.pulse == 1) []
                else newModuleState.destinations map (destination) ->
                    { 
                        module: destination, 
                        pulse: {
                            module: p.module,
                            pulse: if (newModuleState.state) 1 else 0
                        },
                        round: pulseState.count 
                    }
            case p if (newModuleState.moduleType == "&") ->
                newModuleState.destinations map (destination) ->
                    { 
                        module: destination, 
                        pulse: {
                            module: p.module,
                            pulse: if (newModuleState.memory pluck $ every (state) -> (state == 1)) 0 else 1
                        },
                        round: pulseState.count
                    }
            else -> []
            }
        ---
        sendPulse(
            {
                modules:  pulseState.modules mergeWith { (pulse.module): newModuleState },
                all: (pulseState.all default [{module: pulse.module, pulse: pulse}]) ++ newPulses,
                new: pending ++ newPulses,
                count: (pulseState.count default 0) + 1
            }
        )
    }

fun pushButton(modules) = sendPulse({modules: modules, new: [{module: "broadcaster", pulse: 0}]})

fun pushButtonUntilCycle(modules, history = []) = do {
    var thisResult = pushButton(log("pushing button", modules))
    ---
    if ((sizeOf(history) > 0) and thisResult.modules == history[0].modules)
        history
    else if (sizeOf(history) > 1000) history[0 to 999]
    else
        pushButtonUntilCycle(thisResult.modules, history << thisResult)
}

fun pushButtonRepeatedly(modules, goal:Number, history = []) = do {
    var thisResult = pushButton(modules)
    ---
    if (sizeOf(history) == goal) (history << thisResult) map $.all
    else pushButtonRepeatedly(thisResult.modules, goal, history << thisResult)
}

fun part1(beginState) =
    do {
        // var buttonCycle = pushButtonUntilCycle(beginState)
        // var push1000 = (1 to 1000) map (buttonCycle[$ mod sizeOf(buttonCycle)].all)
        var push1000 = pushButtonRepeatedly(beginState, 1000)
        var push1000pulses = flatten(push1000 map (pushResults) ->
            (pushResults map (pushResult) -> pushResult.pulse.pulse))
        var pulseCounts = (push1000pulses groupBy $) mapObject (pulses, pulseType) ->
            (pulseType): sizeOf(pulses)
        ---
        {
            // cycle: sizeOf(buttonCycle),
            // examples: buttonCycle[0 to 2],
            pulseCounts: pulseCounts,
            solution: pulseCounts['0'] * pulseCounts['1']
        }
    }