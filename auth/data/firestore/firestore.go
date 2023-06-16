package firestore

import (
	"auth/data"
	"context"
	"errors"
	"fmt"

	"cloud.google.com/go/firestore"
	"google.golang.org/api/iterator"
)

const (
	projectID         = "grocery-api-380005"
	authCollection    = "service/auth/"
	userCollection    = authCollection + "user/"
	sessionCollection = authCollection + "sessions/"
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

func (c *Connection) WriteUser(ctx context.Context, u data.User) error {

	user := c.client.Doc(fmt.Sprintf("%s%d", userCollection, u.Id))

	_, err := user.Create(ctx, u)
	return err
}

func (c *Connection) ReadUser(ctx context.Context, uid int64) (data.User, error) {

	var user data.User

	doc := c.client.Doc(fmt.Sprintf("%s%d", userCollection, uid))
	docsnap, err := doc.Get(ctx)
	if err != nil {
		return user, err
	}

	return user, docsnap.DataTo(&user)
}

var ErrNoSuchUser error = errors.New("no such user")

func (c *Connection) ReadUserByEmail(ctx context.Context, email string) (data.User, error) {

	var user data.User

	doc := c.client.Collection(fmt.Sprintf("%s", userCollection))

	if doc == nil {
		return data.User{}, ErrNoSuchUser
	}

	q := doc.Where("email", "==", email)

	iter := q.Documents(ctx)
	defer iter.Stop()
	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return data.User{}, err
		}

		return user, doc.DataTo(&user)
	}

	return data.User{}, ErrNoSuchUser
}

func (c *Connection) WriteSession(ctx context.Context, s data.Session) error {

	session := c.client.Doc(fmt.Sprintf("%s%s", sessionCollection, s.Id))
	_, err := session.Create(ctx, s)
	return err

}

func (c *Connection) ReadSession(ctx context.Context, sid string) (data.Session, error) {
	var session data.Session

	doc := c.client.Doc(fmt.Sprintf("%s%s", sessionCollection, sid))
	docsnap, err := doc.Get(ctx)
	if err != nil {
		return session, err
	}

	return session, docsnap.DataTo(&session)

}
