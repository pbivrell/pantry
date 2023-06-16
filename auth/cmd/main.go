package main

import (
	"auth/data"
	"auth/data/firestore"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"hash/fnv"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/gorilla/mux"
	"github.com/kjk/betterguid"
	"golang.org/x/crypto/bcrypt"
)

func main() {

	ctx := context.Background()

	db, err := firestore.Connect(ctx)
	if err != nil {
		fmt.Printf("Broken: %v\n", err)
		return
	}
	defer db.Close()

	app := NewApp(db)

	r := mux.NewRouter()
	r.HandleFunc("/login", app.HandleLogin)
	r.HandleFunc("/register", app.HandleRegister)
	r.HandleFunc("/validate", app.HandleValidate)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	srv := &http.Server{
		Addr: fmt.Sprintf("0.0.0.0:%s", port),
		// Good practice to set timeouts to avoid Slowloris attacks.
		WriteTimeout: time.Second * 15,
		ReadTimeout:  time.Second * 15,
		IdleTimeout:  time.Second * 60,
		Handler:      r, // Pass our instance of gorilla/mux in.
	}

	if err := srv.ListenAndServe(); err != nil {
		fmt.Println(err)
	}
}

type App struct {
	DB *firestore.Connection
}

func NewApp(db *firestore.Connection) *App {
	return &App{
		DB: db,
	}
}

func HashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 14)
	return string(bytes), err
}

func CheckPasswordHash(password, hash string) error {
	return bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
}

func hash(s string) int64 {
	h := fnv.New32a()
	h.Write([]byte(s))
	return int64(h.Sum32())
}

func (a *App) HandleLogin(w http.ResponseWriter, r *http.Request) {

	request := struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}{}

	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		http.Error(w, "Invalid json reuqest", http.StatusBadRequest)
		return
	}

	uid := hash(request.Email)

	user, err := a.DB.ReadUser(r.Context(), uid)
	if err != nil {
		http.Error(w, "", http.StatusInternalServerError)
		log.Printf("UserByName: %v", err)
		return
	}

	err = CheckPasswordHash(request.Password, user.Hash)

	if err != nil {
		http.Error(w, "Forbidden", http.StatusForbidden)
		log.Printf("CheckPasswordHash: %v", err)
		return
	}

	cookie, err := a.CreateSession(r, user.Id)
	if err != nil {
		http.Error(w, "", http.StatusInternalServerError)
		log.Printf("WriteSessions: %v", err)
		return
	}

	http.SetCookie(w, &cookie)
}

func (a *App) CreateSession(r *http.Request, uid int64) (http.Cookie, error) {
	session := data.Session{
		Id:      betterguid.New(),
		UserId:  uid,
		Created: time.Now(),
		IP:      GetIP(r),
	}

	err := a.DB.WriteSession(r.Context(), session)
	return http.Cookie{
		Name:     "X-Session-Token",
		Value:    session.Id,
		Path:     "/",
		MaxAge:   1 * 60 * 60,
		HttpOnly: true,
		Secure:   true,
		SameSite: http.SameSiteLaxMode,
	}, err

}

func GetIP(r *http.Request) string {
	forwarded := r.Header.Get("X-FORWARDED-FOR")
	for _, ip := range strings.Split(forwarded, ",") {
		return ip
	}
	return r.RemoteAddr
}

func (a *App) HandleRegister(w http.ResponseWriter, r *http.Request) {

	var request data.User

	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		http.Error(w, "Invalid json reuqest", http.StatusBadRequest)
		return
	}

	_, err = a.DB.ReadUserByEmail(r.Context(), request.Email)
	if !errors.Is(err, firestore.ErrNoSuchUser) {
		http.Error(w, "Username taken", http.StatusBadRequest)
		log.Printf("UserByName: %v", err)
		return
	}

	request.Id = hash(request.Email)
	request.Hash, err = HashPassword(request.Password)
	if err != nil {
		http.Error(w, "", http.StatusInternalServerError)
		log.Printf("Hashpassword: %v", err)
		return
	}

	err = a.DB.WriteUser(r.Context(), request)
	if err != nil {
		http.Error(w, "", http.StatusInternalServerError)
		log.Printf("WriteUser: %v", err)
		return
	}

	cookie, err := a.CreateSession(r, request.Id)
	if err != nil {
		http.Error(w, "", http.StatusInternalServerError)
		log.Printf("WriteSessions: %v", err)
		return
	}

	http.SetCookie(w, &cookie)
}

func (a *App) HandleValidate(w http.ResponseWriter, r *http.Request) {
	cookies := strings.Split(r.Header.Get("Cookie"), ";")

	token := ""
	for _, cookie := range cookies {
		t := strings.SplitN(string(cookie), "=", 2)
		if t[0] == "X-Session-Token" {
			token = t[1]
		}
	}

	session, err := a.DB.ReadSession(r.Context(), token)
	if err != nil {
		http.Error(w, "", http.StatusForbidden)
		log.Printf("GetSession: %v", err)
		return
	}

	fmt.Fprintf(w, "%d", session.UserId)
}
