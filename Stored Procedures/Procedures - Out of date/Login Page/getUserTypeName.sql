DELIMITER $$
create procedure getUserType(IN username VARCHAR(255))
BEGIN
	SELECT UserType from activities_app.usertype as u
    JOIN usertable as ut ON u.UserTypeID = ut.UserTypeID;
END $$
DELIMITER ;