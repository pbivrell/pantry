package data

import (
	"hash/fnv"
	"time"
)

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
	User      int64
}

type ProductID struct {
	Name string `firestore:"name"`
}

type Product struct {
	ID        string     `firestore:"id"`
	Purchases []Purchase `firestore:"history"`
}

type Purchase struct {
	Amount int       `firestore:"amount"`
	Date   time.Time `firestore:"date"`
}

func Hash(s string) int64 {
	h := fnv.New32a()
	h.Write([]byte(s))
	return int64(h.Sum32())
}
