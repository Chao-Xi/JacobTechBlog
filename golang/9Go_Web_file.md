# Go working with Web File

## Reading a text file from the web


In Go, The **HTTP package** lets you make requests and send data to remote hosts, and also lets you create HTTP server applications that listen for and respond to requests. 

```
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
```

**If the error isn't nil, then I'll call the panic function, and that will display the error, and stop the application in its tracks**

```
if err != nil {
	panic(err)
}
```


**Use the `%T` verb to display the type of the object**

```
fmt.Printf("Response Type: %T\n", resp)
```

```
Response Type: *http.Response
```

```
defer resp.Body.Close()

bytes, err := ioutil.ReadAll(resp.Body)
if err != nil {
	panic(err)
}

content := string(bytes)
fmt.Print(content)
```

#### Return and get the json data

```
[{"tourId":"14","packageId":"5","packageTitle":"From Desert to Sea","name":"2 Days Adrift the Salton Sea","blurb":"
The Salton Sea, 25% saltier than the Pacific, has been a tourist destination since the 1920s. See what attracts peo
ple to this desert oasis.",...
```


## Creating and parsing a JSON string


```
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
```

```
$ go run 29Go_json.go 
2 Days Adrift the Salton Sea ($256.00)
A Week of Wine ($768.00)
Amgen Tour of California Special ($4096.00)
Avila Beach Hot springs ($768.00)
Big Sur Retreat ($512.00)
Channel Islands Excursion ($128.00)
Coastal Experience ($1024.00)
Cycle California: My Way ($1024.00)
Day Spa Package ($512.00)
Endangered Species Expedition ($512.00)
Fossil Tour ($384.00)
Hot Salsa Tour ($384.00)
Huntington Library and Pasadena Retreat Tour ($192.00)
In the Steps of John Muir ($512.00)
Joshua Tree: Best of the West Tour ($128.00)
Kids L.A. Tour ($192.00)
Mammoth Mountain Adventure ($768.00)
Matilija Hot springs ($768.00)
Mojave to Malibu ($192.00)
Monterey to Santa Barbara Tour ($2048.00)
Mountain High Lift-off ($768.00)
Olive Garden Tour ($64.00)
Oranges & Apples Tour ($256.00)
Restoration Package ($768.00)
The Death Valley Survivor's Trek ($192.00)
The Mt. Whitney Climbers Tour ($512.00)
```

## Creating a simple HTTP server

```
package main

import (
	"fmt"
	"net/http"
)

type Hello struct{}

func (h Hello) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "<h1>Hello from the Go web Server</h1>")
}

func main() {
	var h Hello
	err := http.ListenAndServe("localhost:4000", h)
	checkError(err)
}

func checkError(err error) {
	if err != nil {
		panic(err)
	}
}
```
```
$ go run 30http_server.go
```

```
$ curl localhost:4000
<h1>Hello from the Go web Server</h1>
```
