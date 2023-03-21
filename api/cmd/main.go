package main

import (
	"api/data"
	"api/ocr"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/gorilla/mux"
	"github.com/kjk/betterguid"
	"golang.org/x/crypto/bcrypt"
)

const (
	UnknownProduct = "unknow"
	TripDir        = "./trips"
)

func main() {

	//db, err := data.ConnectUnixSocket()
	db, err := data.ConnectIP()
	if err != nil {
		log.Fatalf("Failed to create db: %v", err)
	}
	app := NewApp(db)

	r := mux.NewRouter()
	r.HandleFunc("/login", app.HandleLogin)

	apiR := r.PathPrefix("/api").Subrouter()
	apiR.Use(app.AuthMiddleware)
	apiR.HandleFunc("/products/search/{product}", app.HandleProductSearch())
	apiR.HandleFunc("/products/search/", app.HandleProductSearch())
	apiR.HandleFunc("/products/search", app.HandleProductSearch())
	apiR.HandleFunc("/trip/upload/file", app.HandleTripUpload())
	apiR.HandleFunc("/trip/upload/photo", app.HandlePhotoUpload())

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
	SessionStore map[string]int
	DB           *data.DB
}

func NewApp(db *data.DB) *App {
	return &App{
		SessionStore: map[string]int{
			"alwaysvalid": 1,
		},
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

func (a *App) HandleLogin(w http.ResponseWriter, r *http.Request) {

	request := struct {
		User     string `json:"user"`
		Password string `json:"password"`
	}{}

	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		http.Error(w, "Invalid json reuqest", http.StatusBadRequest)
		return
	}

	user, err := a.DB.GetUserByName(request.User)
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

	session := betterguid.New()

	a.SessionStore[session] = user.Id

	cookie := http.Cookie{
		Name:     "X-Session-Token",
		Value:    session,
		Path:     "/",
		MaxAge:   1 * 60 * 60,
		HttpOnly: true,
		Secure:   true,
		SameSite: http.SameSiteLaxMode,
	}

	http.SetCookie(w, &cookie)
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

	id, ok := a.SessionStore[token]
	return id, ok
}

func (a *App) AuthMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		if _, ok := a.GetUserFromSession(r.Header.Get("Cookie")); ok {
			next.ServeHTTP(w, r)
		} else {
			http.Error(w, "Forbidden", http.StatusForbidden)
		}
	})
}

func (a *App) HandleProductSearch() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		vars := mux.Vars(r)
		term, _ := vars["product"]

		term = strings.ToLower(term)

		purchases, err := a.DB.GetProductItems(term)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			fmt.Printf("Database %v\n", err)
			return
		}

		err = json.NewEncoder(w).Encode(purchases)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
	}
}

func (a *App) HandlePhotoUpload() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		//d, _ := ioutil.ReadAll(r.Body)
		//fmt.Println(string(d))
		//return

		lines, err := ocr.DetectText(r.Body, 10)
		if err != nil {
			http.Error(w, "", http.StatusInternalServerError)
			fmt.Printf("ocr error: %v\n", err)
			return
		}
		tripFile, err := ocr.ParseKingSoopers(lines)
		if err != nil {
			http.Error(w, "", http.StatusInternalServerError)
			fmt.Printf("parse error: %v\n", err)
			return
		}

		err = a.FetchExistingCommonProducts(&tripFile)
		if err != nil {
			http.Error(w, "", http.StatusInternalServerError)
			fmt.Printf("fetch db error: %v\n", err)
			return
		}

		userID, _ := a.GetUserFromSession(r.Header.Get("Cookie"))

		tripID, err := a.UploadTripFile(tripFile, userID, -1)
		if err != nil {
			http.Error(w, "", http.StatusInternalServerError)
			fmt.Printf("Upload error: %v\n", err)
			return
		}

		f, err := os.Create(fmt.Sprintf("%s/%d", TripDir, tripID))
		if err != nil {
			fmt.Printf("Save file err: %v\n", err)
			return
		}
		defer f.Close()
		tripFile.Write(f)

		resp := struct {
			Written int `json:"written"`
		}{
			Written: len(tripFile.Purchases),
		}

		err = json.NewEncoder(w).Encode(resp)
		if err != nil {
			http.Error(w, "", http.StatusInternalServerError)
			fmt.Printf("Upload error: %v\n", err)
			return
		}
	}
}

func (a *App) FetchExistingCommonProducts(t *data.TripFile) error {
	for i, p := range t.Purchases {
		purchase, err := a.DB.GetPurchaseByProductIdentifier(p.PurchaseName)
		t.Purchases[i].CommonName = UnknownProduct

		if errors.Is(err, sql.ErrNoRows) {
			continue
		}

		if err != nil {
			return err
		}

		commonProduct, err := a.DB.GetCommonProductByID(purchase.CommonProductId)
		if err != nil {
			return err
		}

		t.Purchases[i].CommonName = commonProduct.Name
	}
	return nil
}

func (a *App) HandleTripUpload() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		t, err := data.TripFile{}.Read(r.Body)
		if err != nil {
			http.Error(w, "", http.StatusInternalServerError)
			fmt.Printf("Upload error: %v\n", err)
			return
		}

		userID, _ := a.GetUserFromSession(r.Header.Get("Cookie"))

		_, err = a.UploadTripFile(t, userID, -1)
		if err != nil {
			http.Error(w, "", http.StatusInternalServerError)
			fmt.Printf("Upload error: %v\n", err)
			return
		}
	}
}

func (a *App) UploadTripFile(t data.TripFile, userID, tripID int) (int, error) {
	storeType, err := a.DB.GetOrPutStoreTypeByName(t.StoreType)
	if err != nil {
		return 0, err
	}

	store, err := a.DB.GetOrPutStoreByAddr(data.Store{
		Name:        "",
		Address:     t.Addr,
		StoreTypeId: storeType.Id,
	})
	if err != nil {
		return 0, err
	}

	if tripID == -1 {
		trip, err := a.DB.PutTrip(data.Trip{
			StoreId:  store.Id,
			UserId:   userID,
			TripDate: t.PurchaseDate,
		})
		if err != nil {
			return 0, err
		}
		tripID = trip.Id
	}

	for _, purchase := range t.Purchases {

		cp, err := a.DB.GetOrPutCommonProductByName(data.CommonProduct{
			Name: purchase.CommonName,
			Icon: "",
		})
		if err != nil {
			return 0, err
		}

		_, err = a.DB.PutPurchase(data.Purchase{
			Price:             purchase.Price,
			ProductIdentifier: purchase.PurchaseName,
			CommonProductId:   cp.Id,
			TripId:            tripID,
		})

		if err != nil {
			return 0, err
		}
	}
	return tripID, nil
}
