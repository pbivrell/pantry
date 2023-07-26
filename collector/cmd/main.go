package main

import (
	"collector/data"
	"collector/data/firestore"
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/mux"

	"cloud.google.com/go/logging"
)

const (
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
	logName := "collector-debug"

	logger := client.Logger(logName).StandardLogger(logging.Info)

	db, err := firestore.Connect(ctx)
	if err != nil {
		fmt.Printf("Broken: %v\n", err)
		return
	}
	defer db.Close()

	app := NewApp(logger, db)

	r := mux.NewRouter()

	r.HandleFunc("/gather", app.HandleGather())

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

func (a *App) HandleGather() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		ctx := context.Background()

		trips, err := a.DB.GetAll(ctx)
		if err != nil {
			http.Error(w, "", http.StatusInternalServerError)
			a.logger.Println("failed to get all products: %v", err)
			return
		}

		pMap := make(map[int64]data.ProductID)
		upMap := make(map[int64]map[int64]data.Product)
		spMap := make(map[int64]map[int64]data.Product)

		for _, trip := range trips {
			addr := data.Hash(trip.Addr)
			date := trip.Visit
			if date.IsZero() {
				date = trip.Date
			}

			if _, exists := spMap[addr]; !exists {
				spMap[addr] = make(map[int64]data.Product)
			}

			if _, exists := upMap[trip.User]; !exists {
				upMap[trip.User] = make(map[int64]data.Product)
			}

			for _, purchase := range trip.Purchases {

				pHash := data.Hash(purchase.PurchaseName)
				pMap[pHash] = data.ProductID{
					Name: purchase.PurchaseName,
				}
				p, exists := upMap[trip.User][pHash]
				if !exists {
					p = data.Product{
						ID:        purchase.PurchaseName,
						Purchases: []data.Purchase{},
					}
				}
				p.Purchases = append(p.Purchases, data.Purchase{
					Amount: purchase.Price,
					Date:   date,
				})
				upMap[trip.User][pHash] = p

				var x data.Product
				x, exists = spMap[addr][pHash]
				if !exists {
					x = data.Product{
						ID:        purchase.PurchaseName,
						Purchases: []data.Purchase{},
					}
				}
				x.Purchases = append(x.Purchases, data.Purchase{
					Amount: purchase.Price,
					Date:   date,
				})
				spMap[addr][pHash] = x
			}
		}

		errs := a.DB.WriteProducts(ctx, pMap)
		for _, err := range errs {
			fmt.Println("failed to write: %v", err)
		}

		/*
			errs := a.DB.WriteUserSummary(ctx, upMap)
			for _, err := range errs {
				fmt.Println("failed to write: %v", err)
			}
			errs = a.DB.WriteStoreSummary(ctx, spMap)
			for _, err := range errs {
				fmt.Println("failed to write: %v", err)
			}*/
	}
}
