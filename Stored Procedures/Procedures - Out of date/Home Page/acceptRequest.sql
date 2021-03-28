DELIMITER $$
CREATE procedure acceptRequest(IN connecteeUsername VARCHAR(255) , IN requestorUsername VARCHAR(255)) 
BEGIN
    DECLARE User1ID INT DEFAULT 0;
	DECLARE User2ID INT DEFAULT 0;
    DECLARE foundEntry INT DEFAULT 0;
    SELECT UserID INTO User1ID from usertable where UserName.usertable = requestorUsername;
    SELECT UserID INTO User2ID from usertable where UserName.usertable = connecteeUsername;
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
    
END $$
DELIMITER ;

