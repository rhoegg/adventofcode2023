package main

import (
	"os"
	"strings"
)

func ParseWiringDiagram(filename string) []Component {
	inputdata, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	components := make(map[string][]string)
	for _, line := range strings.Split(string(inputdata), "\n") {
		tokens := strings.Split(line, ": ")
		name := tokens[0]
		for _, wire := range strings.Split(tokens[1], " ") {
			components[name] = append(components[name], wire)
			components[wire] = append(components[wire], name)
		}
	}
	var result []Component
	for name, wires := range components {
		result = append(result, Component{
			Name:  name,
			Wires: wires,
		})
	}
	return result
}

type Component struct {
	Name  string
	Wires []string
}
