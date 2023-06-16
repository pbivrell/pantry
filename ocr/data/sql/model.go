package data

import "time"

type User struct {
	Id       int
	Username string
	Hash     string
}

type StoreType struct {
	Id   int
	Name string
}

type Store struct {
	Id          int
	Name        string
	Address     string
	StoreTypeId int
}

type Trip struct {
	Id       int
	StoreId  int
	UserId   int
	TripDate time.Time
}

type Purchase struct {
	Id                int
	Price             int
	ProductIdentifier string
	CommonProductId   int
	TripId            int
}

type CommonProduct struct {
	Id   int
	Name string
	Icon string
}

type ProductItem struct {
	CommonProductId int    `json:"id"`
	Name            string `json:"name"`
	Icon            string `json:"icon"`
	Price           int    `json:"price"`
	InPantry        bool   `json:"inPantry"`
}

type Meal struct {
	Id     int
	Name   string
	Info   string
	Origin string
}

type MealIngredient struct {
	Id              int
	MealId          int
	CommonProductId int
}

type MealItem struct {
	MealId int       `json:"id"`
	Name   string    `json:"name"`
	Date   time.Time `json:"date"`
	Icon   string    `json:"icon"`
}

type MealCard struct {
	Meal
	Ingredients []int
}
