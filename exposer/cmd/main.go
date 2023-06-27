package main

import (
	"context"
	"encoding/json"
	"exposer/data/firestore"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/gorilla/mux"

	"cloud.google.com/go/logging"
)

const (
	authAPI   = "https://grocery-auth-dev-7osudstnga-uc.a.run.app/validate"
	projectID = "grocery-api-380005"
)

func main() {

	ctx := context.Background()

	// Creates a client.
	client, err := logging.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}
	defer client.Close()

	// Sets the name of the log to write to.
	logName := "exposer-debug"

	logger := client.Logger(logName).StandardLogger(logging.Info)

	db, err := firestore.Connect(ctx)
	if err != nil {
		fmt.Printf("Broken: %v\n", err)
		return
	}
	defer db.Close()

	app := NewApp(logger, db)

	r := mux.NewRouter()

	apiR := r.PathPrefix("/api").Subrouter()
	apiR.Use(app.AuthMiddleware)
	apiR.HandleFunc("/recipt", app.HandleRecipt())
	apiR.HandleFunc("/summary", app.HandleRecipts())

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
	logger *log.Logger
	DB     *firestore.Connection
}

func NewApp(logger *log.Logger, db *firestore.Connection) *App {
	return &App{
		logger: logger,
		DB:     db,
	}
}

func (a *App) GetUserFromSession(cookie string) (int, bool) {
	cookies := strings.Split(cookie, ";")

	token := ""
	for _, cookie := range cookies {
		t := strings.SplitN(string(cookie), "=", 2)
		if t[0] == "X-Session-Token" {
			token = t[1]
		}
	}

	fmt.Println("Token", token)

	if token == "" {
		return 0, false
	}

	req, err := http.NewRequest("GET", authAPI, nil)
	if err != nil {
		fmt.Printf("%v\n", err)
		return 0, false
	}

	req.Header.Add("Cookie", fmt.Sprintf(`X-Session-Token=%s`, token))

	client := &http.Client{}

	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("%v\n", err)
		return 0, false
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Printf("%v\n", err)
		return 0, false
	}

	fmt.Println("Hey: ", string(body))

	resp.Body.Close()

	id, err := strconv.Atoi(string(body))
	if err != nil {
		fmt.Printf("%v\n", err)
		return 0, false
	}

	return id, true
}

func (a *App) AuthMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		a.logger.Println("Headers", r.Header)

		if _, ok := a.GetUserFromSession(r.Header.Get("Cookie")); ok {
			next.ServeHTTP(w, r)
		} else {
			http.Error(w, "Forbidden", http.StatusForbidden)
		}
	})
}

func (a *App) HandleRecipts() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		user, _ := a.GetUserFromSession(r.Header.Get("Cookie"))
		summarys, err := a.DB.GetSummarys(r.Context(), user)
		if err != nil {
			http.Error(w, "", http.StatusInternalServerError)
			a.logger.Println("failed to get summaries: %v", err)
			return
		}

		err = json.NewEncoder(w).Encode(summarys)
		if err != nil {
			http.Error(w, "", http.StatusInternalServerError)
			a.logger.Println("failed to marshal summaries: %v", err)
			return
		}
	}
}

func (a *App) HandleRecipt() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		tid, err := strconv.ParseInt(r.URL.Query().Get("tid"), 10, 64)
		if err != nil {
			http.Error(w, "", http.StatusBadRequest)
			a.logger.Printf("failed to get query param: %v", err)
			return
		}

		user, _ := a.GetUserFromSession(r.Header.Get("Cookie"))
		summarys, err := a.DB.GetTrip(r.Context(), user, int(tid))
		if err != nil {
			http.Error(w, "", http.StatusInternalServerError)
			a.logger.Println("failed to get summaries: %v", err)
			return
		}

		err = json.NewEncoder(w).Encode(summarys)
		if err != nil {
			http.Error(w, "", http.StatusInternalServerError)
			a.logger.Println("failed to marshal summaries: %v", err)
			return
		}
	}
}
