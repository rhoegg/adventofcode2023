package main

import (
	"fmt"
	"reflect"
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

type StateSummary struct {
	FlipFlop    map[string]bool
	Conjunction map[string][]int8
}

func (p Pulse) String() string {
	pulseValue := "low"
	if p.Value > 0 {
		pulseValue = "high"
	}
	return fmt.Sprintf("%s -%s-> %s", p.Source, pulseValue, p.Destination)
}

func (s StateSummary) Equals(s2 StateSummary) bool {
	return reflect.DeepEqual(s.FlipFlop, s2.FlipFlop) &&
		reflect.DeepEqual(s.Conjunction, s2.Conjunction)
}

// modified euclidean
func gcd(a int, b int) int {
	if b == 0 {
		return a
	} else {
		return gcd(b, a%b)
	}
}
func lcm(a int, b int) int {
	return (a / gcd(a, b)) * b
}
