USE Bank1
GO

--Problem 14. Create Table Logs
CREATE TABLE Logs(
	LogId INT PRIMARY KEY IDENTITY,
	AccountId INT,
	OldSum DECIMAL(15, 2),
	NewSum DECIMAL(15, 2)
)
GO

CREATE TRIGGER tr_Logs
    ON Accounts
 AFTER UPDATE AS
 BEGIN
	INSERT INTO Logs(AccountId, OldSum, NewSum)
	SELECT d.Id, d.Balance, i.Balance
	  FROM inserted AS i
	  JOIN deleted AS d
	    ON d.Id = i.Id
 END
GO

--Problem 15. Create Table Emails
CREATE TABLE NotificationEmails(
Id INT PRIMARY KEY IDENTITY,
Recipient INT,
Subject NVARCHAR(50),
Body NVARCHAR(MAX)
)
GO

CREATE TRIGGER tr_NotificationEmails
    ON Logs
 AFTER INSERT AS
 BEGIN
	DECLARE @recepient INT = (SELECT AccountId FROM inserted);
	DECLARE @oldBalance DECIMAL(15, 2) = (SELECT OldSum FROM inserted);
	DECLARE @newBalance DECIMAL(15, 2) = (SELECT NewSum FROM deleted);

	INSERT INTO NotificationEmails(Recipient, Subject, Body)
	VALUES(@recepient,
			CONCAT('Balance change for account: ', @recepient),
			CONCAT('On ', GETDATE(), ' your balance was changed from ', @oldBalance, ' to ', @newBalance))
 END
GO

--Problem 16. Deposit Money
ALTER TABLE Accounts
ALTER COLUMN Balance DECIMAL(15, 4)
GO 

CREATE PROC usp_DepositMoney (@accountId INT, @moneyAmount DECIMAL(15, 4)) AS
BEGIN
	BEGIN TRANSACTION
	
	UPDATE Accounts
	   SET Balance += @moneyAmount
	 WHERE Id = @accountId

	IF (@@ROWCOUNT <> 1)
	BEGIN
		RAISERROR('Invalid account', 16, 1)
		ROLLBACK;
		RETURN;
	END

	COMMIT;
END

EXEC usp_DepositMoney 5, 100
GO

--Problem 17. Withdraw Money
CREATE PROC usp_WithdrawMoney (@accountId INT, @moneyAmount DECIMAL(15, 4)) AS
BEGIN
	
	BEGIN TRANSACTION
	UPDATE Accounts
	   SET Balance -= @moneyAmount
	 WHERE Id = @accountId

	IF (@@ROWCOUNT <> 1)
	BEGIN
		RAISERROR('Invalid account', 16, 1)
		ROLLBACK;
		RETURN;
	END

	COMMIT;
END

EXEC usp_WithdrawMoney 5, 100
GO

--Problem 18. Money Transfer
CREATE PROC usp_TransferMoney(@senderId INT, @receiverId INT, @amount DECIMAL(15, 4)) AS
BEGIN
	BEGIN TRAN
		EXEC usp_WithdrawMoney @senderId, @amount

		EXEC usp_DepositMoney @receiverId, @amount
	COMMIT;
END