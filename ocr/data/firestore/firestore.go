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
