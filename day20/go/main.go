package main

import (
	"log"
	"strings"
)

func main() {
	moduleConfig := LoadModuleConfiguration("puzzle-input.txt")
	log.Println(moduleConfig)
	pulses := moduleConfig.PushButton()
	var pulsesText []string
	for _, p := range pulses {
		pulsesText = append(pulsesText, p.String())
	}
	log.Printf("One button push: %s", strings.Join(pulsesText, "\n"))
	part1(moduleConfig)
	part2(moduleConfig)
}

func part1(moduleConfig *ModuleConfiguration) {
	pulseStats := moduleConfig.PushButtonOneThousand()
	log.Printf("Part 1 (%d, %d): %d", pulseStats[0], pulseStats[1], pulseStats[0]*pulseStats[1])
}

func part2(moduleConfig *ModuleConfiguration) {
	// this is the brute force method.  In my input, all modules that
	//feed conjunction gh have to be "high" pulse at the same time
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
