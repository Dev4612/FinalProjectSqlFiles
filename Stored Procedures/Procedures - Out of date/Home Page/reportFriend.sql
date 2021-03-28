DELIMITER $$
CREATE procedure reportFriend(IN username VARCHAR(255), IN reportedFriendUsername VARCHAR(255), IN message VARCHAR(255)) 
BEGIN
	DECLARE User1ID INT DEFAULT 0;
	DECLARE User2ID INT DEFAULT 0;
    DECLARE maxRID INT;
    SELECT max(ReportedID) INTO maxRID FROM reports;
    SELECT UserID INTO User1ID from usertable where UserName.usertable = username;
    SELECT UserID INTO User2ID from usertable where UserName.usertable = reportedFriendUsername;
    
    INSERT INTO reports(ReportedID, ReportedUserID, ReporteeUserID)
    VALUES((maxRID + 1), User2ID, User1ID);
    
    INSERT INTO reportedusers(ReportedID, ReportedDate, UserComments) 
    VALUES ((maxRID + 1), CURRENT_TIMESTAMP, message);
    
END $$
DELIMITER ;

