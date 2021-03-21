DELIMITER $$
create procedure authenticateUser(IN username VARCHAR(255), IN userpassword VARCHAR(255), OUT authentication INT)
BEGIN
	SELECT count(*) INTO authentication from activities_app.user as u
    WHERE u.UserName = username AND u.UserPassword = userpassword;
END $$
DELIMITER ;