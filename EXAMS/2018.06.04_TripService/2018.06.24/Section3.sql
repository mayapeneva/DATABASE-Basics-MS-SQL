--5. Bulgarian Cities
SELECT Id, Name
  FROM Cities
 WHERE CountryCode = 'BG'
 ORDER BY Name

--6. People Born After 1991
SELECT CASE
		WHEN MiddleName IS NULL THEN CONCAT(FirstName, ' ', LastName) 
		ELSE CONCAT(FirstName, ' ', MiddleName, ' ', LastName) 
		END AS [Full Name], 
		YEAR(BirthDate) AS BirthYear
  FROM Accounts
 WHERE YEAR(BirthDate) > 1991
 ORDER BY BirthYear DESC, FirstName

--7. EEE-Mails
SELECT a.FirstName, a.LastName, FORMAT(a.BirthDate, 'MM-dd-yyyy'), c.Name AS Hometown, a.Email
  FROM Accounts AS a
  JOIN Cities AS c ON c.Id = a.CityId
 WHERE a.Email LIKE 'e%'
 ORDER BY Hometown DESC

--8. City Statistics
SELECT c.Name, COUNT(h.Id) AS Hotels
  FROM Cities AS c
  LEFT JOIN Hotels AS h ON h.CityId = c.Id
 GROUP BY c.Name
 ORDER BY Hotels DESC, c.Name

--9. Expensive First-Class Rooms
SELECT r.Id, r.Price, h.Name, c.Name 
  FROM Rooms AS r
  JOIN Hotels AS h ON h.Id = r.HotelId
  JOIN Cities AS c ON c.Id = h.CityId
 WHERE r.Type = 'First Class'
 ORDER BY r.Price DESC, r.Id

--10. Longest and Shortest Trips
WITH CTE_LongestShortesTripsRanks AS(
	SELECT a.Id AS AccountId,
			CONCAT(a.FirstName, ' ', a.LastName) AS FullName,
			DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate) AS LongestTrip,
			ROW_NUMBER() OVER (PARTITION BY a.Id ORDER BY DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate) DESC) AS LongestTripRank
	  FROM Accounts AS a
	  JOIN AccountsTrips AS atr ON atr.AccountId = a.Id
	  JOIN Trips AS t ON t.Id = atr.TripId
	  WHERE a.MiddleName IS NULL AND t.CancelDate IS NUll)

SELECT cte.AccountId, cte.FullName, LongestTrip, ShortestTrip
  FROM CTE_LongestShortesTripsRanks AS cte 
  JOIN (SELECT a.Id AS AccountId,
				DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate) AS ShortestTrip,
				ROW_NUMBER() OVER (PARTITION BY a.Id ORDER BY DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS ShortestTripRank
		  FROM Accounts AS a
		  JOIN AccountsTrips AS atr ON atr.AccountId = a.Id
		  JOIN Trips AS t ON t.Id = atr.TripId
		  WHERE a.MiddleName IS NULL AND t.CancelDate IS NUll) AS a ON a.AccountId = cte.AccountId
 WHERE cte.LongestTripRank = 1 AND ShortestTripRank = 1
 ORDER BY LongestTrip DESC, AccountId

--11. Metropolis
SELECT TOP(5) c.Id, c.Name, c.CountryCode, COUNT(a.Id) AS Accounts
  FROM Cities AS c
  JOIN Accounts AS a ON a.CityId = c.Id
 GROUP BY c.Id, c.Name, c.CountryCode
 ORDER BY Accounts DESC

--12. Romantic Getaways
SELECT a.Id, a.Email, c.Name, COUNT(t.Id) AS Trips
  FROM Accounts AS a
  JOIN AccountsTrips AS atr ON atr.AccountId = a.Id
  JOIN Trips AS t ON t.Id = atr.TripId
  JOIN Rooms AS r ON r.Id = t.RoomId
  JOIN Hotels AS h ON h.Id = r.HotelId
  JOIN Cities AS c ON c.Id = h.CityId
 WHERE a.CityId = h.CityId
 GROUP BY a.Id, a.Email, c.Name
 ORDER BY Trips DESC, a.Id
GO

--13. Lucrative Destinations
SELECT TOP(10) c.Id,
		c.Name,
		SUM(h.BaseRate + r.Price) AS [Total Revenue],
		COUNT(t.Id) AS Trips
  FROM Cities AS c
  JOIN Hotels AS h ON h.CityId = c.Id
  JOIN Rooms AS r ON r.HotelId = h.Id
  JOIN Trips AS t ON  t.RoomId = r.Id
 WHERE YEAR(t.BookDate) = 2016
 GROUP BY c.Id, c.Name
 ORDER BY [Total Revenue] DESC, Trips DESC

--14. Trip Revenues
SELECT t.Id,
		h.Name AS HotelName,
		r.Type AS RoomType,
		CASE
			WHEN t.CancelDate IS NULL THEN SUM(h.BaseRate + r.Price)
			ELSE 0 
		END AS Revenue
  FROM Trips AS t
  JOIN AccountsTrips AS atr ON atr.TripId = t.Id
  JOIN Accounts AS a ON a.Id = atr.AccountId
  JOIN Rooms AS r ON r.Id = t.RoomId
  JOIN Hotels AS h ON h.Id = r.HotelId
 GROUP BY t.Id, h.Name, r.Type, t.CancelDate
 ORDER BY r.Type, t.Id

--15. Top Travelers
WITH CTE_TravelersRanks AS(
	SELECT a.Id AS AccountId,
			a.Email,
			c.CountryCode,
			ROW_NUMBER() OVER(PARTITION BY c.CountryCode ORDER BY COUNT(*) DESC) AS TravelersRank,
			COUNT(*) AS Trips
	  FROM Accounts AS a 
	  JOIN AccountsTrips AS atr ON atr.AccountId = a.Id
	  JOIN Trips AS t ON t.Id = atr.TripId
	  JOIN Rooms AS r ON r.Id = t.RoomId
	  JOIN Hotels AS h ON h.Id = r.HotelId
	  JOIN Cities AS c ON c.Id = h.CityId
	  GROUP BY c.CountryCode, a.Id, a.Email)

SELECT AccountId, Email, CountryCode, Trips
  FROM CTE_TravelersRanks
 WHERE TravelersRank = 1
 ORDER BY Trips DESC, AccountId

--16. Luggage Fees
SELECT TripId, 
		TotalLuggage, 
		CASE
			WHEN TotalLuggage <= 5 THEN '$0'
			ELSE '$' + CAST((TotalLuggage * 5) as NVARCHAR) 
		END AS Fee
  FROM(
	SELECT TripId, 
			SUM(Luggage) AS TotalLuggage
	  FROM AccountsTrips
	 WHERE Luggage > 0
	 GROUP BY TripId) AS a
 ORDER BY TotalLuggage DESC

--17. GDPR Violation
SELECT t.Id,
		CASE
		WHEN MiddleName IS NULL THEN CONCAT(FirstName, ' ', LastName)
		ELSE CONCAT(FirstName, ' ', MiddleName, ' ', LastName) 
		END AS [Full Name],
		(SELECT Name FROM Cities AS c WHERE c.Id = a.CityId) AS [From],
		(SELECT Name FROM Cities AS c WHERE c.Id = h.CityId) AS [To],
		CASE
			WHEN t.CancelDate IS NOT NULL THEN 'Canceled'
			ELSE CAST(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate) AS NVARCHAR) + ' days'
		END
  FROM Accounts AS a
  JOIN AccountsTrips AS atr ON atr.AccountId = a.Id
  JOIN Trips AS t ON t.Id = atr.TripId
  JOIN Rooms AS r ON r.Id = t.RoomId
  JOIN Hotels AS h ON h.Id = r.HotelId
 ORDER BY [Full Name], TripId 