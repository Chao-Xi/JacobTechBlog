package main

import (
	"fmt"
	"sort"
)

func main() {
	var colors = []string{"deepblue", "watermelon", "cheery"}
	fmt.Println(colors)

	var colors_appended = append(colors, "grape")
	fmt.Println(colors_appended)

	// remove first element in array
	colors = append(colors_appended[1:len(colors_appended)])
	fmt.Println(colors)

	// remove last element in array
	colors = append(colors_appended[:len(colors_appended)-1])
	fmt.Println(colors)

	numbers := make([]int, 5, 5) // initial size of five, and a capacity of five
	numbers[0] = 1
	numbers[1] = 2222
	numbers[2] = 44
	numbers[3] = 33
	numbers[4] = 323

	fmt.Println(numbers)

	numbers = append(numbers, 2333)
	fmt.Println(numbers)
	fmt.Println(cap(numbers)) // Report the current capacity.

	sort.Ints(numbers)
	fmt.Println(numbers)
}
