create table gender (
    GenderID INT NOT NULL,
	Gender VARCHAR(255) NOT NULL,
    PRIMARY KEY(GenderID)
);
create table activities (
    ActivityID INT NOT NULL,
	Activity VARCHAR(255) NOT NULL,
    PRIMARY KEY(ActivityID)
);
create table usertype (
    UserTypeID INT NOT NULL,
    UserType VARCHAR(255) NOT NULL,
    PRIMARY KEY(UserTypeID)
);
create table usertable (
	UserID INT NOT NULL,
    UserTypeID INT NOT NULL,
    GenderID INT NOT NULL,
	UserName VARCHAR(255) NOT NULL,
	UserPassword VARCHAR(255) NOT NULL,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(10) NOT NULL,
    Age INT NOT NULL,
    About VARCHAR(255) NOT NULL,
    PRIMARY KEY(UserID),
    FOREIGN KEY (UserTypeID) REFERENCES usertype(UserTypeID),
    FOREIGN KEY (GenderID) REFERENCES gender(GenderID)
);
create table distance (
	UserID INT NOT NULL,
    Distance INT NOT NULL,
    PRIMARY KEY(UserID),
    FOREIGN KEY(UserID) REFERENCES usertable(UserID)
);

create table UserActivities (
    UserID INT NOT NULL,
	ActivityID INT NOT NULL,
    SkillLevel VARCHAR(255) NOT NULL,
    PRIMARY KEY(UserID, ActivityID),
    FOREIGN KEY (UserID) REFERENCES usertable(UserID),
    FOREIGN KEY (ActivityID) REFERENCES activities(ActivityID)
);
create table recent_locations (
	RecentLocationID INT NOT NULL,
    UserID INT NOT NULL,
    Latitude VARCHAR(255) NOT NULL,
	Longitude VARCHAR(255) NOT NULL,
	Timestamp VARCHAR(255) NOT NULL,
    City VARCHAR(255) NOT NULL,
    PRIMARY KEY(RecentLocationID),
    FOREIGN KEY (UserID) REFERENCES usertable(UserID)
);
create table userreview (
	UserReviewID INT NOT NULL,
    ReviewScore INT NOT NULL,
    PRIMARY KEY(UserReviewID)
);
create table reviews (
	ReviewID INT NOT NULL,
    ReviewerID INT NOT NULL,
    RevieweeID INT NOT NULL,
    PRIMARY KEY(ReviewID, ReviewerID, RevieweeID),
    FOREIGN KEY (ReviewerID) REFERENCES usertable(UserID),
	FOREIGN KEY (RevieweeID) REFERENCES usertable(UserID),
	FOREIGN KEY (ReviewID) REFERENCES userreview(UserReviewID)
);
create table reports (
	UserReportedID INT NOT NULL,
    ReportedUserID INT NOT NULL,
    ReporteeUserID INT NOT NULL,
    PRIMARY KEY(UserReportedID, ReportedUserID, ReporteeUserID),
    FOREIGN KEY (ReportedUserID) REFERENCES usertable(UserID),
	FOREIGN KEY (ReporteeUserID) REFERENCES usertable(UserID)
);
create table admins (
	AdminID INT NOT NULL,
    LoginName VARCHAR(255) NOT NULL,
    LoginPassword VARCHAR(255) NOT NULL,
    PRIMARY KEY(AdminID)
);
create table connectionrequest (
	ConnectionReqID INT NOT NULL,
    message VARCHAR(255) NOT NULL,
    PRIMARY KEY(ConnectionReqID)
);
create table connections (
	connectionID INT NOT NULL,
    message VARCHAR(255) NOT NULL,
    PRIMARY KEY(connectionID)
);
create table reportedusers (
	ReportedID INT NOT NULL,
    RportedDate DATETIME NOT NULL,
    UserComments INT NOT NULL,
	AdminID INT,
	AdminComments VARCHAR(255),
    PRIMARY KEY(ReportedID),
    FOREIGN KEY (AdminID) REFERENCES admins(AdminID),
	FOREIGN KEY (ReportedID) REFERENCES reports(UserReportedID)
);
create table sendconnectionrequest (
	SCRID INT NOT NULL,
    ConnectorUser INT NOT NULL,
    ConnecteeUser INT NOT NULL,
    PRIMARY KEY(SCRID, ConnectorUser, ConnecteeUser),
    FOREIGN KEY (SCRID) REFERENCES connectionrequest(ConnectionReqID),
	FOREIGN KEY (ConnectorUser) REFERENCES usertable(UserID),
	FOREIGN KEY (ConnecteeUser) REFERENCES usertable(UserID)
);
create table connections_cid (
	cID INT NOT NULL,
    User1 INT NOT NULL,
    User2 INT NOT NULL,
    PRIMARY KEY(cID, User1, User2),
    FOREIGN KEY (cID) REFERENCES connections(ConnectionID),
	FOREIGN KEY (User1) REFERENCES usertable(UserID),
	FOREIGN KEY (User2) REFERENCES usertable(UserID)
);
