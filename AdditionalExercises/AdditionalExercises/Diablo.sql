USE Diablo
GO

--Problem 1.	Number of Users for Email Provider
SELECT [Email Provider], COUNT(Id) AS [Number Of Users]
  FROM (SELECT Id, SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) AS[Email Provider]
		  FROM Users) AS a
 GROUP BY [Email Provider]
 ORDER BY [Number Of Users] DESC, [Email Provider]
GO

--Problem 2.	All User in Games
SELECT g.Name AS Game, 
		gt.Name AS [Game Type],
		u.Username,
		ug.Level,
		ug.Cash,
		c.Name AS Character
  FROM Users AS u
  JOIN UsersGames AS ug
    ON ug.UserId = u.Id
  JOIN Games AS g
    ON g.Id = ug.GameId
  JOIN GameTypes AS gt
    ON gt.Id = g.GameTypeId
  JOIN Characters as c
    ON c.Id = ug.CharacterId
 ORDER BY ug.Level DESC, u.Username, g.Name
GO

--Problem 3.	Users in Games with Their Items
SELECT u.Username, g.Name AS Game, COUNT(i.Id) AS [Items Count], SUM(i.Price) AS [Items Price]
  FROM UserGameItems as ugi
  JOIN Items as i
    ON i.Id = ugi.ItemId
  JOIN UsersGames AS ug
	ON ug.Id = ugi.UserGameId
  JOIN Games AS g
	ON g.Id = ug.GameId
  JOIN Users AS u
    ON u.Id = ug.UserId
 GROUP BY u.Username, g.Name
HAVING COUNT(i.Id) >= 10
 ORDER BY [Items Count] DESC, [Items Price] DESC, Username
GO

--Problem 5.	All Items with Greater than Average Statistics
SELECT i.Name, i.Price, i.MinLevel, s.Strength, s.Defence, s.Speed, s.Luck, s.Mind
  FROM Items AS i
  JOIN [Statistics] AS s ON s.Id = i.StatisticId
 WHERE  s.Mind > (SELECT AVG(Mind) FROM [Statistics])
		AND s.Luck > (SELECT AVG(Luck) FROM [Statistics])
		AND s.Speed > (SELECT AVG(Speed) FROM [Statistics])
 ORDER BY Name

--Problem 6.	Display All Items with Information about Forbidden Game Type
SELECT i.Name AS Item,
		i.Price,
		i.MinLevel,
		gt.Name
  FROM Items AS i
  LEFT JOIN GameTypeForbiddenItems AS gfi ON gfi.ItemId = i.Id
  LEFT JOIN GameTypes AS gt ON gt.Id = gfi.GameTypeId
 ORDER BY gt.Name DESC, i.Name

--Problem 7.	Buy Items for User in Game
DECLARE @userGameId INT = (SELECT *
					  FROM Users AS u
					  JOIN UsersGames AS ug ON ug.UserId = u.Id
					  JOIN Games AS g ON g.Id = ug.GameId
					  WHERE u.Username = 'Alex' AND g.Name = 'Edinburgh')

INSERT INTO UserGameItems (UserGameId, ItemId) VALUES
(@userGameId, (SELECT Id FROM Items WHERE Name = 'Blackguard')),
(@userGameId, (SELECT Id FROM Items WHERE Name = 'Bottomless Potion of Amplification')),
(@userGameId, (SELECT Id FROM Items WHERE Name = 'Eye of Etlich (Diablo III)')),
(@userGameId, (SELECT Id FROM Items WHERE Name = 'Gem of Efficacious Toxin')),
(@userGameId, (SELECT Id FROM Items WHERE Name = 'Golden Gorget of Leoric')),
(@userGameId, (SELECT Id FROM Items WHERE Name = 'Hellfire Amulet'))

UPDATE UsersGames
SET Cash -= (SELECT SUM(Price) FROM Items WHERE Name IN('Blackguard', 'Bottomless Potion of Amplification', 'Eye of Etlich (Diablo III)', 'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet'))
WHERE Id = (SELECT *
					  FROM Users AS u
					  JOIN UsersGames AS ug ON ug.UserId = u.Id
					  JOIN Games AS g ON g.Id = ug.GameId
					  WHERE u.Username = 'Alex' AND g.Name = 'Edinburgh')

SELECT u.Username, g.Name, ug.Cash, i.Name AS [Item Name]
  FROM Users AS u
  JOIN UsersGames AS ug ON ug.UserId = u.Id
  JOIN Games AS g ON g.Id = ug.GameId
  JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
  JOIN Items AS i ON i.Id = ugi.ItemId
 WHERE g.Name = 'Edinburgh'