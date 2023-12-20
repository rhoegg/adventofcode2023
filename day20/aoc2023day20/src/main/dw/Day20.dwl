%dw 2.0

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
                {(sources map (source) -> {(source.name): 0})}
            }
            else module
    }

fun pushButton(modules) = sendPulse(modules, [{module: "broadcaster", pulse: 0}])

fun sendPulse(modules, pulses) = 
    if (isEmpty(pulses)) []
    else do {
        var pulse = pulses[0]
        var pending = pulses[1 to -1]
        var moduleInfo = modules[pulse.module]
        // new module state here
        var newModuleState = moduleInfo
            mergeWith pulse.moduleType match {
                case "%" -> // flip flop
                    if (pulse.pulse == 1) {} // high pulse nothing happens
                    else {state: ! moduleInfo.state } // toggle
                case "&" -> // conjunction
                    { (pulse.module): pulse.pulse }
                else -> {}
            }
        ---
        pending ++ pulse match {
            case p if (p.module == "broadcaster") ->
                modules[p.module].destinations map (destination) ->
                    { module: destination, pulse: p }
            case p if (moduleInfo.moduleType == "%") -> if (p.pulse == 1) []
                else moduleInfo.destinations map (destination) ->
                    { module: destination, pulse: if (newModuleState.state) 1 else 0 }
            case p if (moduleInfo.moduleType == "&") -> "conjunction"
        }
    }
