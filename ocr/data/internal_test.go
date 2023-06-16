package data

import (
	"bytes"
	"testing"
	"time"

	"github.com/google/go-cmp/cmp"
)

func TestRoundTrip(t *testing.T) {
	tests := []struct {
		tf TripFile
	}{
		{
			tf: TripFile{
				StoreType:    "King Soopers",
				Addr:         "300 Apple",
				PurchaseDate: time.Date(2009, time.November, 10, 23, 0, 0, 0, time.UTC),
				Purchases: []PurchaseLine{
					{
						CommonName:   "A",
						PurchaseName: "TAP",
						Price:        129,
					},
				},
			},
		},
	}

	for i, test := range tests {

		var buf bytes.Buffer
		err := test.tf.Write(&buf)
		if err != nil {
			t.Errorf("Test %d: %v", i, err)
			continue
		}

		tf, err := TripFile{}.Read(&buf)
		if err != nil {
			t.Errorf("Test %d: %v", i, err)
			continue
		}

		if diff := cmp.Diff(test.tf, tf); diff != "" {
			t.Errorf("Test %d: diff:\n%v", i, diff)
		}
	}
}
