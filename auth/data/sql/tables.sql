create table IF NOT EXISTS users(
	userID INT NOT NULL AUTO_INCREMENT,
	name VARCHAR(100),
	email VARCHAR(100),
	password VARCHAR(100),
	PRIMARY KEY ( userID )
);

create table IF NOT EXISTS sessions(
	sessionID INT NOT NULL AUTO_INCREMENT,
	userID INT,
	created DATETIME,
	ip  VARCHAR(100),
	PRIMARY KEY ( storeID ),
	FOREIGN KEY ( userID ) REFERENCES users( userID )
);
