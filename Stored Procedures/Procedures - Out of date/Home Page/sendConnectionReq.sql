DELIMITER $$
CREATE procedure sendConnectionReq(IN username VARCHAR(255), IN recipientUsername VARCHAR(255), IN message VARCHAR(255)) 
BEGIN
  	DECLARE User1ID INT DEFAULT 0;
	DECLARE User2ID INT DEFAULT 0;
    SELECT UserID INTO User1ID from usertable where UserName.usertable = requestorUsername;
    SELECT UserID INTO User2ID from usertable where UserName.usertable = recipientUsername;
    
    INSERT INTO connectionReq(ConnectorUser, ConnecteeUser, message)
    VALUES (User1ID, User2ID, message);

END $$
DELIMITER ;

