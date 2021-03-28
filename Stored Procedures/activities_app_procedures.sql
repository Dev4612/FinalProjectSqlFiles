DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `acceptRequest`(IN connecteeUsername VARCHAR(255) , IN requestorUsername VARCHAR(255))
BEGIN
    DECLARE User1ID INT DEFAULT 0;
	DECLARE User2ID INT DEFAULT 0;
    DECLARE foundEntry INT DEFAULT 0;
    SELECT UserID INTO User2ID from usertable where usertable.UserName = connecteeUsername;
    SELECT UserID INTO User1ID from usertable where usertable.UserName = requestorUsername;
    SELECT count(*) INTO foundEntry from activities_app.usertable 
	WHERE usertable.UserName = username;    
    IF foundEntry >  0 THEN
		DELETE from connectionReq 
        WHERE connectionReq.connectorUser = User1ID AND connectionReq.connecteeUser = User2ID;
		INSERT into connections(User1, User2) 
        VALUES (User1ID, User2ID);
	ELSE
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Request doesnt exist';
	END IF;
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `ADD_ACTIVITY`(IN Input_username VARCHAR(255), IN New_activity VARCHAR(255), IN New_SkillLevel VARCHAR(255))
BEGIN
	INSERT INTO UserActivities(UserID, ActivityID, SkillLevel) 
    VALUES ((select userid from usertable where usertable.UserName = Input_username),(select ActivityID from activities where Activity = New_activity),
    New_SkillLevel);
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `addUserLocations`(IN uname VARCHAR(255), IN latitude VARCHAR(255), IN longitude VARCHAR(255))
BEGIN
	DECLARE userMID INT;
    SELECT UserID into userMID FROM usertable AS u WHERE u.UserName = uname;
    INSERT INTO recent_locations (UserID, Latitude, Longitude, Timestamp) 
    VALUES (userMID, latitude, longitude, CURRENT_TIMESTAMP);
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `authenticateAdmin`(IN adminname VARCHAR(255), IN adminpassword VARCHAR(255), OUT authentication INT)
BEGIN
	SELECT count(*) INTO authentication from activities_app.admins as a
    WHERE a.LoginName = adminname AND a.LoginPassword = adminpassword;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `authenticateUser`(IN username VARCHAR(255), IN userpassword VARCHAR(255), OUT authentication INT)
BEGIN
	SELECT count(*) INTO authentication from activities_app.usertable as u
    WHERE u.UserName = username AND u.UserPassword = userpassword;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `createUser`(IN uname VARCHAR(255), IN upassword VARCHAR(255), IN utype VARCHAR(255), IN gender VARCHAR(255), IN firstName VARCHAR(255), 
									IN lastName VARCHAR(255), IN phoneNumber VARCHAR(255), IN age INT, IN about VARCHAR(255))
BEGIN

	DECLARE foundEntry INT DEFAULT 0;
	DECLARE max_uid INT DEFAULT 0;
    SELECT max(UserID) INTO max_uid from usertable;
	SELECT count(*) INTO foundEntry from activities_app.usertable 
	WHERE usertable.UserName = uname;

	IF foundEntry >  0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User already exists';
	ELSE
		INSERT into usertable(UserID, UserTypeID, GenderID, UserName, UserPassword, FirstName, LastName, PhoneNumber, Age, About) 
        VALUES ((max_uid + 1),
				(SELECT usertype.UserTypeID from activities_app.usertype WHERE usertype.UserType = utype),
                (SELECT GenderID from activities_app.gender WHERE gender.Gender = gender),
                uname, upassword, firstName, lastName, phoneNumber, age, about);
                
       INSERT into distance(UserID, Distance)
       VALUES ((max_uid + 1), 30);
	END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `DELETE_USER`()
BEGIN
#delete from : user(userid), reports(reporteduserid OR reporteeuserid), reportedusers(based on the reports(userreviewID) that was deleted),
# Distance(userid), useractiviities(userid), reviews(rewieverid OR revieweeid), userreview(based on reviews(reviewID) find the uservewivewid)
# sendconnectionrequest(connectoreuser OR conecteeuser), connectionrequest(based on sendconnection request SCRID), connections_cid(user1 OR user2) 
# connections (based on CID from connections_CID)
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `GET_ACTIVITIES`(IN Input_username VARCHAR(255))
BEGIN
	select Activity, SkillLevel from usertable as u natural join UserActivities as ua natural join activities as a where UserName = Input_username;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `GET_DISTANCE`(IN Input_username VARCHAR(255))
BEGIN
#get the distance given a username
select d.Distance from usertable as u natural join distance as d where UserName = Input_username 
and u.UserID = (select u2.userid from usertable as u2 where u2.UserName = u.UserName);

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `GET_UNCHECKED_REPORTS`()
BEGIN
	select rd.ReportedID,u.username, TimesReported, rd.UserComments
	from reportedusers as rd join reports as r on r.UserReportedID = rd.ReportedID
    inner join (select UserReportedID,ReportedUserID,count(ReportedUserID) as TimesReported from reports group by ReportedUserID) as cnt on cnt.ReportedUserID = r.ReportedUserID
    join usertable as u on u.UserId = cnt.ReportedUserID
    WHERE AdminID IS NULL;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `getFriends`(IN uname VARCHAR(255))
BEGIN
	DECLARE userMID INT;
    SELECT UserID into userMID FROM usertable AS u WHERE u.UserName = uname;
    
    (SELECT 
		u.UserName, distance.Distance 
	FROM 
		usertable AS u 
		JOIN distance ON u.UserID = distance.UserID
	WHERE 
		u.UserID IN (SELECT User2 FROM connections AS cid WHERE cid.User1 = userMID))
    UNION
    (SELECT
		u.UserName, distance.Distance 
	FROM 
		usertable AS u
        JOIN distance ON u.UserID = distance.UserID
	WHERE 
		u.UserID IN (SELECT User1 FROM  connections AS cid WHERE cid.User2 = userMID));
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `getLocation`(IN uname VARCHAR(255))
BEGIN
  	DECLARE UserMID INT DEFAULT 0;
    SELECT UserID INTO UserMID from usertable where usertable.UserName = uname;
    
    SELECT 
		u.UserName, rl.Latitude, rl.Longitude, rl.Timestamp 
    FROM 
		usertable AS u
		JOIN recent_locations AS rl ON u.UserID = rl.UserID
    WHERE
		rl.UserID = UserMID AND rl.Timestamp = (SELECT MAX(rl2.Timestamp) FROM recent_locations As rl2 WHERE rl2.UserID = rl.UserID);

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `getMatches`(IN uname VARCHAR(255))
BEGIN
	DECLARE userMID INT;
    SELECT UserID into userMID FROM usertable AS u WHERE u.UserName = uname;
	SELECT
		u.UserName, di.Distance, rl.Latitude, 
        rl.Longitude, rl.Timestamp
	FROM
		usertable AS u
		JOIN recent_locations AS rl ON u.UserID = rl.UserID
        JOIN distance AS di ON u.UserID = di.UserID
    WHERE 
		u.UserName <> uname
		AND rl.Timestamp = (SELECT MAX(rl2.Timestamp) FROM recent_locations As rl2 WHERE rl2.UserID = rl.UserID)
        AND u.UserName NOT IN 
				((SELECT 
					u.UserName
				FROM 
					usertable AS u 
				WHERE 
					u.UserID IN (SELECT User2 FROM connections AS cid WHERE cid.User1 = userMID))
				UNION
				(SELECT
					u.UserName
				FROM 
					usertable AS u
				WHERE 
					u.UserID IN (SELECT User1 FROM  connections AS cid WHERE cid.User2 = userMID)))
		AND u.UserName NOT IN 
					(SELECT usertable.UserName from usertable 
					JOIN connectionReq ON connectionReq.connectorUser = usertable.UserID
					WHERE usertable.UserID IN
						(SELECT cReq.ConnectorUser from (SELECT * from connectionReq
							WHERE ConnecteeUser = (SELECT UserID from usertable where usertable.UserName = uname)) as cReq));
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `getUserType`(IN username VARCHAR(255))
BEGIN
	SELECT UserType from activities_app.usertype as u
    JOIN usertable as ut ON u.UserTypeID = ut.UserTypeID
    where ut.UserName = username;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `incomingFriendRequests`(IN uname VARCHAR(255))
BEGIN
	
	SELECT usertable.UserName, connectionReq.message from usertable 
    
    JOIN connectionReq ON connectionReq.connectorUser = usertable.UserID
    
    WHERE usertable.UserID IN
		(SELECT cReq.ConnectorUser from (SELECT * from connectionReq
			WHERE ConnecteeUser = (SELECT UserID from usertable where usertable.UserName = uname)) as cReq);
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `rejectRequest`(IN username VARCHAR(255), IN requestorUsername VARCHAR(255))
BEGIN

	DECLARE User1ID INT DEFAULT 0;
	DECLARE User2ID INT DEFAULT 0;
    SELECT UserID INTO User1ID from usertable where usertable.UserName = requestorUsername;
    SELECT UserID INTO User2ID from usertable where usertable.UserName = username;
    
    DELETE FROM connectionReq WHERE connectorUser = User1ID AND connecteeUser = User2ID;
	
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `REMOVE_ACTIVITY`(IN Input_username VARCHAR(255), IN Del_activity VARCHAR(255))
BEGIN
	delete ua from UserActivities as ua natural join activities as a natural join usertable as ut 
	where Activity = Del_activity AND UserName = Input_username and ut.UserID = (select userid from usertable where usertable.UserName = Input_username);
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `reportFriend`(IN username VARCHAR(255), IN reportedFriendUsername VARCHAR(255), IN message VARCHAR(255))
BEGIN
	DECLARE User1ID INT DEFAULT 0;
	DECLARE User2ID INT DEFAULT 0;
    DECLARE maxRID INT;
    SELECT max(ReportedID) INTO maxRID FROM reports;
    SELECT UserID INTO User1ID from usertable where usertable.UserName = username;
    SELECT UserID INTO User2ID from usertable where usertable.UserName = reportedFriendUsername;
    
    INSERT INTO reports(ReportedID, ReportedUserID, ReporteeUserID)
    VALUES((maxRID + 1), User2ID, User1ID);
    
    INSERT INTO reportedusers(ReportedID, ReportedDate, UserComments) 
    VALUES ((maxRID + 1), CURRENT_TIMESTAMP, message);
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `RESOLVE_REPORT`(IN adminUsername VARCHAR(255),IN reportRowPrimaryKey int, IN adminComments VARCHAR(255))
BEGIN
	update reportedusers as r set r.AdminId = (select AdminId from admins where LoginName = adminUsername), r.AdminComments = adminComments
	where r.ReportedID = reportRowPrimaryKey; 
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `reviewFriend`(IN username VARCHAR(255), IN friendUsername VARCHAR(255), IN score VARCHAR(255))
BEGIN
	DECLARE User1ID INT DEFAULT 0;
	DECLARE User2ID INT DEFAULT 0;
    DECLARE maxR INT;
    SELECT max(UserReviewID) INTO maxR FROM userreview;
    SELECT UserID INTO User1ID from usertable where usertable.UserName = username;
    SELECT UserID INTO User2ID from usertable where usertable.UserName = friendUsername;
    
    INSERT INTO userreview(UserReviewID, ReviewScore) 
    VALUES ((maxR + 1),
			score);
    
    INSERT INTO reviews(ReviewID, ReviewerID, RevieweeID)
    VALUES((maxR + 1), User1ID, User2ID);
    
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `sendConnectionReq`(IN requestorUsername VARCHAR(255), IN recipientUsername VARCHAR(255), IN message VARCHAR(255))
BEGIN
  	DECLARE User1ID INT DEFAULT 0;
	DECLARE User2ID INT DEFAULT 0;
    SELECT UserID INTO User1ID from usertable where usertable.UserName = requestorUsername;
    SELECT UserID INTO User2ID from usertable where usertable.UserName = recipientUsername;
    
    INSERT INTO connectionReq(ConnectorUser, ConnecteeUser, message)
    VALUES (User1ID, User2ID, message);

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `SET_DISTANCE`(IN Input_username VARCHAR(255), IN New_distance int)
BEGIN
#May need to fix this, only lets an update go if you give it a primary key in where clasue

update distance as d join usertable as u set Distance = New_distance where UserName = Input_username 
and d.userid = (select userid from usertable where usertable.UserName = Input_username); 

END$$
DELIMITER ;