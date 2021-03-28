
create table connectionReq (
	conRID INT NOT NULL AUTO_INCREMENT,
    ConnectorUser INT NOT NULL,
    ConnecteeUser INT NOT NULL,
    message VARCHAR(255) NOT NULL,
    PRIMARY KEY(conRID, ConnectorUser, ConnecteeUser),
	FOREIGN KEY (ConnectorUser) REFERENCES usertable(UserID),
	FOREIGN KEY (ConnecteeUser) REFERENCES usertable(UserID)
);
create table connections (
	cID INT NOT NULL AUTO_INCREMENT,
    User1 INT NOT NULL,
    User2 INT NOT NULL,
    PRIMARY KEY(cID, User1, User2),
	FOREIGN KEY (User1) REFERENCES usertable(UserID),
	FOREIGN KEY (User2) REFERENCES usertable(UserID)
);
