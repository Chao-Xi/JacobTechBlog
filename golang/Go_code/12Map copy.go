package main

import (
	"fmt"
	"sort"
)

func main() {
	states := make(map[string]string)

	states["NY"] = "New York"
	states["NJ"] = "New Jersey"
	states["CA"] = "California"

	fmt.Println(states)

	california := states["CA"]
	fmt.Println(california)

	delete(states, "NJ")
	fmt.Println(states)

	states["WA"] = "Washington"

	for k, v := range states {
		fmt.Printf("%v: %v\n", k, v)
	}

	keys := make([]string, len(states))
	// fmt.Println(len(keys))
	i := 0
	for k := range states {
		keys[i] = k
		i++
	}
	sort.Strings(keys)
	fmt.Println("\nSorted")

	for i := range keys {
		fmt.Println(states[keys[i]])
	}

}
