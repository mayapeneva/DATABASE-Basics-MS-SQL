USE RentACar
GO

--5.	Showroom
SELECT Manufacturer, Model
  FROM Models AS m
 ORDER BY Manufacturer, Id DESC

--6.	Y Generation
SELECT FirstName, LastName
  FROM Clients
 WHERE DATEPART(Year, BirthDate) BETWEEN 1977 AND 1994
 ORDER BY FirstName, LastName, Id

--7.	Spacious Office
SELECT t.Name AS TownName, o.Name AS OfficeName, o.ParkingPlaces
  FROM Offices AS o
  JOIN Towns AS t
    ON t.Id = o.TownId
 WHERE o.ParkingPlaces > 25
 ORDER BY TownName, o.Id

--8.	Available Vehicles
SELECT m.Model, m.Seats, v.Mileage
  FROM Vehicles AS v
  JOIN Models AS m
    ON m.Id = v.ModelId
 WHERE v.Id NOT IN(SELECT VehicleId FROM Orders 
					WHERE ReturnDate IS NULL)
 ORDER BY v.Mileage, Seats DESC, m.Id

--9.	Offices per Town
SELECT t.Name AS TownName, COUNT(o.Id) AS OfficesNumber
  FROM Towns AS t
  JOIN Offices AS o
    ON o.TownId = t.Id
 GROUP BY t.Name
 ORDER BY OfficesNumber DESC, TownName

--10.	Buyers Best Choice 
SELECT m.Manufacturer, m.Model, COUNT(o.VehicleId) AS TimesOrdered
  FROM Vehicles AS v
  LEFT JOIN Models AS m
    ON m.Id = v.ModelId
  LEFT JOIN Orders AS o
    ON o.VehicleId = v.Id
 GROUP BY m.Manufacturer, m.Model
 ORDER BY TimesOrdered DESC, Manufacturer DESC, Model

--11.	Kinda Person
WITH CTE_CustomersWithClassRank AS(
SELECT c.Id, CONCAT(c.FirstName, ' ', c.LastName) AS Names, m.Class, RANK() OVER (PARTITION BY c.Id ORDER BY COUNT(m.Class) DESC) AS ClassRank
  FROM Clients AS c
  JOIN Orders AS o ON o.ClientId = c.Id
  JOIN Vehicles AS v ON v.Id = o.VehicleId
  JOIN Models AS m ON m.Id = v.ModelId
 GROUP BY c.Id, c.FirstName, c.LastName, m.Class)

SELECT Names, Class
  FROM CTE_CustomersWithClassRank
 WHERE ClassRank = 1
 ORDER BY Names, Class, Id

--12.	Age Groups Revenue
WITH CTE_AgeGroups AS(
SELECT CASE
			WHEN DATEPART(YEAR, BirthDate) BETWEEN 1970 AND 1979 THEN '70''s'
			WHEN DATEPART(YEAR, BirthDate) BETWEEN 1980 AND 1989 THEN '80''s'
			WHEN DATEPART(YEAR, BirthDate) BETWEEN 1990 AND 1999 THEN '90''s'
			ELSE 'Others' 
		END AS AgeGroup,
		Bill, 
		o.TotalMileage 
  FROM Clients AS c
  JOIN Orders AS o
    ON o.ClientId = c.Id)

SELECT AgeGroup, SUM(Bill) AS Revenue, AVG(TotalMileage) AS AverageMileage
  FROM CTE_AgeGroups
 GROUP BY AgeGroup

--13.	Consumption in Mind
SELECT Manufacturer, AverageConsumption
  FROM (SELECT TOP (7) m.Manufacturer, 
		AVG(Consumption) AS AverageConsumption,
		COUNT(o.CollectionDate) AS OrdersCount
		  FROM Orders AS o
		 RIGHT JOIN Vehicles AS v ON v.Id = o.VehicleId
		  JOIN Models AS m ON m.Id = v.ModelId
		 GROUP BY Manufacturer, m.Model
		 ORDER BY OrdersCount DESC) AS a
 WHERE AverageConsumption BETWEEN 5 AND 15
 ORDER BY Manufacturer, AverageConsumption

--14.	Debt Hunter
WITH CTE_GroupedClients AS(
SELECT c.Id, 
		CONCAT(c.FirstName, ' ', c.LastName) AS ClientName, 
		c.Email, 
		o.Bill, 
		t.Name AS Town, 
		ROW_NUMBER() OVER (PARTITION BY t.Name ORDER BY o.Bill DESC) AS ClientsRanks
  FROM Clients AS c
  JOIN Orders AS o ON o.ClientId = c.Id
  JOIN Towns AS t ON t.Id = o.TownId
 WHERE c.CardValidity < o.CollectionDate AND o.Bill IS NOT NULL
 GROUP BY t.Name, o.Bill, c.Id, c.Email, c.FirstName, c.LastName)
 
SELECT ClientName, Email, Bill, Town
  FROM CTE_GroupedClients
 WHERE ClientsRanks IN(1, 2)
 ORDER BY Town, Bill, Id

--15.	Town Statistics
WITH CTE_ClientsByGender AS(
SELECT t.Id AS TownId,
		t.Name AS TownName,
		SUM(CASE
				WHEN c.Gender = 'M' THEN 1
				ELSE 0
			  END) AS MaleCount,
		SUM(CASE
				WHEN c.Gender = 'F' THEN 1
				ELSE 0
			  END) AS FemaleCount,
		COUNT(c.Gender) AS TotalCount
  FROM Towns AS t
  JOIN Orders AS o ON o.TownId = t.Id
  JOIN Clients AS c ON c.Id = o.ClientId
 GROUP By t.Name, t.Id)

SELECT TownName, 
		CASE
			WHEN MaleCount * 100 / TotalCount = 0 THEN NULL
			ELSE MaleCount * 100 / TotalCount
		END AS MalePercent,
		CASE
			WHEN FemaleCount * 100 / TotalCount = 0 THEN NULL
			ELSE FemaleCount * 100 / TotalCount
		END AS FemalePercent
  FROM CTE_ClientsByGender
 ORDER BY TownName, TownId

--16.	Home Sweet Home
WITH CTE_Ranks AS(
SELECT VehicleId, Manufacturer, Model, CollectionOfficeId, ReturnOfficeId
  FROM (SELECT 
			v.Id AS VehicleId, 
			m.Manufacturer,
			m.Model,
			v.OfficeId AS CollectionOfficeId,
			o.ReturnOfficeId,
			DENSE_RANK() OVER (PARTITION BY v.Id ORDER BY o.CollectionDate DESC) AS LatestRentedCarsRank			
		  FROM Orders AS o
		 RIGHT JOIN Vehicles AS v ON v.Id = o.VehicleId
		  JOIN Models AS m ON m.Id = v.ModelId) AS a
		 WHERE LatestRentedCarsRank = 1)

 SELECT CONCAT(Manufacturer, ' - ', Model) AS Vehicle,
		CASE
			WHEN (SELECT COUNT(*) FROM Orders AS o WHERE o.VehicleId = b.VehicleId) = 0  OR CollectionOfficeId = ReturnOfficeId THEN 'home'
			WHEN ReturnOfficeId IS NULL THEN 'on a rent'
			WHEN CollectionOfficeId <> ReturnOfficeId THEN (SELECT CONCAT(t.Name, ' - ', o.Name) FROM Offices AS o JOIN Towns AS t ON t.Id = o.TownId WHERE ReturnOfficeId = o.Id)
		END AS Location
  FROM CTE_Ranks AS b
 ORDER BY Vehicle, VehicleId
