package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"math/big"
	"net/http"
	"strings"
)

// 1. A struct, that will represent each entity within my JSON data
// 2. Then I'll declare two fields, Name and Price.

type Tour struct {
	Name, Price string
}

func main() {

	url := "http://services.explorecalifornia.org/json/tours.php"
	content := contentFromServer(url)

	tours := toursFromJson(content)
	// fmt.Println(tours)

	for _, tour := range tours {
		price, _, _ := big.ParseFloat(tour.Price, 10, 2, big.ToZero)
		//Then is the base, and I'm saying I'm counting in base 10. And then the precision, which I'll set to 2.
		fmt.Printf("%v ($%.2f)\n", tour.Name, price)
	}
}

func checkError(err error) {
	if err != nil {
		panic(err)
	}
}

func contentFromServer(url string) string {

	resp, err := http.Get(url)
	checkError(err)

	defer resp.Body.Close()
	bytes, err := ioutil.ReadAll(resp.Body)
	checkError(err)

	return string(bytes)
}

func toursFromJson(content string) []Tour {
	tours := make([]Tour, 0, 20)
	// I'm setting this as a slice, and not as a fixed-size array, because I don't know how many tours I'm going to get.
	// built-in Make function.
	// set the initial size as 0, and the initial capacity at 20

	decoder := json.NewDecoder(strings.NewReader(content))
	// json.NewDecoder(reader object from the strings.NewReader function)
	_, err := decoder.Token()
	// The first is the token itself, and I'm not intetrested in that. So I'll throw it away, by naming it with an underscore character,
	checkError(err)

	var tour Tour
	// Tour is struct
	for decoder.More() {
		err := decoder.Decode(&tour)
		checkError(err)
		tours = append(tours, tour)
	}
	return tours
}
