package main

import (
	"fmt"
	"time"
)

var (
	sleepTime string = "3s"
)

func main() {
	// parsing time
	sleepTimeDuration, _ := time.ParseDuration(sleepTime)

	// print message in a loop
	for {
		fmt.Printf("I'm running from scratch.\n")
		time.Sleep(sleepTimeDuration)
	}
}
