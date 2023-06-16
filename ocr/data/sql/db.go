package data

import (
	"database/sql"
	"errors"
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

func ConnectIP() (*DB, error) {
	mustGetenv := func(k string) string {
		v := os.Getenv(k)
		if v == "" {
			log.Printf("%s environment variable not set.", k)
		}
		return v
	}
	var (
		dbUser         = mustGetenv("DB_USER")
		dbPwd          = mustGetenv("DB_PASS")
		dbName         = mustGetenv("DB_NAME")
		unixSocketPath = mustGetenv("DB_IP")
	)

	dbURI := fmt.Sprintf("%s:%s@tcp(%s)/%s?parseTime=true",
		dbUser, dbPwd, unixSocketPath, dbName)

	// dbPool is the pool of database connections.
	dbPool, err := sql.Open("mysql", dbURI)
	if err != nil {
		return nil, fmt.Errorf("sql.Open: %v", err)
	}

	return &DB{
		db: dbPool,
	}, nil
}

// connectUnixSocket initializes a Unix socket connection pool for
// a Cloud SQL instance of MySQL.
func ConnectUnixSocket() (*DB, error) {
	mustGetenv := func(k string) string {
		v := os.Getenv(k)
		if v == "" {
			log.Printf("%s environment variable not set.", k)
		}
		return v
	}
	// Note: Saving credentials in environment variables is convenient, but not
	// secure - consider a more secure solution such as
	// Cloud Secret Manager (https://cloud.google.com/secret-manager) to help
	// keep secrets safe.
	var (
		dbUser         = mustGetenv("DB_USER")              // e.g. 'my-db-user'
		dbPwd          = mustGetenv("DB_PASS")              // e.g. 'my-db-password'
		dbName         = mustGetenv("DB_NAME")              // e.g. 'my-database'
		unixSocketPath = mustGetenv("INSTANCE_UNIX_SOCKET") // e.g. '/cloudsql/project:region:instance'
	)

	dbURI := fmt.Sprintf("%s:%s@unix(%s)/%s?parseTime=true",
		dbUser, dbPwd, unixSocketPath, dbName)

	// dbPool is the pool of database connections.
	dbPool, err := sql.Open("mysql", dbURI)
	if err != nil {
		return nil, fmt.Errorf("sql.Open: %v", err)
	}

	return &DB{
		db: dbPool,
	}, nil
}

type DB struct {
	db *sql.DB
}

func (d *DB) GetUserByName(value string) (User, error) {
	query := `SELECT userID, username, hash FROM users WHERE username=?`
	return d.getUserByX(query, value)
}

func (d *DB) GetUserByID(value int) (User, error) {
	query := `SELECT userID, username, hash FROM users WHERE userID=?`
	return d.getUserByX(query, value)
}

func (d *DB) getUserByX(query string, value ...any) (User, error) {

	u := User{}

	res := d.db.QueryRow(query, value...)

	return u, res.Scan(&u.Id, &u.Username, &u.Hash)
}

func (d *DB) GetOrPutStoreTypeByName(value string) (StoreType, error) {
	st, err := d.GetStoreTypeByName(value)
	if err == nil {
		return st, nil
	}

	if !errors.Is(err, sql.ErrNoRows) {
		return st, err
	}

	return d.PutStoreType(value)
}

func (d *DB) PutStoreType(name string) (StoreType, error) {
	query := `INSERT INTO store_types (name) VALUES (?)`
	res, err := d.db.Exec(query, name)
	if err != nil {
		return StoreType{}, err
	}

	id, _ := res.LastInsertId()
	return StoreType{
		Id:   int(id),
		Name: name,
	}, err
}

func (d *DB) getStoreTypeByX(query string, value ...any) (StoreType, error) {

	u := StoreType{}

	res := d.db.QueryRow(query, value...)

	return u, res.Scan(&u.Id, &u.Name)
}

func (d *DB) GetStoreTypeByName(value string) (StoreType, error) {
	query := `SELECT storeTypeID, name FROM store_types WHERE name=?`
	return d.getStoreTypeByX(query, value)
}

func (d *DB) GetStoreTypeByID(value int) (StoreType, error) {
	query := `SELECT storeTypeID, name FROM store_types WHERE storeTypeID=?`
	return d.getStoreTypeByX(query, value)
}

func (d *DB) GetOrPutStoreByAddr(s Store) (Store, error) {
	st, err := d.GetStoreByAddr(s.Address)
	if err == nil {
		return st, nil
	}

	if !errors.Is(err, sql.ErrNoRows) {
		return st, err
	}

	return d.PutStore(s)
}

func (d *DB) PutStore(s Store) (Store, error) {
	query := `INSERT INTO stores (name, address, storeTypeID) VALUES (?, ?, ?)`
	res, err := d.db.Exec(query, s.Name, s.Address, s.StoreTypeId)
	if err != nil {
		return Store{}, err
	}

	id, _ := res.LastInsertId()
	s.Id = int(id)
	return s, err
}

func (d *DB) getStoreByX(query string, value ...any) (Store, error) {

	u := Store{}

	res := d.db.QueryRow(query, value...)

	return u, res.Scan(&u.Id, &u.Name, &u.Address, &u.StoreTypeId)
}

func (d *DB) GetStoreByName(value string) (Store, error) {
	query := `SELECT storeID, name, address, storeTypeID FROM stores WHERE name=?`
	return d.getStoreByX(query, value)
}

func (d *DB) GetStoreByID(value int) (Store, error) {
	query := `SELECT storeID, name, address, storeTypeID FROM stores WHERE storeID=?`
	return d.getStoreByX(query, value)
}

func (d *DB) GetStoreByAddr(value string) (Store, error) {
	query := `SELECT storeID, name, address, storeTypeID FROM stores WHERE address=?`
	return d.getStoreByX(query, value)
}

func (d *DB) PutTrip(s Trip) (Trip, error) {
	query := `INSERT INTO trips (storeID, userID, tripDate) VALUES (?, ?, ?)`
	res, err := d.db.Exec(query, s.StoreId, s.UserId, s.TripDate)
	if err != nil {
		return Trip{}, err
	}

	id, _ := res.LastInsertId()
	s.Id = int(id)
	return s, err
}

func (d *DB) getTripByX(query string, value ...any) (Trip, error) {

	u := Trip{}

	res := d.db.QueryRow(query, value...)

	return u, res.Scan(&u.Id, &u.StoreId, &u.UserId, &u.TripDate)
}

func (d *DB) GetTripByName(value string) (Trip, error) {
	query := `SELECT tripID, storeID, userID, tripDate FROM trips WHERE name=?`
	return d.getTripByX(query, value)
}

func (d *DB) GetTripByID(value int) (Trip, error) {
	query := `SELECT tripID, storeID, userID, tripDate FROM trips WHERE tripID=?`
	return d.getTripByX(query, value)
}

func (d *DB) GetOrPutCommonProductByName(value CommonProduct) (CommonProduct, error) {
	st, err := d.GetCommonProductByName(value.Name)
	if err == nil {
		return st, nil
	}

	if !errors.Is(err, sql.ErrNoRows) {
		return st, err
	}

	return d.PutCommonProduct(value)
}

func (d *DB) PutCommonProduct(s CommonProduct) (CommonProduct, error) {
	query := `INSERT INTO common_products ( name, icon) VALUES ( ?, ?)`
	res, err := d.db.Exec(query, s.Name, s.Icon)

	id, _ := res.LastInsertId()
	s.Id = int(id)
	return s, err
}

func (d *DB) getCommonProductByX(query string, value ...any) (CommonProduct, error) {

	u := CommonProduct{}

	res := d.db.QueryRow(query, value...)

	return u, res.Scan(&u.Id, &u.Name, &u.Icon)
}

func (d *DB) GetCommonProductByName(value string) (CommonProduct, error) {
	query := `SELECT commonProductID, name, icon FROM common_products WHERE name=?`
	return d.getCommonProductByX(query, value)
}

func (d *DB) GetCommonProductByID(value int) (CommonProduct, error) {
	query := `SELECT commonProductID, name, icon FROM common_products WHERE commonProductID=?`
	return d.getCommonProductByX(query, value)
}

func (d *DB) GetProductItems(value string) ([]ProductItem, error) {

	value = "%" + value + "%"

	query := `SELECT C.commonProductID, C.name, C.icon, FLOOR(AVG(P.price)) AS price FROM common_products C, purchases P WHERE lower(name) like ? AND C.commonProductID = P.commonProductID GROUP BY C.commonProductId;`
	stmt, err := d.db.Prepare(query)
	if err != nil {
		return []ProductItem{}, err
	}

	rows, err := stmt.Query(value)
	if err != nil {
		return []ProductItem{}, err
	}

	p := make([]ProductItem, 0)

	for rows.Next() {
		u := ProductItem{}

		err = rows.Scan(&u.CommonProductId, &u.Name, &u.Icon, &u.Price)
		if err != nil {
			return []ProductItem{}, err
		}
		p = append(p, u)
	}

	return p, err

}

func (d *DB) PutPurchase(s Purchase) (Purchase, error) {
	query := `INSERT INTO purchases (price, productIdentifier, commonProductID, tripID) VALUES (?, ?, ?, ?)`
	res, err := d.db.Exec(query, s.Price, s.ProductIdentifier, s.CommonProductId, s.TripId)
	if err != nil {
		return Purchase{}, err
	}

	id, _ := res.LastInsertId()
	s.Id = int(id)
	return s, err
}

func (d *DB) getPurchaseByX(query string, value ...any) (Purchase, error) {

	u := Purchase{}

	res := d.db.QueryRow(query, value...)

	return u, res.Scan(&u.Id, &u.Price, &u.ProductIdentifier, &u.CommonProductId, &u.TripId)
}

func (d *DB) GetPurchaseByProductIdentifier(value string) (Purchase, error) {
	query := `select purchaseID, price, productIdentifier, commonProductID, tripID from purchases where productIdentifier=? limit 1;`

	return d.getPurchaseByX(query, value)
}

func (d *DB) GetPurchaseByCommonProductId(value int) (Purchase, error) {
	query := `SELECT purchaseID, price, productIdentifier, commonProductID, tripID FROM purchases WHERE commonProductID=?`
	return d.getPurchaseByX(query, value)
}

func (d *DB) GetPurchaseByID(value int) (Purchase, error) {
	query := `SELECT purchaseID, price, productIdentifier, commonProductID, tripID FROM purchases WHERE purchaseID=?`
	return d.getPurchaseByX(query, value)
}

func (d *DB) PutMeal(s Meal) (Meal, error) {
	query := `INSERT INTO meals (name, info, origin) VALUES (?, ?, ?)`
	res, err := d.db.Exec(query, s.Name, s.Info, s.Origin)
	if err != nil {
		return Meal{}, err
	}

	id, _ := res.LastInsertId()
	s.Id = int(id)
	return s, err
}

func (d *DB) getMealByX(query string, value ...any) (Meal, error) {

	u := Meal{}

	res := d.db.QueryRow(query, value...)

	return u, res.Scan(&u.Id, &u.Name, &u.Info, &u.Origin)
}

func (d *DB) GetMealByID(value int) (Meal, error) {
	query := `SELECT mealID, name, info, origin FROM meals WHERE mealID=?`
	return d.getMealByX(query, value)
}

func (d *DB) GetMeals() ([]MealItem, error) {
	query := `SELECT mealID, name FROM meals;`
	stmt, err := d.db.Prepare(query)
	if err != nil {
		return []MealItem{}, err
	}

	rows, err := stmt.Query()
	if err != nil {
		return []MealItem{}, err
	}

	p := make([]MealItem, 0)

	for rows.Next() {
		u := MealItem{
			Date: time.Now(),
		}

		err = rows.Scan(&u.MealId, &u.Name)
		if err != nil {
			return []MealItem{}, err
		}
		p = append(p, u)
	}

	return p, err
}

/*
func (d *DB) PutMealCard(m MealCard) (MealCard, error) {

}

func (d *DB) GetMealCardByID(value int) (MealCard, error) {
}
*/

func (d *DB) PutMealIngredients(mealID int, commonProductIDs ...int) error {
	if len(commonProductIDs) < 1 {
		return nil
	}
	query := fmt.Sprintf(`INSERT INTO meal_ingredients (MealID, CommonProductID) VALUES %s`, strings.Repeat(`(?,?),`, len(commonProductIDs)))
	// Lop off trialing comma added by strings.Repeat
	query = query[:len(query)-1]
	vals := make([]any, len(commonProductIDs)*2)
	for i, v := range commonProductIDs {
		vals[i*2] = mealID
		vals[(i*2)+1] = v
	}

	_, err := d.db.Exec(query, vals...)
	return err
}
