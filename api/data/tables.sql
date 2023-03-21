create table IF NOT EXISTS store_types(
	storeTypeID INT NOT NULL AUTO_INCREMENT,
	name VARCHAR(100),
	PRIMARY KEY ( storeTypeID )
);

create table IF NOT EXISTS stores(
	storeID INT NOT NULL AUTO_INCREMENT,
	name VARCHAR(100),
	address VARCHAR(200),
	storeTypeID INT,
	PRIMARY KEY ( storeID ),
	FOREIGN KEY ( storeTypeID ) REFERENCES store_types( storeTypeID )
);

create table IF NOT EXISTS common_products(
	commonProductID INT NOT NULL AUTO_INCREMENT,
	name VARCHAR(100) NOT NULL,
	icon VARCHAR(200) NOT NULL,
	PRIMARY KEY ( commonProductID )
);

create table IF NOT EXISTS users(
	userID INT NOT NULL AUTO_INCREMENT,
	username VARCHAR(32) NOT NULL,
	hash VARCHAR(100) NOT NULL,
	PRIMARY KEY ( userID )
);

create table IF NOT EXISTS trips(
	tripID INT NOT NULL AUTO_INCREMENT,
	storeID INT NOT NULL,
	userID INT,
	tripDate DATETIME,
	PRIMARY KEY ( tripID ),
	FOREIGN KEY ( storeID ) REFERENCES stores( storeID ),
	FOREIGN KEY (  userID ) REFERENCES users( userID )
);

create table IF NOT EXISTS purchases(
	purchaseID INT NOT NULL AUTO_INCREMENT,
	price INT,
	productIdentifier VARCHAR(200),
	commonProductID INT,
	tripID INT,
	PRIMARY KEY ( purchaseID ),
	FOREIGN KEY ( commonProductID ) REFERENCES common_products( commonProductID ),
	FOREIGN KEY ( tripID ) REFERENCES trips( tripID )
);

