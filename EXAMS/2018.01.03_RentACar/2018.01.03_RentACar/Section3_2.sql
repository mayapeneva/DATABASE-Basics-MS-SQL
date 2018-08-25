USE RentACar
GO

--5.	Showroom
SELECT Manufacturer, Model
  FROM Models
 ORDER BY Manufacturer, Id DESC

--6.	Y Generation
SELECT FirstName, LastName
  FROM Clients
 WHERE YEAR(BirthDate) BETWEEN 1977 AND 1994
 ORDER BY FirstName, LastName, Id

--7.	Spacious Office
SELECT t.Name AS TownName, o.Name AS OfficeName, o.ParkingPlaces
  FROM Offices AS o
  JOIN Towns AS t ON t.Id = o.TownId
 WHERE ParkingPlaces > 25
 ORDER BY t.Name, o.Id

--8.	Available Vehicles
SELECT m.Model, m.Seats, v.Mileage
  FROM Vehicles AS v
  JOIN Models AS m ON m.Id = v.ModelId
 WHERE v.Id NOT IN(
					SELECT VehicleId
					  FROM Orders
					 WHERE ReturnDate IS NULL)
 ORDER BY Mileage, Seats DESC, m.Id

--9.	Offices per Town
SELECT t.Name AS TownName, COUNT(o.Id) AS OfficesNumber
  FROM Towns AS t
  JOIN Offices AS o ON o.TownId = t.Id
 GROUP BY t.Name
 ORDER BY OfficesNumber DESC, t.Name

--10.	Buyers Best Choice 
SELECT m.Manufacturer, m.Model, COUNT(o.Id) AS TimesOrdered
  FROM Models AS m
  JOIN Vehicles AS v ON v.ModelId = m.Id
  LEFT JOIN Orders AS o ON o.VehicleId = v.Id
 GROUP BY m.Manufacturer, m.Model
 ORDER BY TimesOrdered DESC, Manufacturer DESC, Model

--11.	Kinda Person
WITH CTE_ClassRanks AS(
	SELECT c.Id, 
			CONCAT(c.FirstName, ' ', c.LastName) AS Names,
			m.Class,
			DENSE_RANK() OVER (PARTITION BY c.Id ORDER BY COUNT(m.Class) DESC) AS ClassRank
	  FROM Clients AS c
	  JOIN Orders AS o ON o.ClientId = c.Id
	  JOIN Vehicles AS v ON v.Id = o.VehicleId
	  JOIN Models AS m ON m.Id = v.ModelId
	 GROUP BY c.Id, c.FirstName, c.LastName, m.Class)

SELECT Names, Class
  FROM CTE_ClassRanks
 WHERE ClassRank = 1
 ORDER BY Names, Class, Id

--12.	Age Groups Revenue
SELECT AgeGroup, SUM(Bill) AS Revenue, AVG(TotalMileage) AS AverageMileage
  FROM(
	SELECT CASE
				WHEN YEAR(c.BirthDate) BETWEEN 1970 AND 1979 THEN '70''s'
				WHEN YEAR(c.BirthDate) BETWEEN 1980 AND 1989 THEN '80''s'
				WHEN YEAR(c.BirthDate) BETWEEN 1990 AND 1999 THEN '90''s'
				ELSE 'Others'
			END AS AgeGroup, 
			o.Bill, 
			o.TotalMileage
	  FROM Clients AS c
	  JOIN Orders AS o ON o.ClientId = c.Id) AS a
 GROUP BY AgeGroup
 ORDER BY AgeGroup

--13.	Consumption in Mind
WITH CTE_ModelsRanks AS(
	SELECT TOP(7) m.Manufacturer, 
			AVG(m.Consumption) AS AverageConsumption,
			COUNT(o.Id) AS OrdersCount
	  FROM Models AS m
	  JOIN Vehicles AS v ON v.ModelId = m.Id
	  JOIN Orders AS o ON o.VehicleId = v.Id
	 GROUP BY m.Manufacturer, m.Model
	 ORDER BY OrdersCount DESC)

SELECT Manufacturer, AverageConsumption
  FROM CTE_ModelsRanks
 WHERE AverageConsumption BETWEEN 5 AND 15
 ORDER BY Manufacturer, AverageConsumption

--14.	Debt Hunter
WITH CTE_BiggestBillClientsPerTown AS(
	SELECT c.Id AS ClientId,
			CONCAT(c.FirstName, ' ', c.LastName) AS [Client Name],
			c.Email, 
			t.Name AS Town,			 
			ROW_NUMBER() OVER (PARTITION BY t.Name ORDER BY o.Bill DESC) AS BillRank,
			o.Bill
	  FROM Orders AS o
	  JOIN Towns AS t ON t.Id = o.TownId
	  JOIN Clients AS c ON c.Id = o.ClientId
	 WHERE c.CardValidity < o.CollectionDate 
		AND o.Bill IS NOT NULL
	 GROUP BY t.Name, c.Id, c.FirstName, c.LastName, c.Email, o.Bill)

SELECT [Client Name],
		Email,
		Bill,
		Town
  FROM CTE_BiggestBillClientsPerTown
 WHERE BillRank IN(1, 2)
 ORDER BY Town, Bill, ClientId

--15.	Town Statistics
WITH CTE_GenderCount AS(
	SELECT t.Id AS TownId,
			t.Name AS TownName, 
			SUM(CASE
				WHEN c.Gender = 'M' THEN 1
				ELSE 0
			  END) AS Males,
			SUM(CASE
				WHEN c.Gender = 'F' THEN 1
				ELSE 0
			  END) AS Females,
			COUNT(c.Id) AllClients
	  FROM Orders AS o
	  JOIN Towns AS t ON t.Id = o.TownId
	  JOIN Clients AS c ON c.Id = o.ClientId
	 GROUP BY t.Id, t.Name)

SELECT TownName,
		CASE
			WHEN ((Males * 100)/ AllClients) = 0 THEN NUll
			ELSE (Males * 100)/ AllClients
		END AS MalePercent,
		CASE
			WHEN ((Females * 100) / AllClients) = 0 THEN NULL
			ELSE (Females * 100) / AllClients
		END AS FemalePercent
  FROM CTE_GenderCount
 ORDER BY TownName, TownId