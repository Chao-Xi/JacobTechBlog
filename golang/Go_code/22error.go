package main

import (
	"errors"
	"fmt"
	"os"
)

func main() {
	f, err := os.Open("filename.ext")

	if err == nil {
		fmt.Println(f)
	} else {
		fmt.Println(err.Error())
	}

	myError := errors.New("My error String")
	fmt.Println(myError)

	attendene := map[string]bool{
		"Anne": true,
		"Mike": true}
	attended, ok := attendene["Ann"]

	if ok {
		fmt.Println("Anne attended?", attended)
	} else {
		fmt.Println("No info for Anne")
	}

}
