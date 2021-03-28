DELIMITER $$
CREATE procedure getMatches(IN username VARCHAR(255)) 
BEGIN
    SELECT
		usertable.UserName, distance.Distance, recent_locations.Latitude, 
        recent_locations.Longitude, recent_locations.Timestamp
	FROM
		usertable AS u, distace AS di, recent_locations AS rl
		JOIN distance ON u.UserID = di.UserID
		JOIN recent_locations ON u.UserID = rl.UserID
    WHERE 
		u.UserName = username;
END $$
DELIMITER ;

