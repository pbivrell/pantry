package ocr

import (
	"context"
	"fmt"
	"io"
	"math"
	"ocr/data"
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

	// y axis of center of the bound box mapping to list of annonation keys that are on that axis
	// {
	//    0: [1 ]
	//    1: [1 ]
	//    2: [1 2]
	//    3: [2 ]
	//    4: [ ]
	// }
	lines := make(map[int][]int)

	// Mapping of key to text
	words := map[int]string{}

	for key, annotation := range annotations {

		if key == 0 {
			continue
		}

		// average bounding box y's
		yLine := 0
		for _, corner := range annotation.BoundingPoly.GetVertices() {
			yLine += int(corner.Y)
		}
		yLine = int(yLine / 4)

		// create a spread of +/- error range
		for i := yLine - errRange; i < yLine+errRange; i++ {
			v, _ := lines[i]
			v = append(v, key)
			lines[i] = v
		}

		// create mapping of key to text
		words[key] = annotation.Description
	}

	values := make([]int, len(lines))

	// set of possible y axis
	i := 0
	for k := range lines {
		values[i] = k
		i++
	}

	// sorted set of possible y axis values
	sort.Ints(values)

	// Pairs of values that indicate when a new y-axis line starts and stops
	ranges := make([]int, 0)

	// When the y axis values are none contigious that means they we've found a new
	// pair so we should mark when the previous block ended and when the new one began
	prev := -2
	for _, value := range values {
		if prev+1 != value {
			ranges = append(ranges, prev, value)
		}
		prev = value
	}

	// Discard first value because it's always not going to match
	ranges = ranges[1:]

	// the last y axis is the last pairs end point
	ranges = append(ranges, values[len(values)-1])

	//
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

func ParseKingSoopers(lines [][]string) (data.TripFile, []error) {

	errs := make([]error, 0)

	currentLine := 0
	var line []string
	for currentLine, line = range lines {
		if strings.ToLower(line[0]) == "hometown" {
			break
		}
	}
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

			if tok == "@" || strings.ToLower(tok) == "sc" || strings.ToLower(tok) == "t" {
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
			errs = append(errs, err)
		}
		priceFloat = math.Abs(priceFloat)

		p.Price = int(priceFloat * 100)
		p.PurchaseName = strings.Join(validToks[0:len(validToks)-1], " ")
		purchases = append(purchases, p)
	}

	return data.TripFile{
		Addr:      addr,
		Date:      time.Now(),
		Purchases: purchases,
	}, errs
}
