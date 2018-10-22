package main

import (
	"encoding/json"
	"net/http"
)

func StatusIndex(w http.ResponseWriter, r *http.Request) {
	output := new(Status)
	output.CurrentStatus = "running"
	output.Version = "1.0"

	if err := json.NewEncoder(w).Encode(output); err != nil {
		panic(err)
	}
}
