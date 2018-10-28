package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	router := NewRouter()
	log.Println(http.ListenAndServe(":8088", router))
	//log.Fatal(http.ListenAndServe(":8088", router))
	fmt.Println("Container successful")
}
