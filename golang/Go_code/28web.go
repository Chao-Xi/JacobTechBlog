package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
)

func main() {

	url := "http://services.explorecalifornia.org/json/tours.php"

	resp, err := http.Get(url)
	if err != nil {
		panic(err)
	}
	fmt.Printf("Response Type: %T\n", resp)

	defer resp.Body.Close()

	bytes, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}

	content := string(bytes)
	fmt.Print(content)
}
