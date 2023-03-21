package data

import (
	"bufio"
	"fmt"
	"io"
	"strconv"
	"strings"
	"time"
)

type PurchaseLine struct {
	CommonName   string
	PurchaseName string
	Price        int
}

type TripFile struct {
	StoreType    string
	Addr         string
	PurchaseDate time.Time
	Purchases    []PurchaseLine
}

func (t TripFile) Write(w io.Writer) error {
	_, err := w.Write([]byte(fmt.Sprintf("%s\n", t.StoreType)))
	if err != nil {
		return err
	}

	_, err = w.Write([]byte(fmt.Sprintf("%s\n", t.Addr)))
	if err != nil {
		return err
	}

	dateString := t.PurchaseDate.Format("01/02/06 15:04")
	_, err = w.Write([]byte(fmt.Sprintf("%s\n", dateString)))
	if err != nil {
		return err
	}

	for _, p := range t.Purchases {
		line := fmt.Sprintf("%q, %q, %0.2f\n", p.CommonName, p.PurchaseName, float64(p.Price)/float64(100))
		_, err := w.Write([]byte(line))
		if err != nil {
			return err
		}
	}

	return nil
}

func (TripFile) Read(r io.Reader) (TripFile, error) {

	reader := bufio.NewScanner(r)
	reader.Scan()
	storeType := reader.Text()

	reader.Scan()
	addr := reader.Text()
	reader.Scan()
	dateLine := reader.Text()

	date, err := time.Parse("01/02/06 15:04", dateLine)
	if err != nil {
		return TripFile{}, err
	}

	purchases := make([]PurchaseLine, 0)
	for reader.Scan() {
		line := reader.Text()
		items := strings.Split(line, ",")

		commonName := strings.Split(items[0], `"`)[1]
		productName := strings.Split(items[1], `"`)[1]
		floatPrice, _ := strconv.ParseFloat(strings.TrimPrefix(items[2], ` `), 64)
		price := int(floatPrice * 100)

		purchases = append(purchases, PurchaseLine{
			CommonName:   commonName,
			PurchaseName: productName,
			Price:        price,
		})
	}

	return TripFile{
		StoreType:    storeType,
		Addr:         addr,
		PurchaseDate: date,
		Purchases:    purchases,
	}, err
}
