package main

import "time"

type Status struct {
	CurrentStatus string
	Version       string
	DeliveredAt   time.Time
}
