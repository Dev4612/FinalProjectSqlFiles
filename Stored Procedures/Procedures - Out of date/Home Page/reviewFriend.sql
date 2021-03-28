DELIMITER $$
CREATE procedure reviewFriend(IN username VARCHAR(255), IN friendUsername VARCHAR(255), IN score VARCHAR(255)) 
BEGIN
	DECLARE User1ID INT DEFAULT 0;
	DECLARE User2ID INT DEFAULT 0;
    SELECT UserID INTO User1ID from usertable where usertable.UserName = username;
    SELECT UserID INTO User2ID from usertable where usertable.UserName = friendUsername;
    
    INSERT INTO reviews(ReviewerID, RevieweeID)
    VALUES(User1ID, User2ID);
    
    INSERT INTO userreview(UserReviewID, ReviewScore) 
    VALUES ((SELECT ReviewID from reviews WHERE (ReviewerID = User1ID AND RevieweeID = User2ID)),
			score);
END $$
DELIMITER ;

