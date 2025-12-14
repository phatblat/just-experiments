package main

import (
	"fmt"
	"os"
)

func main() {
	if len(os.Args) > 1 {
		fmt.Printf("Hello from Go SDK! Args: %v\n", os.Args[1:])
	} else {
		fmt.Println("Hello from Go SDK!")
	}
	fmt.Println("Version: 1.0.0")
}
