package ocr

import (
	"api/data"
	"testing"

	"github.com/google/go-cmp/cmp"
)

func TestParseKingSoopers(t *testing.T) {

	tests := []struct {
		lines     [][]string
		addr      string
		purchases []data.PurchaseLine
	}{
		{
			lines: [][]string{
				{"Soopers"},
				{"HOMETOWN", "GROCER", ".", "HOMETOWN", "TEAM"},
				{"3600", "TABLE", "MESA", "DR"},
				{"(", "303", ")", "499-4004", "Store"},
				{"Your", "cashier", "was", "CHEC", "502"},
				{"RGLD", "CHEDDAR", "CHS", "-", "$", "2.99", "B"},
				{"SC", "SOOPER", "SAVINGS", "0.70"},
				{"PRSL", "RIGATONI", "1.99", "B"},
				{"CHOBANI", "YOGURT", "XP", "6.49", "B"},
				{"KRO", "SAUSAGE", "4.99", "B"},
				{"PHLLY", "CREAM", "CHEESE", "4.79", "B"},
				{"DLRM", "SALSA", "-", "$", "3.79", "B"},
				{"SOOPER", "SAVINGS", "SC", "1.20"},
				{"FSEL", "SLICED", "MSHRM", "3.29", "B"},
				{"2.33", "lb", "@", "0.65", "/", "lb"},
				{"WT", "CHIQ", "BANANAS", "1.51", "B"},
				{"BLUEBRY", "ORG", "S", "3.88", "B"},
				{"SC", "SOOPER", "SAVINGS", "3.11"},
				{"DRIS", "RASPBRY", "3.29", "B"},
				{"DRIS", "BLCKBRY", "-", "$", "2.00", "B"},
				{"SC", "SOOPER", "SAVINGS", "0.59"},
				{"KRO", "APL", "PNK", "LDY", "4.99", "B"},
				{"DAVES", "KILLER", "BAGEL", "6.49", "B"},
				{"PECORINO", "ROMANO", "6.97", "B"},
				{"HORIZON", "HVY", "CREAM", "6.49", "B"},
				{"1", "@", "2", "/", "1.00"},
				{"GARLIC", "LARGE", "0.50", "B"},
				{"0.64", "lb", "@", "0.79", "/", "lb"},
				{"WT", "ONION", "YLW", "COLOSSAL", "0.51", "B"},
				{"Valued", "Customer", "*******", "0557"},
			},
			addr: "3600 TABLE MESA DR",
			purchases: []data.PurchaseLine{
				{
					PurchaseName: "RGLD CHEDDAR CHS",
					Price:        299,
				}, {

					PurchaseName: "PRSL RIGATONI",
					Price:        199,
				}, {
					PurchaseName: "CHOBANI YOGURT",
					Price:        649,
				}, {

					PurchaseName: "KRO SAUSAGE",
					Price:        499,
				}, {

					PurchaseName: "PHLLY CREAM CHEESE",
					Price:        479,
				}, {

					PurchaseName: "DLRM SALSA",
					Price:        379,
				}, {
					PurchaseName: "FSEL SLICED MSHRM",
					Price:        329,
				}, {
					PurchaseName: "CHIQ BANANAS",
					Price:        151,
				}, {
					PurchaseName: "BLUEBRY ORG",
					Price:        388,
				}, {
					PurchaseName: "DRIS RASPBRY",
					Price:        329,
				}, {
					PurchaseName: "DRIS BLCKBRY",
					Price:        200,
				}, {

					PurchaseName: "KRO APL PNK LDY",
					Price:        499,
				}, {
					PurchaseName: "DAVES KILLER BAGEL",
					Price:        649,
				}, {
					PurchaseName: "PECORINO ROMANO",
					Price:        697,
				}, {
					PurchaseName: "HORIZON HVY CREAM",
					Price:        649,
				}, {
					PurchaseName: "GARLIC LARGE",
					Price:        50,
				}, {
					PurchaseName: "ONION YLW COLOSSAL",
					Price:        51,
				},
			},
		},
	}

	for i, test := range tests {
		_, addr, _, purchases, err := ParseKingSoopers(test.lines)
		if err != nil {
			t.Errorf("Test %d: Failed unexpectedly: %v", i, err)
		}

		if addr != test.addr {
			t.Errorf("Test %d: Expected(%v) Got(%v)", i, test.addr, addr)
		}

		if diff := cmp.Diff(purchases, test.purchases); diff != "" {
			t.Errorf("Test %d: Found diff:\n%v", i, diff)
		}
	}
}
