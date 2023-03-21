package ocr

import (
	"api/data"
	"context"
	"fmt"
	"io"
	"math"
	"sort"
	"strconv"
	"strings"
	"time"

	vision "cloud.google.com/go/vision/apiv1"
)

func DetectText(r io.Reader, errRange int) ([][]string, error) {
	ctx := context.Background()

	client, err := vision.NewImageAnnotatorClient(ctx)
	if err != nil {
		return [][]string{}, err
	}

	image, err := vision.NewImageFromReader(r)
	if err != nil {
		return [][]string{}, err
	}
	annotations, err := client.DetectTexts(ctx, image, nil, 10)
	if err != nil {
		return [][]string{}, err
	}

	if len(annotations) == 0 {
		return [][]string{}, fmt.Errorf("no data in image")
	}

	lines := make(map[int][]int)

	words := map[int]string{}

	for key, annotation := range annotations {

		if key == 0 {
			continue
		}

		yLine := 0
		for _, corner := range annotation.BoundingPoly.GetVertices() {
			yLine += int(corner.Y)
		}
		yLine = int(yLine / 4)

		for i := yLine - errRange; i < yLine+errRange; i++ {
			v, _ := lines[i]
			v = append(v, key)
			lines[i] = v
		}

		words[key] = annotation.Description
		//fmt.Fprintf(w, "%q\n", annotation.Description)
		//fmt.Fprintf(w, "%q\n", annotation.BoundingPoly)
	}

	ranges := make([]int, 0)
	values := make([]int, len(lines))

	i := 0
	for k := range lines {
		values[i] = k
		i++
	}

	sort.Ints(values)

	prev := -2
	for _, value := range values {
		if prev+1 != value {
			ranges = append(ranges, prev, value)
		}
		prev = value
	}
	ranges = ranges[1:]
	ranges = append(ranges, values[len(values)-1])

	lineItems := make([]map[int]struct{}, len(ranges)/2)
	for i := 0; i < len(ranges); i += 2 {
		for j := ranges[i]; j < ranges[i+1]; j++ {
			m := lineItems[i/2]
			if m == nil {
				m = make(map[int]struct{})
			}
			for _, v := range lines[j] {
				m[v] = struct{}{}
			}
			lineItems[i/2] = m
		}
	}

	finalLines := make([][]string, len(lineItems))
	for j, line := range lineItems {
		x := make([]int, len(line))
		i := 0
		for k := range line {
			x[i] = k
			i++
		}
		sort.Ints(x)

		finalLines[j] = make([]string, len(x))
		for p, word := range x {
			finalLines[j][p] = words[word]
		}
	}

	return finalLines, nil
}

func ParseKingSoopers(lines [][]string) (data.TripFile, error) {

	currentLine := 0
	var line []string
	for currentLine, line = range lines {
		if len(line) == 1 && strings.ToLower(line[0]) == "soopers" {
			break
		}
	}

	// Eat Soopers line
	currentLine++

	// Skip HOMETOWN GROCER . HOMETOWN TEAM
	currentLine++

	addr := strings.Join(lines[currentLine], " ")
	// Eat the addr line
	currentLine++

	// Skip phone #
	currentLine++

	// Skip Your cashier was...
	currentLine++

	stripToks := map[string]struct{}{
		"wt": {},
		"-":  {},
		"$":  {},
		"s":  {},
		"b":  {},
		"xp": {},
	}

	purchases := make([]data.PurchaseLine, 0)

	for ; currentLine < len(lines); currentLine++ {

		p := data.PurchaseLine{}

		validToks := make([]string, 0)

		doneParsing, ignoreLine := false, false
		for _, tok := range lines[currentLine] {
			if strings.ToLower(tok) == "valued" {
				doneParsing = true
			}

			if tok == "@" || strings.ToLower(tok) == "sc" {
				ignoreLine = true
				break
			}

			if _, ok := stripToks[strings.ToLower(tok)]; !ok {
				validToks = append(validToks, tok)
			}
		}

		if ignoreLine {
			continue
		}

		if doneParsing {
			break
		}

		priceFloat, err := strconv.ParseFloat(validToks[len(validToks)-1], 64)
		if err != nil {
			return data.TripFile{}, err
		}
		priceFloat = math.Abs(priceFloat)

		p.Price = int(priceFloat * 100)
		p.PurchaseName = strings.Join(validToks[0:len(validToks)-1], " ")
		purchases = append(purchases, p)
	}

	return data.TripFile{
		StoreType:    "King Soopers",
		Addr:         addr,
		PurchaseDate: time.Now(),
		Purchases:    purchases,
	}, nil
}
