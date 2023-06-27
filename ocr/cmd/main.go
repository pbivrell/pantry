package main

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"ocr/data/firestore"
	"ocr/ocr"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/gorilla/mux"

	"cloud.google.com/go/logging"
	"cloud.google.com/go/storage"
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
	logName := "ocr-debug"

	logger := client.Logger(logName).StandardLogger(logging.Info)

	logger.Println("Hey we have logging enabled")

	app := NewApp(logger)

	r := mux.NewRouter()

	apiR := r.PathPrefix("/api").Subrouter()
	apiR.Use(app.AuthMiddleware)
	apiR.HandleFunc("/ocr", app.HandlePhotoUpload())

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
}

func NewApp(logger *log.Logger) *App {
	return &App{
		logger: logger,
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

func (a *App) HandlePhotoUpload() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		err := r.ParseMultipartForm(32 << 20) // maxMemory 32MB
		if err != nil {
			http.Error(w, "", http.StatusBadRequest)
			fmt.Printf("ocr error: %v\n", err)
			return
		}
		//Access the photo key - First Approach
		file, _, err := r.FormFile("photo")
		if err != nil {
			http.Error(w, "", http.StatusBadRequest)
			fmt.Printf("ocr error: %v\n", err)
			return
		}

		var buf bytes.Buffer

		tee := io.TeeReader(file, &buf)

		lines, err := ocr.DetectText(tee, 10)
		if err != nil {
			http.Error(w, "", http.StatusInternalServerError)
			fmt.Printf("ocr error: %v\n", err)
			return
		}

		fmt.Println(lines)

		tripFile, errs := ocr.ParseKingSoopers(lines)
		if err != nil {
			fmt.Printf("parse error: %v\n", errs)
			return
		}

		c, err := firestore.Connect(r.Context())
		if err != nil {
			fmt.Printf("ocr firestore connect failed: %v\n", err)
			http.Error(w, "", http.StatusInternalServerError)
			return
		}

		uid, ok := a.GetUserFromSession(r.Header.Get("Cookie"))
		if !ok {
			fmt.Printf("somehow unauthed")
			http.Error(w, "", http.StatusInternalServerError)
			return
		}

		err = c.WriteTrip(r.Context(), uid, tripFile)
		if err != nil {
			fmt.Printf("failed to write ocr trip: %v", err)
		}

		err = writeToStorage(r.Context(), &buf, uid, len(errs))
		if err != nil {
			fmt.Printf("failed to backup image: %v\n", err)
		}

		err = c.WriteSummary(r.Context(), uid, tripFile)
		if err != nil {
			fmt.Printf("failed to write ocr summary: %v\n", err)
		}

	}
}

func writeToStorage(ctx context.Context, file io.Reader, uid, errors int) error {
	bucket := "groceryui-photostore"
	object := fmt.Sprintf("%d-%d-%d.png", time.Now().UnixNano(), uid, errors)

	client, err := storage.NewClient(ctx)
	if err != nil {
		return fmt.Errorf("storage.NewClient: %w", err)
	}
	defer client.Close()

	ctx, cancel := context.WithTimeout(ctx, time.Second*50)
	defer cancel()

	o := client.Bucket(bucket).Object(object)

	// Optional: set a generation-match precondition to avoid potential race
	// conditions and data corruptions. The request to upload is aborted if the
	// object's generation number does not match your precondition.
	// For an object that does not yet exist, set the DoesNotExist precondition.
	o = o.If(storage.Conditions{DoesNotExist: true})
	// If the live object already exists in your bucket, set instead a
	// generation-match precondition using the live object's generation number.
	// attrs, err := o.Attrs(ctx)
	// if err != nil {
	//      return fmt.Errorf("object.Attrs: %w", err)
	// }
	// o = o.If(storage.Conditions{GenerationMatch: attrs.Generation})

	// Upload an object with storage.Writer.
	wc := o.NewWriter(ctx)
	if _, err = io.Copy(wc, file); err != nil {
		return fmt.Errorf("io.Copy: %w", err)
	}
	if err := wc.Close(); err != nil {
		return fmt.Errorf("Writer.Close: %w", err)
	}
	return nil
}
