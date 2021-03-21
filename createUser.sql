DELIMITER $$
CREATE procedure createUser(IN uname VARCHAR(255), IN upassword VARCHAR(255), IN utype VARCHAR(255), IN gender VARCHAR(255), IN firstName VARCHAR(255), 
									IN lastName VARCHAR(255), IN phoneNumber VARCHAR(255), IN age INT, IN about VARCHAR(255)) 
BEGIN

	DECLARE foundEntry INT DEFAULT 0;

	SELECT count(*) INTO foundEntry from activities_app.usertable 
	WHERE activities_app.usertable = uname;

	IF foundEntry >  0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User already exists';
	ELSE
		INSERT into usertable(UserID, UserTypeID, GenderID, UserName, UserPassword, FirstName, LastName, PhoneNumber, Age, About) 
        VALUES (((SELECT max(UserID) from activities_app.usertable) + row_number() over (ORDER BY UserID)),
				(SELECT UserTypeID from activities_app.usertable WHERE UserType = utype),
                (SELECT GenderID from activities_app.gender WHERE Gender = gender),
                uname, upassword, firstName, lastName, phoneNumber, age, about);
	END IF;
END $$
DELIMITER ;

