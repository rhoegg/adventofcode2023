package main

import (
	"os"
	"regexp"
	"strings"
)

func main() {

}

func LoadModuleConfiguration(filename string) ModuleConfiguration {
	inputdata, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	modules := make(map[string]*Module)
	for _, line := range strings.Split(string(inputdata), "\n") {
		segments := strings.Split(line, " -> ")
		hasType, err := regexp.MatchString("\\w.*", segments[0])
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
			Destinations: strings.Split(segments[1], ","),
		}
		modules[name] = &m
	}

	return ModuleConfiguration{
		Modules: modules,
	}
}
