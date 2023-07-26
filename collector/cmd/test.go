package main

import (
	"context"
	"exposer/data/firestore"
	"fmt"
)

const (
	authAPI   = "https://grocery-auth-dev-7osudstnga-uc.a.run.app/validate"
	projectID = "grocery-api-380005"
)

func main() {

	ctx := context.Background()

	db, err := firestore.Connect(ctx)
	if err != nil {
		fmt.Printf("Broken: %v\n", err)
		return
	}
	defer db.Close()
	summarys, err := db.GetSummarys(ctx, 1720278163)
	if err != nil {
		fmt.Println("Err", err)
	}

	fmt.Println(summarys)
}
