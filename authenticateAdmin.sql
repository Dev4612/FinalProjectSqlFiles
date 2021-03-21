DELIMITER $$
create procedure authenticateAdmin(IN adminname VARCHAR(255), IN adminpassword VARCHAR(255), OUT authentication INT)
BEGIN
	SELECT count(*) INTO authentication from activities_app.admins as a
    WHERE a.LoginName = adminname AND a.LoginPassword = adminpassword;
END $$
DELIMITER ;