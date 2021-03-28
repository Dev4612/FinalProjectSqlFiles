DELIMITER $$
CREATE procedure getLocation(IN uname VARCHAR(255)) 
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

END $$
DELIMITER ;

