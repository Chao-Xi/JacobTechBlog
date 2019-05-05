package main

import (
	"fmt"
	// "html/template"
	"io"
	"net/http"
)

func hello(w http.ResponseWriter, r *http.Request) {
	if r.Method == "GET" {
		io.WriteString(w, "<html><head></head><body><h1>Welcome to GaiaStack!</h1><img height=\"100\" src=\"/static/logo.png\"></body></html>")
		return
	}
}

func main() {
	http.HandleFunc("/", hello)
	http.HandleFunc("/static/", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, r.URL.Path[1:])
	})
	err1 := http.ListenAndServe(":9009", nil)
	if err1 != nil {
		fmt.Println("Listen And Server", err1.Error())
	}
}
