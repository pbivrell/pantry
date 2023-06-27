package data

import "time"

type PurchaseLine struct {
	PurchaseName string `firestore:"name"`
	Price        int    `firestore:"price"`
}

type TripFile struct {
	Visit     time.Time      `firestore:"visit"`
	Date      time.Time      `firestore:"date"`
	Addr      string         `firestore:"addr"`
	Purchases []PurchaseLine `firestore:"items"`
}

type Summary struct {
	Visit time.Time `firestore:"visit"`
	Date  time.Time `firestore:"date"`
	Addr  string    `firestore:"addr"`
	Total int       `firestore:"total"`
	Count int       `firestore:"count"`
}
