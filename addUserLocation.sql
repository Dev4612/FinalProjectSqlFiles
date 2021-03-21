DELIMITER $$
CREATE procedure addUserLocations(IN uname VARCHAR(255), IN latitude VARCHAR(255), IN longitude VARCHAR(255)) 
BEGIN
	INSERT INTO recent_locations (RecentLocationID, UserID, Latitude, Longitude, Timestamp) 
    VALUES (NULL, (select userid from usertable where usertable.userid = uname), latitude, longitude, CURRENT_TIMESTAMP);
END $$
DELIMITER ;

-- need to figure out how to only keep 10 entries
