USE Bakery
GO

--5.	Products by Price
SELECT Name, Price, Description
  FROM Products
 ORDER BY Price DESC, Name

--6.	Ingredients
SELECT Name, Description, OriginCountryId
  FROM Ingredients
 WHERE OriginCountryId IN(1, 10, 20)
 ORDER BY Id

--7.	Ingredients from Bulgaria and Greece
SELECT TOP(15) i.Name, i.Description, c.Name
  FROM Ingredients AS i
  JOIN Countries AS c ON c.Id = i.OriginCountryId
 WHERE c.Name IN('Bulgaria', 'Greece')
 ORDER BY i.Name, c.Name

--8.	Best Rated Products
SELECT TOP(10) p.Name, 
				p.Description, 
				AVG(f.Rate) AS AverageRate, 
				COUNT(f.Id) AS FeedbacksAmount
  FROM Products AS p
  JOIN Feedbacks AS f ON f.ProductId = p.Id
 GROUP BY p.Id, p.Name, p.Description
 ORDER BY AverageRate DESC, FeedbacksAmount DESC

--9.	Negative Feedback
SELECT f.ProductId, f.Rate, f.Description, c.Id AS CustomerId, c.Age, c.Gender
  FROM Feedbacks AS f
  JOIN Customers AS c ON c.Id = f.CustomerId
 WHERE f.Rate < 5
 ORDER BY f.ProductId DESC, f.Rate

--10.	Customers without Feedback
SELECT CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName, 
		c.PhoneNumber,
		c.Gender
  FROM Customers AS c
  LEFT JOIN Feedbacks AS f ON f.CustomerId = c.Id
 WHERE f.Id IS NULL
 ORDER BY c.Id

--11.	Honorable Mentions
WITH CTE_CustomersWithMoreFeedback AS(
SELECT CustomerId
  FROM Feedbacks
 GROUP BY CustomerId
HAVING COUNT(Id) >= 3
)

SELECT f.ProductId, 
		CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
		f.Description AS FeedbackDescription
  FROM Customers AS c
  JOIN Feedbacks AS f ON f.CustomerId = c.Id
  JOIN CTE_CustomersWithMoreFeedback AS cte ON cte.CustomerId = c.Id
 ORDER BY f.ProductId, CustomerName, f.Id

--12.	Customers by Criteria
SELECT cs.FirstName, cs.Age, cs.PhoneNumber
  FROM Customers AS cs
  JOIN Countries AS ct ON ct.Id = cs.CountryId
 WHERE (cs.Age >= 21 
		AND cs.FirstName LIKE '%an%') 
		OR (RIGHT(cs.PhoneNumber, 2) = '38'
		AND ct.Name <> 'Greece')
 ORDER BY FirstName, Age DESC

--13.	Middle Range Distributors
WITH CTE_ProductsWithAvgRate AS(
SELECT p.Id AS ProductId, p.Name AS ProductName, AVG(f.Rate) AS AverageRate
  FROM Products AS p
  JOIN Feedbacks AS f ON f.ProductId = p.Id
 GROUP BY p.Id, P.Name)

SELECT d.Name AS DistributorName,
		i.Name AS IngredientName,
		cte.ProductName, 
		cte.AverageRate
  FROM Distributors AS d
  JOIN Ingredients AS i ON i.DistributorId = d.Id
  JOIN ProductsIngredients AS pin ON pin.IngredientId = i.Id
  JOIN CTE_ProductsWithAvgRate AS cte ON cte.ProductId = pin.ProductId
 WHERE AverageRate BETWEEN 5 AND 8
 ORDER BY d.Name, i.Name, cte.ProductName

--14.	The Most Positive Country
SELECT TOP(1) WITH TIES ct.Name AS CountryName, AVG(f.Rate) AS FeedbacksCount
  FROM Feedbacks AS f
  JOIN Customers AS c ON c.Id = f.CustomerId
  JOIN Countries AS ct ON ct.Id = c.CountryId
 GROUP BY ct.Name
 ORDER BY FeedbacksCount DESC

--15.	Country Representative
SELECT CountryName, DistributorName
  FROM(SELECT c.Name AS CountryName, 
				d.Name AS DistributorName, 
				COUNT(i.Id) AS IngredientsCount,
				DENSE_RANK() OVER (PARTITION BY c.Name ORDER BY COUNT(i.Id) DESC) AS DistributorRank 
		 FROM Countries AS c
		 JOIN Distributors AS d ON d.CountryId = c.Id
		 JOIN Ingredients AS i ON i.DistributorId = d.Id
		GROUP BY d.Name, c.Name) AS a
 WHERE DistributorRank = 1
 ORDER BY CountryName, DistributorName
GO