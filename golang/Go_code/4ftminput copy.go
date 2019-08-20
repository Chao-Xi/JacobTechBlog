package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	// var s string
	// fmt.Scanln(&s)
	// fmt.Println(s)

	reader := bufio.NewReader(os.Stdin) //Declare
	fmt.Print("Enter text: ")
	str, _ := reader.ReadString('\n')
	fmt.Println(str)

	fmt.Print("Enter a number: ")
	str, _ = reader.ReadString('\n') //Assign
	f, err := strconv.ParseFloat(strings.TrimSpace(str), 64)
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Println("Value of number:", f)
	}
}
