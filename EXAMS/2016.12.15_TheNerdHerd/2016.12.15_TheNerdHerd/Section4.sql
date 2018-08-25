USE TheNerdHerd
GO

--15.	Radians
CREATE FUNCTION udf_GetRadians(@degrees FLOAT)
RETURNS FLOAT
AS
BEGIN
	RETURN @degrees * PI() / 180
END

SELECT dbo.udf_GetRadians(22.12) AS Radians

--16.	Change Password
CREATE PROC udp_ChangePassword(@email NVARCHAR(30), @NEWpass NVARCHAR(20))
AS
BEGIN
	UPDATE Credentials
	SET Password = @NEWpass
	WHERE Email = @email

	IF(@@ROWCOUNT <> 1)
	BEGIN
		RAISERROR('The email does''t exist!', 16, 1)
	END
END

EXEC udp_ChangePassword 'abarnes0@sogou.com', 'LOL77s'

SELECT Password FROM Credentials WHERE Email = 'abarnes0@sogou.com'

--17.	Send Message
CREATE PROC udp_SendMessage(@userId INT, @chatId INT, @content NVARCHAR(200))
AS
BEGIN
	BEGIN TRAN
	
	IF((SELECT COUNT(*) FROM Messages WHERE UserId = @userId AND ChatId = @chatId) = 0)
	BEGIN
		RAISERROR('There is no chat with that user!', 16, 1)
	END

	INSERT INTO Messages(Content, SentOn, UserId, ChatId) VALUES
	(@content, GETDATE(), @userId, @chatId)

	COMMIT;
END

SELECT * FROM Messages

EXEC dbo.udp_SendMessage 19, 17, 'Awesome'

--18.	Log Messages
CREATE TABLE MessageLogs(
	Id INT PRIMARY KEY IDENTITY,
	Content NVARCHAR(200),
	SentOn DATE,
	ChatId INT,
	UserId INT
)

CREATE TRIGGER tr_Messages
ON Messages
FOR DELETE
AS
BEGIN
	DECLARE @id NVARCHAR(200) = (SELECT Id FROM deleted)
	DECLARE @content NVARCHAR(200) = (SELECT Content FROM deleted)
	DECLARE @sentOn DATE = (SELECT SentOn FROM deleted)
	DECLARE @chatId INT = (SELECT ChatId FROM deleted)
	DECLARE @userId INT = (SELECT UserId FROM deleted)

	INSERT INTO MessageLogs VALUES
	(@id, @content, @sentOn, @chatId, @userId)
END