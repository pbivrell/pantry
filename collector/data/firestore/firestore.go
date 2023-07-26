package firestore

import (
	"collector/data"
	"context"
	"fmt"
	"strconv"

	"cloud.google.com/go/firestore"
	"google.golang.org/api/iterator"
)

const (
	projectID       = "grocery-api-380005"
	authCollection  = "service/auth/"
	storeCollection = "service/product/store"
	productDoc      = "service/product/products/%d"
	userCollection  = authCollection + "user"
	tripDoc         = userCollection + "/%d/trip"
	userSummaryDoc  = userCollection + "/%d/products/%d"
	storeSummaryDoc = storeCollection + "/%d/products/%d"
)

type Connection struct {
	client *firestore.Client
}

func Connect(ctx context.Context) (*Connection, error) {

	client, err := firestore.NewClient(ctx, projectID)
	if err != nil {
		return nil, err
	}

	return &Connection{
		client: client,
	}, nil
}

func (c *Connection) Close() {
	c.client.Close()
}

func (c *Connection) getUserIDs(ctx context.Context) ([]int64, error) {

	var ids []int64

	doc := c.client.Collection(userCollection)

	if doc == nil {
		return ids, fmt.Errorf("no collection found: %v", userCollection)
	}

	iter := doc.Documents(ctx)
	defer iter.Stop()
	for {
		d, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return ids, err
		}

		id, _ := strconv.ParseInt(d.Ref.ID, 10, 64)
		ids = append(ids, id)
	}
	return ids, nil
}

func (c *Connection) GetAll(ctx context.Context) ([]data.TripFile, error) {

	summarys := make([]data.TripFile, 0)

	ids, err := c.getUserIDs(ctx)
	if err != nil {
		return summarys, err
	}

	for _, id := range ids {
		collection := fmt.Sprintf(tripDoc, id)
		doc := c.client.Collection(collection)

		if doc == nil {
			return summarys, fmt.Errorf("no collection found: %v", userCollection)
		}

		iter := doc.Documents(ctx)
		defer iter.Stop()
		for {
			d, err := iter.Next()
			if err == iterator.Done {
				break
			}
			if err != nil {
				return summarys, err
			}

			trip := &data.TripFile{
				User: id,
			}

			if err = d.DataTo(trip); err != nil {
				return summarys, err
			} else {
				summarys = append(summarys, *trip)
			}
		}

	}
	return summarys, nil
}

func (c *Connection) WriteUserSummary(ctx context.Context, data map[int64]map[int64]data.Product) []error {
	return c.WriteSummary(ctx, userSummaryDoc, data)
}

func (c *Connection) WriteStoreSummary(ctx context.Context, data map[int64]map[int64]data.Product) []error {
	return c.WriteSummary(ctx, storeSummaryDoc, data)
}

func (c *Connection) WriteSummary(ctx context.Context, path string, data map[int64]map[int64]data.Product) []error {

	errs := make([]error, 0)
	for k, v := range data {
		for j, w := range v {
			user := c.client.Doc(fmt.Sprintf(path, k, j))
			_, err := user.Create(ctx, w)
			if err != nil {
				errs = append(errs, err)
			}
		}
	}

	return errs
}

func (c *Connection) WriteProducts(ctx context.Context, data map[int64]data.ProductID) []error {
	errs := make([]error, 0)

	for k, v := range data {
		user := c.client.Doc(fmt.Sprintf(productDoc, k))
		_, err := user.Create(ctx, v)
		if err != nil {
			errs = append(errs, err)
		}
	}
	return errs
}
