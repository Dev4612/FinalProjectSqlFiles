DELIMITER $$
CREATE procedure incomingFriendRequests(IN username VARCHAR(255)) 
BEGIN
	DECLARE UserXID INT DEFAULT 0;
    SELECT UserID INTO UserXID from usertable where UserName.usertable = username;
    
    SELECT connectionReq.* FROM connectionReq WHERE connecteeUser = UserXID;
    
END $$
DELIMITER ;

