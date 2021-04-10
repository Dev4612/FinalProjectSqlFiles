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
CREATE DEFINER=`admin`@`%` PROCEDURE `DELETE_USER`(IN adminUsername VARCHAR(255), IN usernameOfUserToDelete VARCHAR(255), IN reportRowPrimaryKey int )
BEGIN

#user reviews
delete r,ur from usertable as u join reviews as r on r.ReviewerID = u.UserID join userreview as ur on ur.UserReviewID = r.ReviewID where u.username = usernameOfUserToDelete;
delete r,ur from usertable as u join reviews as r on r.RevieweeID = u.UserID join userreview as ur on ur.UserReviewID = r.ReviewID where u.username = usernameOfUserToDelete;

#delete connection requests
delete cr1 from usertable as u join connectionReq as cr1 on cr1.ConnectorUser = u.userID where u.username = usernameOfUserToDelete;
delete cr2 from usertable as u join connectionReq as cr2 on cr2.ConnecteeUser = u.userID where u.username = usernameOfUserToDelete;

#delete connections
delete cc1 from usertable as u join connections as cc1 on cc1.User1 = u.userID where u.username = usernameOfUserToDelete;
delete cc2 from usertable as u join connections as cc2 on cc2.User2 = u.userID where u.username = usernameOfUserToDelete;
 
#reports and reportedusers (both reporter and reported)
delete rp,ru from reports as rp natural join reportedusers as ru where rp.ReportedUserID = (select UserID from usertable where UserName = usernameOfUserToDelete)
 or rp.ReporteeUserID = (select UserID from usertable where UserName = usernameOfUserToDelete);
 
#usertable,distance,useractivities, recent locations
delete from recent_locations where userID = (select UserID from usertable where UserName = usernameOfUserToDelete);
delete from distance where userID = (select UserID from usertable where UserName = usernameOfUserToDelete);
delete from UserActivities where userID = (select UserID from usertable where UserName = usernameOfUserToDelete);
delete from usertable where UserName = usernameOfUserToDelete;

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
CREATE DEFINER=`admin`@`%` PROCEDURE `GET_RATING`(IN uname VARCHAR(255))
BEGIN
	select AVG(reviewScore) from reviews as r join userreview as ur on ReviewID = UserReviewID where RevieweeID = (select userId from usertable where username = uname);
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `GET_UNCHECKED_REPORTS`()
BEGIN
	select rd.ReportedID,u.username, TimesReported, rd.UserComments
	from reportedusers as rd natural join reports as r
    inner join (select ReportedID,ReportedUserID,count(ReportedUserID) as TimesReported from reports group by ReportedUserID) as cnt on cnt.ReportedUserID = r.ReportedUserID
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
		u.UserName, u.FirstName, u.LastName, u.Age, u.PhoneNumber, u.About, di.Distance, rl.Latitude, 
        rl.Longitude, rl.Timestamp, act.Activity, ua.SkillLevel
	FROM 
		usertable AS u 
		JOIN recent_locations AS rl ON u.UserID = rl.UserID
        JOIN distance AS di ON u.UserID = di.UserID
        JOIN UserActivities AS ua ON u.UserID = ua.UserID
        JOIN activities AS act ON ua.ActivityID = act.ActivityID
	WHERE 
		u.UserID IN (SELECT User2 FROM connections AS cid WHERE cid.User1 = userMID)
        AND rl.Timestamp = (SELECT MAX(rl2.Timestamp) FROM recent_locations As rl2 WHERE rl2.UserID = rl.UserID))
    UNION
    (SELECT
		u.UserName, u.FirstName, u.LastName, u.Age, u.PhoneNumber, u.About, di.Distance, rl.Latitude, 
        rl.Longitude, rl.Timestamp, act.Activity, ua.SkillLevel
	FROM 
		usertable AS u
        JOIN recent_locations AS rl ON u.UserID = rl.UserID
        JOIN distance AS di ON u.UserID = di.UserID
        JOIN UserActivities AS ua ON u.UserID = ua.UserID
        JOIN activities AS act ON ua.ActivityID = act.ActivityID
	WHERE 
		u.UserID IN (SELECT User1 FROM  connections AS cid WHERE cid.User2 = userMID)
        AND rl.Timestamp = (SELECT MAX(rl2.Timestamp) FROM recent_locations As rl2 WHERE rl2.UserID = rl.UserID));
    
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
        rl.Longitude, rl.Timestamp, act.Activity, ua.SkillLevel
	FROM
		usertable AS u
		JOIN recent_locations AS rl ON u.UserID = rl.UserID
        JOIN distance AS di ON u.UserID = di.UserID
        JOIN UserActivities AS ua ON u.UserID = ua.UserID
        JOIN activities AS act ON ua.ActivityID = act.ActivityID
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
					((SELECT 
						u.UserName 
					FROM 
						usertable AS u
					WHERE 
						u.UserID IN (SELECT cReq.ConnecteeUser FROM connectionReq AS cReq WHERE cReq.ConnectorUser = UserMID))
					UNION
                    (SELECT 
						u.UserName 
					FROM 
						usertable AS u
					WHERE 
						u.UserID IN (SELECT cReq.ConnectorUser FROM connectionReq AS cReq WHERE cReq.ConnecteeUser = UserMID)))
                        
                        
					
					
		ORDER BY 
			u.UserID;
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
	
	SELECT 
		u.UserName, connectionReq.message, di.Distance, rl.Latitude, 
        rl.Longitude, rl.Timestamp, act.Activity, ua.SkillLevel, connectionReq.conRID
	FROM
		connectionReq -- , usertable AS u    
 		JOIN usertable as u ON connectionReq.connectorUser = u.UserID
        JOIN recent_locations AS rl ON u.UserID = rl.UserID
		JOIN distance AS di ON u.UserID = di.UserID
        JOIN UserActivities AS ua ON u.UserID = ua.UserID
        JOIN activities AS act ON ua.ActivityID = act.ActivityID
        
    WHERE 
	connectionReq.ConnecteeUser = (SELECT UserID FROM usertable AS u WHERE u.UserName = uname)
--    u.UserID IN (SELECT cReq.ConnectorUser from connectionReq AS cReq WHERE cReq.ConnecteeUser = (SELECT UserID FROM usertable AS u WHERE u.UserName = uname))
-- 		(SELECT cReq.ConnectorUser from (SELECT * from connectionReq
-- 			WHERE ConnecteeUser = (SELECT UserID from usertable where usertable.UserName = uname)) as cReq)
	AND rl.Timestamp = (SELECT MAX(rl2.Timestamp) FROM recent_locations As rl2 WHERE rl2.UserID = rl.UserID);
    
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
    
	INSERT INTO reportedusers(ReportedID, ReportedDate, UserComments) 
    VALUES ((maxRID + 1), CURRENT_TIMESTAMP, message);
    
    INSERT INTO reports(ReportedID, ReportedUserID, ReporteeUserID)
    VALUES((maxRID + 1), User2ID, User1ID);
    
    DELETE FROM connections AS c 
    WHERE 
		(c.User1 = User1ID AND c.User2 = User2ID) OR (c.User1 = User2ID AND c.User2 = User1ID);
    
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
CREATE DEFINER=`admin`@`%` PROCEDURE `reviewFriend`(IN username VARCHAR(255), IN friendUsername VARCHAR(255), IN score DECIMAL(2,1))
BEGIN
	DECLARE User1ID INT DEFAULT 0;
	DECLARE User2ID INT DEFAULT 0;
    DECLARE maxR INT;
    SELECT max(UserReviewID) INTO maxR FROM userreview;
    SELECT UserID INTO User1ID from usertable where usertable.UserName = username;
    SELECT UserID INTO User2ID from usertable where usertable.UserName = friendUsername;
    
    IF(score > 0 AND score <= 5.0) THEN    
		INSERT INTO userreview(UserReviewID, ReviewScore, Timestamp) 
		VALUES ((maxR + 1),
				score, CURRENT_TIMESTAMP);
		
		INSERT INTO reviews(ReviewID, ReviewerID, RevieweeID)
		VALUES((maxR + 1), User1ID, User2ID);
	ELSE 
    		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid score entered';
	END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`admin`@`%` PROCEDURE `sendConnectionReq`(IN requestorUsername VARCHAR(255), IN recipientUsername VARCHAR(255), IN message VARCHAR(255))
BEGIN

  	DECLARE User1ID INT DEFAULT 0;
	DECLARE User2ID INT DEFAULT 0;
    DECLARE ConnectionFound1 INT DEFAULT 0;
    DECLARE ConnectionFound2 INT DEFAULT 0;
    SELECT UserID INTO User1ID from usertable where usertable.UserName = requestorUsername;
    SELECT UserID INTO User2ID from usertable where usertable.UserName = recipientUsername;
    
    SELECT count(*) INTO ConnectionFound1 FROM connectionReq AS cr WHERE (cr.ConnectorUser = User1ID AND cr.ConnecteeUser = User2ID);
	SELECT count(*) INTO ConnectionFound2 FROM connectionReq AS cr WHERE (cr.ConnectorUser = User2ID AND cr.ConnecteeUser = User1ID);
    
    IF (ConnectionFound1 > 0 OR ConnectionFound2 > 0) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Request already exists';
	ELSE
		INSERT INTO connectionReq(ConnectorUser, ConnecteeUser, message)
		VALUES (User1ID, User2ID, message);
	END IF;
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
