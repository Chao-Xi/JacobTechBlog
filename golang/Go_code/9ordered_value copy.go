package main

import (
	"fmt"
)

func main() {

	var colors [3]string
	colors[0] = "pink"
	colors[1] = "black"
	colors[2] = "brown"

	fmt.Println(colors)
	fmt.Println(colors[1])

	numbers := [5]int{5, 3, 4, 2, 1}
	// var numbers = [5]int{5, 3, 4, 2, 1}
	fmt.Println(numbers)

	fmt.Println("Number of colors", len(colors))
	fmt.Println("Number of numbers", len(numbers))

	for i := 0; i < len(colors); i++ {
		fmt.Println("Output each color:", colors[i])
	}

	var twoD [2][3]int
	for i := 0; i < 2; i++ {
		for j := 0; j < 3; j++ {
			twoD[i][j] = i + j
		}
	}
	fmt.Println("2d: ", twoD)
}
