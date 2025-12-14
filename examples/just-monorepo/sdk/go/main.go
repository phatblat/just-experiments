package main

import (
	"fmt"
	"os"
)

func main() {
	if len(os.Args) > 1 {
		fmt.Printf("Hello from Go SDK! You said: %s\n", os.Args[1])
	} else {
		fmt.Println("Hello from Go SDK!")
	}
}
