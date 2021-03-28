DELIMITER $$
CREATE procedure getFriends(IN username VARCHAR(255)) 
BEGIN
	DECLARE userMID INT;
    SELECT UserID into userMID FROM usertable AS u WHERE u.UserName = username;
    (SELECT UserName FROM usertable AS u WHERE UserID IN
    (SELECT User2 FROM connections AS cid WHERE userMID = cid.User1))
    UNION
    (SELECT UserName FROM usertable AS u WHERE UserID IN
    (SELECT User1 FROM  connections AS cid WHERE userMID = cid.User2));
END $$
DELIMITER ;

