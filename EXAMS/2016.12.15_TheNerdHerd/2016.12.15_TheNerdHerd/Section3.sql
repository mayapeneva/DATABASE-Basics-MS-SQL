USE TheNerdHerd
GO

--5.	Age Range
SELECT Nickname, Gender, Age
  FROM Users
  WHERE Age BETWEEN 22 AND 37

--6.	Messages
SELECT Content, SentOn
  FROM Messages
 WHERE SentOn > '2014/05/12' AND Content LIKE '%just%'
 ORDER BY Id DESC

--7.	Chats
SELECT Title, IsActive
  FROM Chats
 WHERE IsActive = 0 AND LEN(Title) < 5 OR Title LIKE '__tl%'
 ORDER BY Title DESC

--8.	Chat Messages
SELECT c.Id, c.Title, m.Id
  FROM Chats AS c
  JOIN Messages AS m ON m.ChatId = c.Id
 WHERE m.SentOn < '2012/03/26' AND c.Title LIKE '%x'
 ORDER BY c.Id, m.Id

--9.	Message Count
SELECT TOP(5) c.Id, COUNT(m.Id) AS TotalMessages
  FROM Chats AS c
 RIGHT JOIN Messages AS m ON m.ChatId = c.Id
 WHERE m.Id < 90
 GROUP BY c.Id
 ORDER BY COUNT(m.Id) DESC, c.Id

--10.	Credentials
SELECT u.Nickname, cr.Email, cr.Password
  FROM Users AS u
  JOIN Credentials AS cr ON cr.Id = u.CredentialId
  WHERE cr.Email LIKE '%co.uk'
  ORDER BY cr.Email

--11.	Locations
SELECT u.Id, u.Nickname, u.Age
  FROM Users AS u
  LEFT JOIN Locations AS l ON l.Id = u.LocationId
  WHERE l.Id IS NULL

--12.	Left Users
SELECT m.Id, m.ChatId, m.UserId
  FROM Messages AS m
 WHERE m.ChatId = 17 
		AND m.UserId NOT IN(SELECT UserId FROM UsersChats WHERE ChatId = m.ChatId) 
		OR m.UserId IS NULL 
 ORDER BY m.Id DESC

--13.	Users in Bulgaria
SELECT u.Nickname, c.Title, l.Latitude, l.Longitude
  FROM Users AS u
  JOIN Locations AS l ON l.Id = u.LocationId
  LEFT JOIN UsersChats AS uc ON uc.UserId = u.Id
  LEFT JOIN Chats AS c ON c.Id = uc.ChatId
 WHERE l.Latitude BETWEEN 41.139999 AND 44.129999 AND l.Longitude BETWEEN 22.209999 AND 28.359999
 ORDER BY Title

--14.	Last Chat
SELECT TOP(1) WITH TIES c.Title, m.Content
  FROM Messages AS m
 RIGHT JOIN Chats AS c ON c.Id = m.ChatId
 ORDER BY StartDate DESC, m.SentOn