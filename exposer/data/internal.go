package data

import "time"

type PurchaseLine struct {
	PurchaseName string `firestore:"name" json:"name"`
	Price        int    `firestore:"price" json:"price"`
}

type TripFile struct {
	ID        int            `firestore:"-" json:"id"`
	Visit     time.Time      `firestore:"visit" json:"visit"`
	Date      time.Time      `firestore:"date" json:"date"`
	Addr      string         `firestore:"addr" json:"addr"`
	Purchases []PurchaseLine `firestore:"items" json:"items"`
}

type Summary struct {
	ID    int       `firestore:"-" json:"id"`
	Visit time.Time `firestore:"visit" json:"visit"`
	Date  time.Time `firestore:"date" json:"date"`
	Addr  string    `firestore:"addr" json:"addr"`
	Total int       `firestore:"total" json:"total"`
	Count int       `firestore:"count" json:"count"`
}
