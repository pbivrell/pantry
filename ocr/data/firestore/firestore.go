package firestore

import (
	"context"
	"fmt"
	"ocr/data"

	"cloud.google.com/go/firestore"
)

const (
	projectID      = "grocery-api-380005"
	authCollection = "service/auth/"
	userCollection = authCollection + "user/"
	tripDoc        = userCollection + "%d/trip/%d"
	summaryDoc     = userCollection + "%d/summary/%d"
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

func (c *Connection) WriteTrip(ctx context.Context, uid int, t data.TripFile) error {

	user := c.client.Doc(fmt.Sprintf(tripDoc, uid, t.Date.UnixNano()))

	_, err := user.Create(ctx, t)
	return err
}

func (c *Connection) WriteSummary(ctx context.Context, uid int, t data.TripFile) error {

	user := c.client.Doc(fmt.Sprintf(summaryDoc, uid, t.Date.UnixNano()))

	total := 0
	for _, v := range t.Purchases {
		total += v.Price
	}

	s := data.Summary{
		Date:  t.Date,
		Addr:  t.Addr,
		Total: total,
		Count: len(t.Purchases),
	}

	_, err := user.Create(ctx, s)
	return err
}
