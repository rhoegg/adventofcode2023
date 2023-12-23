package main

type Module struct {
	Name         string
	Type         string
	Destinations []string
}

type ModuleConfiguration struct {
	Modules map[string]*Module
}
