DELIMITER $$
CREATE procedure rejectRequest(IN username VARCHAR(255), IN requestorUsername VARCHAR(255)) 
BEGIN

	DECLARE User1ID INT DEFAULT 0;
	DECLARE User2ID INT DEFAULT 0;
    SELECT UserID INTO User1ID from usertable where UserName.usertable = requestorUsername;
    SELECT UserID INTO User2ID from usertable where UserName.usertable = connecteeUsername;
    
    DELETE FROM connectionReq WHERE User1ID = connectorUser AND User2ID = connecteeUser;

END $$
DELIMITER ;

