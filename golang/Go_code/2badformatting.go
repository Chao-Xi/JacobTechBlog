package main

import (
	"bytes"
	"fmt"
)

func main() {
	var chars [6]string
	chars[0] = "a"
	chars[1] = "i"
	chars[2] = "b"
	chars[3] = "o"
	chars[4] = "h"
	chars[5] = "p"

	fmt.Println("A Palindrome")
	fmt.Println("************")
	var buffer bytes.Buffer
	for i := 0; i < len(chars); i++ {
		buffer.WriteString(chars[i])
	}
	for i := len(chars) - 2; i >= 0; i-- {
		buffer.WriteString(chars[i])
	}
	fmt.Println(buffer.String())
}
