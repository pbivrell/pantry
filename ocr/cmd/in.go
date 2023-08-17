package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"sort"
	"strings"
	"time"

	"cloud.google.com/go/storage"
	vision "cloud.google.com/go/vision/apiv1"
	"google.golang.org/api/iterator"
)

func main() {
	translate()
}

func translate() {
	ctx := context.Background()
	s, err := storage.NewClient(ctx)
	if err != nil {
		fmt.Println(err)
		return
	}

	list, err := readNamesFromStorage(ctx, s)
	if err != nil {
		fmt.Println(err)
		return
	}

	data, err := readFromStorage(ctx, s, list[1])
	if err != nil {
		fmt.Println(err)
		return
	}

	var t []V
	err = json.NewDecoder(data).Decode(&t)
	if err != nil {
		fmt.Println(err)
		return
	}

	fmt.Println(list[1])
	lines := lineItems(t)
	fmt.Println(lines)
}

const (
	UnknownStore = iota
	KingSoopersStore
)

func identifyRecipt(lines [][]string) int {

	if wordsInOrder(lines, []string{"king", "soopers"}, 5) != -1 {
		return KingSoopersStore
	}
	return UnknownStore
}

type Item struct {
	Label string
	Price string
}

type Store struct {
	Addr  string
	Date  time.Time
	Items []Item
}

type KingSoopersMeta struct {
	Sales   []Item
	Phone   string
	Tax     int
	CardNum int
	Savings int
	Total   int
}

func wordsInOrder(lines [][]string, words []string, depth int) int {

	found := 0
	for i, line := range lines {
		for _, word := range line {
			if strings.ToLower(word) == strings.ToLower(words[found]) {
				found++
			}
			if found >= len(words) {
				return i
			}
		}
		if i >= depth {
			break
		}
	}
	return -1
}

func parseKingSoopers(lines [][]string) (Store, KingSoopersMeta, []error, error) {

	s := Store{}
	m := KingSoopersMeta{}

	start := wordsInOrder(lines, []string{"hometown", "grocer", "hometown", "team"}, 10)
	if start == -1 {
		return s, m, []error{}, fmt.Errorf("failed to find 'hometown grocer hometown team' starting point")
	}

	if len(lines) < start+4 {
		return s, m, []error{}, fmt.Errorf("missing recipt body")
	}

	s.Addr = strings.Join(lines[start+1], " ")
	m.Phone = strings.Join(lines[start+2], " ")
)
}

func bulkUpload(path string) {

	ctx := context.Background()

	v, err := vision.NewImageAnnotatorClient(ctx)
	if err != nil {
		fmt.Println(err)
		return
	}

	s, err := storage.NewClient(ctx)
	if err != nil {
		fmt.Println(err)
		return
	}
	defer s.Close()
	defer v.Close()

	files, err := ioutil.ReadDir(path)
	for _, f := range files {
		ctx, cancel := context.WithTimeout(ctx, time.Second*300)
		defer cancel()
		processFile(ctx, fmt.Sprintf("%s/%s", path, f.Name()), v, s)
	}
}

func processFile(ctx context.Context, file string, v *vision.ImageAnnotatorClient, s *storage.Client) {
	f, err := os.Open(file)
	if err != nil {
		fmt.Printf("failed open file %s: %v\n", file, err)
		return
	}
	defer f.Close()

	b := &bytes.Buffer{}

	tee := io.TeeReader(f, b)

	data, err := detectText(ctx, v, tee)
	if err != nil {
		fmt.Printf("failed detect %s: %v\n", file, err)
		return
	}

	dir := time.Now().UnixNano()

	err = writeToStorage(ctx, s, b, fmt.Sprintf("%d/image.jpg", dir))
	if err != nil {
		fmt.Printf("failed write image %s: %v\n", file, err)
		return
	}

	j := &bytes.Buffer{}

	err = json.NewEncoder(j).Encode(data)
	if err != nil {
		fmt.Printf("failed encoding err %s: %v\n", file, err)
		return
	}

	err = writeToStorage(ctx, s, j, fmt.Sprintf("%d/text.json", dir))
	if err != nil {
		fmt.Printf("failed write image %s: %v\n", file, err)
		return
	}
}

type Point struct {
	X int32 `json:"x"`
	Y int32 `json:"y"`
}

type V struct {
	Value    string  `json:"v"`
	Vertices []Point `json:"vs"`
	yLine    int32
	xLine    int32
}

func (v V) String() string {
	return fmt.Sprintf("%s", v.Value)
}

func lineItems(items []V) [][]string {
	_, items = items[0], items[1:]

	var height int32 = 0
	for i := range items {
		var big int32 = -1
		var small int32 = 1000000000
		for _, v := range items[i].Vertices {
			if v.Y > big {
				big = v.Y
			}
			if v.Y < small {
				small = v.Y
			}
			items[i].yLine += v.Y
			items[i].xLine += v.X
		}
		height += big - small
		items[i].yLine /= 4
		items[i].xLine /= 4
	}
	avgHeight := int(height) / int(len(items))

	sort.Slice(items, func(i, j int) bool {
		return items[i].yLine < items[j].yLine
	})

	lines := make([][]V, 0)
	line := make([]V, 0)
	for i := range items {
		// When previous Y sorted line is not with 1/2 the average word height
		// then it can be assumed we are on a new line.
		if i > 0 && items[i].yLine-items[i-1].yLine > int32(avgHeight*1/2) {
			lines = append(lines, line)
			line = make([]V, 0)
		}
		line = append(line, items[i])
	}

	for i := range lines {
		sort.Slice(lines[i], func(k, j int) bool {
			return lines[i][k].xLine < lines[i][j].xLine
		})
	}

	text := make([][]string, len(lines))
	for i, v := range lines {
		words := make([]string, len(v))
		for j, word := range v {
			words[j] = word.Value
		}
		text[i] = words
	}

	return text
}

func detectText(ctx context.Context, client *vision.ImageAnnotatorClient, r io.Reader) ([]V, error) {

	image, err := vision.NewImageFromReader(r)
	if err != nil {
		return []V{}, err
	}

	annotations, err := client.DetectTexts(ctx, image, nil, 10)
	if err != nil {
		return []V{}, err
	}

	values := make([]V, len(annotations))

	if len(annotations) == 0 {
		return values, fmt.Errorf("no data")
	} else {
		for i, annotation := range annotations {
			values[i].Value = annotation.Description
			for _, v := range annotation.BoundingPoly.Vertices {
				values[i].Vertices = append(values[i].Vertices, Point{
					X: v.X,
					Y: v.Y,
				})
			}
		}
	}

	return values, nil
}

func readNamesFromStorage(ctx context.Context, client *storage.Client) ([]string, error) {
	bucket := "grocery-dev-photostore"

	bkt := client.Bucket(bucket)

	query := &storage.Query{
		Prefix: "",
	}
	query.SetAttrSelection([]string{"Name"})

	it := bkt.Objects(ctx, query)
	names := make([]string, 0)
	for {
		attrs, err := it.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return nil, err
		}
		names = append(names, attrs.Name)
	}
	return names, nil
}

func readFromStorage(ctx context.Context, client *storage.Client, path string) (*bytes.Buffer, error) {
	bucket := "grocery-dev-photostore"
	b := &bytes.Buffer{}

	o := client.Bucket(bucket).Object(path)

	r, err := o.NewReader(ctx)
	if err != nil {
		return b, err
	}

	if _, err := io.Copy(b, r); err != nil {
		return b, err
	}

	return b, nil
}

func writeToStorage(ctx context.Context, client *storage.Client, r io.Reader, path string) error {
	bucket := "grocery-dev-photostore"

	o := client.Bucket(bucket).Object(path)
	o = o.If(storage.Conditions{DoesNotExist: true})

	// Upload an object with storage.Writer.
	wc := o.NewWriter(ctx)
	if _, err := io.Copy(wc, r); err != nil {
		return fmt.Errorf("io.Copy: %w", err)
	}
	if err := wc.Close(); err != nil {
		return fmt.Errorf("Writer.Close: %w", err)
	}
	return nil
}
