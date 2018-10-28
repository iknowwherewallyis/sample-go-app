package main

import (
	"log"
	"net/http"
)

func main() {
	router := NewRouter()
	log.Println("testing staging")
	log.Fatal(http.ListenAndServe(":8088", router))
}
