USE Bank1
GO

CREATE PROC usp_GetHoldersFullName AS
BEGIN
	SELECT FirstName + ' ' + LastName AS [Full Name]
	  FROM AccountHolders
END	
GO

CREATE PROC usp_GetHoldersWithBalanceHigherThan(@totalBalance DECIMAL(15,2)) AS
BEGIN
	SELECT FirstName AS [First Name], LastName AS [Last Name]
	  FROM AccountHolders
	 WHERE Id IN(
	 SELECT AccountHolderId FROM Accounts
	  GROUP BY AccountHolderId
	 HAVING SUM(Balance) > @totalBalance)
	  ORDER BY LastName, FirstName
END

EXEC usp_GetHoldersWithBalanceHigherThan 50000
GO

CREATE FUNCTION ufn_CalculateFutureValue(@sum DECIMAL(15, 2), @yearlyInterestRate FLOAT, @yearsNumber INT) 
RETURNS DECIMAL(15,4)
AS
BEGIN
	DECLARE @futureValue DECIMAL(15, 4)
	SET @futureValue = @sum * POWER((1 + @yearlyInterestRate), @yearsNumber)
	RETURN @futureValue
END

SELECT dbo.ufn_CalculateFutureValue (1000, 10/100, 5)
GO

CREATE PROC usp_CalculateFutureValueForAccount(@accountId INT, @interestRate FLOAT) AS
BEGIN
	DECLARE @initialBalance DECIMAL(15, 2) = 
		(SELECT Balance
		   FROM Accounts
		  WHERE Id = @accountId)

	DECLARE @endBalance DECIMAL(15, 4) = 
		(SELECT dbo.ufn_CalculateFutureValue (@initialBalance, @interestRate, 5))

	SELECT a.Id AS [Account Id],
			ah.FirstName AS [First Name],
			ah.LastName AS [Last Name],
			a.Balance AS [Current Balance],
			@endBalance AS [Balance in 5 years]
	  FROM AccountHolders AS ah
	  JOIN Accounts AS a
	    ON a.AccountHolderId = ah.Id
	 WHERE a.Id = @accountId
END

EXEC dbo.usp_CalculateFutureValueForAccount 1, 0.1