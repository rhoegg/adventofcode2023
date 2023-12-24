package main

import (
	"fmt"
	"os"
	"regexp"
	"strings"
)

type Module struct {
	Name         string
	Type         string
	Destinations []string
}

type Pulse struct {
	Source      string
	Value       int8
	Destination string
}

type ModuleConfiguration struct {
	Modules      map[string]*Module
	FlipFlops    map[string]bool
	Conjunctions map[string]map[string]int8
}

func (c ModuleConfiguration) String() string {
	var descriptions []string
	for _, m := range c.Modules {
		var destinations []string
		for _, d := range m.Destinations {
			destinations = append(destinations, d)
		}
		descriptions = append(descriptions,
			fmt.Sprintf("%s [%s] -> %s", m.Name, m.Type, strings.Join(destinations, ",")))
	}
	return strings.Join(descriptions, "\n")
}

func (p Pulse) String() string {
	pulseValue := "low"
	if p.Value > 0 {
		pulseValue = "high"
	}
	return fmt.Sprintf("%s -%s-> %s", p.Source, pulseValue, p.Destination)
}

func LoadModuleConfiguration(filename string) *ModuleConfiguration {
	inputdata, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	modules := make(map[string]*Module)
	conjunctions := make(map[string]map[string]int8)
	for _, line := range strings.Split(string(inputdata), "\n") {
		segments := strings.Split(line, " -> ")
		hasType, err := regexp.MatchString("\\W.*", segments[0])
		if err != nil {
			panic(err)
		}
		moduleType := "none"
		name := segments[0]
		if hasType {
			moduleType = segments[0][0:1]
			name = segments[0][1:]
		}
		m := Module{
			Name:         name,
			Type:         moduleType,
			Destinations: strings.Split(segments[1], ", "),
		}
		modules[name] = &m

		if m.Type == "&" {
			// conjunction
			conjunctions[m.Name] = make(map[string]int8)
		}
	}

	// initialize conjunction memory
	for source := range modules {
		for _, dest := range modules[source].Destinations {
			destinationModule, ok := modules[dest]
			if ok && destinationModule.Type == "&" {
				// initialize conjunction source memory to low pulse
				conjunctions[destinationModule.Name][modules[source].Name] = 0
			}
		}
	}

	return &ModuleConfiguration{
		Modules:      modules,
		FlipFlops:    make(map[string]bool),
		Conjunctions: conjunctions,
	}
}

func (c *ModuleConfiguration) PushButton() (pulses []Pulse) {
	// send one low pulse to broadcaster module
	pulses = append(pulses, Pulse{
		Source:      "button",
		Value:       0,
		Destination: "broadcaster",
	})
	// send pulses!
	var history []Pulse
	for len(pulses) > 0 {
		thisPulse := pulses[0]
		history = append(history, thisPulse)
		remaining := pulses[1:]
		newPulses := c.SendPulse(thisPulse)
		//log.Printf("module %s generated %d pulses", thisPulse.Destination, len(newPulses))
		pulses = append(remaining, newPulses...)
	}
	return history
}

func (c *ModuleConfiguration) SendPulse(p Pulse) (pulses []Pulse) {
	if p.Destination == "broadcaster" {
		broadcaster := c.Modules["broadcaster"]
		for _, destination := range broadcaster.Destinations {
			pulses = append(pulses, Pulse{
				Source:      "broadcaster",
				Value:       0,
				Destination: destination,
			})
		}
		return pulses
	}
	if m, ok := c.Modules[p.Destination]; ok {
		if m.Type == "%" {
			// flip flop
			if p.Value == 0 {
				value := int8(1) // it was off, turn on and send high pulse
				if c.FlipFlops[p.Destination] {
					// it was on, turn off and send low pulse
					value = 0
				}
				c.FlipFlops[p.Destination] = !c.FlipFlops[p.Destination]
				for _, dest := range m.Destinations {
					pulses = append(pulses, Pulse{
						Source:      p.Destination,
						Value:       value,
						Destination: dest,
					})
				}
			}
			return pulses
		} else if m.Type == "&" {
			// conjunction
			// first update memory
			c.Conjunctions[p.Destination][p.Source] = p.Value
			// then if all are high pulses send low, otherwise high
			var pulseValue int8 = 0
			for _, currentPulseValue := range c.Conjunctions[p.Destination] {
				if currentPulseValue == 0 { // low pulse found
					pulseValue = 1
				}
			}
			for _, dest := range m.Destinations {
				pulses = append(pulses, Pulse{
					Source:      p.Destination,
					Value:       pulseValue,
					Destination: dest,
				})
			}
			return pulses
		}
	}
	//log.Printf("pulse %d to non-module %s", p.Value, p.Destination)
	return pulses
}

func (c ModuleConfiguration) PushButtonOneThousand() map[int8]int {
	stats := make(map[int8]int)
	for i := 0; i < 1000; i++ {
		pulses := c.PushButton()
		for _, p := range pulses {
			stats[p.Value] += 1
		}
	}
	return stats
}
