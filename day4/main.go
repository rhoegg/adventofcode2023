package main

import (
	"fmt"
	"log"
	"os"
	"slices"
	"strconv"
	"strings"
)

type ScratchCard struct {
	Name           string
	WinningNumbers []int
	ActualNumbers  []int
}

func ParseScratchCard(line string) ScratchCard {
	parts := strings.Split(line, ": ")
	name := parts[0]
	parts = strings.Split(parts[1], " | ")
	winning := strings.TrimSpace(strings.ReplaceAll(parts[0], "  ", " "))
	actual := strings.TrimSpace(strings.ReplaceAll(parts[1], "  ", " "))
	var winningNumbers []int
	for _, numText := range strings.Split(winning, " ") {
		winningNumber, err := strconv.Atoi(numText)
		if err != nil {
			log.Printf("error %v on %s", err, numText)
			panic(err)
		}
		winningNumbers = append(winningNumbers, winningNumber)
	}
	var cardNumbers []int
	for _, numText := range strings.Split(actual, " ") {
		cardNumber, err := strconv.Atoi(numText)
		if err != nil {
			log.Printf("error %v on %s", err, numText)
			panic(err)
		}
		cardNumbers = append(cardNumbers, cardNumber)
	}
	return ScratchCard{
		Name:           name,
		WinningNumbers: winningNumbers,
		ActualNumbers:  cardNumbers,
	}
}

func (c ScratchCard) String() string {
	return fmt.Sprintf("%s: %v | %v", c.Name, c.WinningNumbers, c.ActualNumbers)
}

func (c ScratchCard) ScoringNumbers() (result []int) {
	for _, num := range c.ActualNumbers {
		if slices.Contains(c.WinningNumbers, num) {
			result = append(result, num)
		}
	}
	return
}

func (c ScratchCard) Score() (score int) {
	for _, _ = range c.ScoringNumbers() {
		if score == 0 {
			score = 1
		} else {
			score *= 2
		}
	}
	return
}

func main() {
	data, err := os.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}
	var cards []ScratchCard
	for _, line := range strings.Split(string(data), "\n") {
		cards = append(cards, ParseScratchCard(line))
	}
	totalScore := 0
	for _, card := range cards {
		totalScore += card.Score()
	}
	fmt.Printf("Part1: %d\n", totalScore)

	cardCounts := make(map[int]int)
	for i, card := range cards {
		cardCounts[i] += 1 // this card
		for j := range card.ScoringNumbers() {
			cardCounts[i+j+1] += cardCounts[i] // this many more
		}
	}
	totalCards := 0
	for i := range cards {
		totalCards += cardCounts[i]
	}
	fmt.Printf("Part 2: %d\n", totalCards)
}
