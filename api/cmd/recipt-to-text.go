package main

import (
	"api/ocr"
	"fmt"
	"os"
)

func main() {

	f, err := os.Open(os.Args[1])
	if err != nil {
		panic(err)
	}

	lines, err := ocr.DetectText(f, 10)
	if err != nil {
		fmt.Printf("ocr error: %v\n", err)
		return
	}
	fmt.Println(lines)
	tripFile, err := ocr.ParseKingSoopers(lines)
	if err != nil {
		fmt.Printf("parse error: %v\n", err)
		return
	}

	fmt.Println(tripFile)
}
