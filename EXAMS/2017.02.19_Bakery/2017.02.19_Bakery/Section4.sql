--16.	Customers with Countries
CREATE VIEW v_UserWithCountries AS(
SELECT CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName, c.Age, c.Gender, ct.Name AS CountryName
  FROM Customers AS c
  JOIN Countries AS ct ON ct.Id = c.CountryId)

SELECT TOP 5 *
  FROM v_UserWithCountries
 ORDER BY Age
GO

--17.	Feedback by Product Name
CREATE FUNCTION udf_GetRating(@productName NVARCHAR(25))
RETURNS VARCHAR(10)
AS
BEGIN
	RETURN
	(SELECT CASE
				WHEN AVG(f.Rate) < 5 THEN 'Bad'
				WHEN AVG(f.Rate) BETWEEN 5 AND 8 THEN 'Average'
				WHEN AVG(f.Rate) > 8 THEN 'Good'
				ELSE 'No rating'
			END
	  FROM Products AS p
	  JOIN Feedbacks AS f ON f.ProductId = p.Id
	 WHERE p.Name = @productName)
END

SELECT TOP 5 Id, Name, dbo.udf_GetRating(Name)
  FROM Products
 ORDER BY Id
GO

--18.	Send Feedback 
CREATE PROC usp_SendFeedback(@customerID INT, @productId INT, @rate DECIMAL(10, 2), @description NVARCHAR(255)) AS
BEGIN
	INSERT INTO Feedbacks(Description, Rate, ProductId, CustomerId) VALUES
	(@description, @rate, @productId, @customerID)

	DECLARE @feedbacksCount INT = (SELECT COUNT(f.Id)
									FROM Feedbacks AS f
								   WHERE f.CustomerId = @customerID AND f.ProductId = @productId)

	IF(@feedbacksCount > 3)
	BEGIN
		RAISERROR('You are limited to only 3 feedbacks per product!', 16, 1)
		ROLLBACK;
		RETURN;
	END
END

EXEC usp_SendFeedback 1, 5, 7.50, 'Average experience';
SELECT COUNT(*) FROM Feedbacks WHERE CustomerId = 1 AND ProductId = 5;

--19.	Delete Products
CREATE TRIGGER tr_DeleteProducts 
ON Products
INSTEAD OF DELETE AS
BEGIN
	DELETE ProductsIngredients
	WHERE ProductId = (SELECT Id FROM deleted)

	DELETE Feedbacks
	WHERE ProductId = (SELECT Id FROM deleted)

	DELETE Products
	WHERE Id = (SELECT Id FROM deleted)
END

--20.	Products by One Distributor
WITH CTE_ProductsIngredientsDistributors AS(
SELECT p.Name AS ProductName, COUNT(DISTINCT d.Name) AS DistributorsCount
  FROM Products AS p
  JOIN ProductsIngredients AS pin ON pin.ProductId = p.Id
  JOIN Ingredients AS i ON i.Id = pin.IngredientId
  JOIN Distributors AS d ON d.Id = i.DistributorId
 GROUP BY p.Name)

SELECT p.Name AS ProductName, AVG(f.Rate) AS ProductAverageRate, d.Name AS DistributorName, c.Name AS DistributorCountry
  FROM Products AS p
  JOIN ProductsIngredients AS pin ON pin.ProductId = p.Id
  JOIN Ingredients AS i ON i.Id = pin.IngredientId
  JOIN Distributors AS d ON d.Id = i.DistributorId
  JOIN Countries AS c ON c.Id = d.CountryId
  JOIN Feedbacks AS f ON f.ProductId = p.Id
  JOIN CTE_ProductsIngredientsDistributors AS cte ON cte.ProductName = p.Name
 GROUP BY p.Id, p.Name, d.Name, c.Name, cte.DistributorsCount
HAVING DistributorsCount = 1
 ORDER BY p.Id