package main

import (
	"log"
	"strings"
)

func main() {
	goal := "rx"
	moduleConfig := LoadModuleConfiguration("puzzle-input.txt")
	log.Println(moduleConfig)
	log.Printf("states: %v", moduleConfig.StatesOfSources(goal))
	pulses := moduleConfig.PushButton()
	var pulsesText []string
	for _, p := range pulses {
		pulsesText = append(pulsesText, p.String())
	}
	log.Printf("One button push: %s", strings.Join(pulsesText, "\n"))
	//part1(moduleConfig)
	//part2(moduleConfig)
	log.Printf("states: %v", moduleConfig.StatesOfSources(goal))
	i := moduleConfig.CountButtonsToStateCycleForModule(goal)
	log.Printf("output state cycle in %d", i)
}

func part1(moduleConfig *ModuleConfiguration) {
	pulseStats := moduleConfig.PushButtonOneThousand()
	log.Printf("Part 1 (%d, %d): %d", pulseStats[0], pulseStats[1], pulseStats[0]*pulseStats[1])
}

func part2bruteforce(moduleConfig *ModuleConfiguration) {
	// this is the brute force method.  In my input, all modules that
	// feed conjunction gh have to be "high" pulse at the same time
	// in order to send a low pulse to rx
	// flipflops are 1 or 0
	// conjunctions are ANDs
	// can we compute the button pushes needed by binary math?
	for i := 0; moduleConfig.RxLowPulses == 0; i++ {
		moduleConfig.PushButton()
		if i%1000000 == 0 {
			log.Printf("(%d) rx pulses %d, %d", i, moduleConfig.RxLowPulses, moduleConfig.RxHighPulses)
		}
	}
	log.Printf("rx pulses %d, %d", moduleConfig.RxLowPulses, moduleConfig.RxHighPulses)
}

func part2(moduleConfig *ModuleConfiguration) {
	// make func count buttons to state cycle?
	// got lucky! the LCM didn't have to mean a low pulse but it turned out that it did
}
