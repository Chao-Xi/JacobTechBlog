package main

import (
	"fmt"
	"io/ioutil"
)

func main() {
	filename := "./25fromString.txt"

	content, err := ioutil.ReadFile(filename)
	checkError(err)

	fmt.Println("Read from file", content)

	result := string(content)
	fmt.Println("Read from file", result)
}

func checkError(err error) {
	if err != nil {
		panic(err)
	}
}
