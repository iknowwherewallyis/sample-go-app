package main

import (
	"log"
	"net/http"
)

func main() {
	router := NewRouter()
	log.Println("Staging server running")
	log.Fatal(http.ListenAndServe(":8088", router))
}
