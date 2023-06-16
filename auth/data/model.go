package data

import "time"

type User struct {
	Id       int64  `firestore:"id"`
	Password string `json:"password" firestore:"-"`
	Hash     string `firestore:"hash"`
	Email    string `json:"email" firestore:"email"`
}

type Session struct {
	Id      string    `firestore:"id"`
	UserId  int64     `firestore:"userid"`
	Created time.Time `firestore:"created"`
	IP      string    `firestore:"ip"`
}
