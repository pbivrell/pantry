package firestore

import (
	"context"
	"exposer/data"
	"fmt"
	"strconv"

	"cloud.google.com/go/firestore"
	"google.golang.org/api/iterator"
)

const (
	projectID         = "grocery-api-380005"
	authCollection    = "service/auth/"
	userCollection    = authCollection + "user/"
	summaryCollection = userCollection + "%d/summary"
	tripDoc           = userCollection + "%d/trip/%d"
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

func (c *Connection) GetTrip(ctx context.Context, uid, tid int) (data.TripFile, error) {

	trip := data.TripFile{
		ID: tid,
	}

	doc := c.client.Doc(fmt.Sprintf(tripDoc, uid, tid))
	docsnap, err := doc.Get(ctx)
	if err != nil {
		return trip, err
	}

	return trip, docsnap.DataTo(&trip)
}

func (c *Connection) GetSummarys(ctx context.Context, uid int) ([]data.Summary, error) {

	summarys := make([]data.Summary, 0)

	collection := fmt.Sprintf(summaryCollection, uid)
	doc := c.client.Collection(collection)

	if doc == nil {
		return summarys, fmt.Errorf("no collection found: %v", collection)
	}

	var lastErr error
	iter := doc.Documents(ctx)
	defer iter.Stop()
	for {
		d, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			lastErr = err
		}

		id, _ := strconv.ParseInt(d.Ref.ID, 10, 64)

		sum := &data.Summary{
			ID: int(id),
		}

		if err = d.DataTo(sum); err != nil {
			lastErr = err
		} else {
			summarys = append(summarys, *sum)
		}
	}

	return summarys, lastErr
}
