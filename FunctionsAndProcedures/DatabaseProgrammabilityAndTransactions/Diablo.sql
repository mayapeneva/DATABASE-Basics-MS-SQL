USE Diablo
GO

CREATE FUNCTION ufn_CashInUsersGames (@gameName VARCHAR(50))
RETURNS TABLE
AS
RETURN(
	SELECT SUM(a.Cash) AS [Sum Cash] 
	  FROM (
		SELECT ug.Cash, 
				ROW_NUMBER() OVER(ORDER BY ug.Cash DESC) AS RowNumber
		  FROM Games AS g
		  JOIN UsersGames AS ug
			ON ug.GameId = g.Id
		 WHERE g.Name = @gameName) AS a
	 WHERE a.RowNumber % 2 = 1)

SELECT * FROM dbo.ufn_CashInUsersGames ('Love in a mist')