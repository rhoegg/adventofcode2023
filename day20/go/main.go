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
}

func part1(moduleConfig *ModuleConfiguration) {
	pulseStats := moduleConfig.PushButtonOneThousand()
	log.Printf("Part 1 (%d, %d): %d", pulseStats[0], pulseStats[1], pulseStats[0]*pulseStats[1])
}
