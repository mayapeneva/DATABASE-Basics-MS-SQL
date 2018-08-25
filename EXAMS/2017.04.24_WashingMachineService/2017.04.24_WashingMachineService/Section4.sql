USE WMS
GO

--17.	Cost of Order
CREATE FUNCTION udf_GetCost(@jobId INT)
RETURNS DECIMAL(15, 2)
AS
BEGIN
	DECLARE @result DECIMAL(15, 2) = (
	SELECT ISNULL(SUM(p.Price), 0)
	  FROM Jobs AS j
	  LEFT JOIN Orders AS o
		ON o.JobId = j.JobId
	  LEFT JOIN OrderParts AS op
		ON op.OrderId = o.OrderId
	  LEFT JOIN Parts AS p
		ON p.PartId = op.PartId
	 WHERE j.JobId = @jobId)

	 RETURN @result;
END

SELECT dbo.udf_GetCost(1)
GO

--18.	Place Order
CREATE PROC usp_PlaceOrder(@jobId INT, @partSerialNumber NVARCHAR(50), @quantity INT) AS
BEGIN
	DECLARE @partId INT = (SELECT PartId FROM Parts WHERE SerialNumber = @partSerialNumber)
	DECLARE @orderId INT = (SELECT TOP(1) OrderId FROM Orders WHERE JobId = @jobId AND issueDate IS NULL)

	IF(EXISTS(SELECT JobId FROM Jobs WHERE JobId = @jobId AND Status = 'Finished'))
		BEGIN
			;THROW 50011, 'This job is not active!', 1
		END
	
	IF(@quantity <= 0)
		BEGIN
			;THROW 50012, 'Part quantity must be more than zero!', 1
		END

	IF(NOT EXISTS(SELECT JobId FROM Jobs WHERE JobId = @jobId))
		BEGIN
			;THROW 50013, 'Job not found!', 1
		END
	
	IF(@partId IS NULL)
		BEGIN
			;THROW 50014, 'Part not found!', 1
		END

	IF(@orderId IS NOT NULL)
		BEGIN
			IF((SELECT PartId FROM OrderParts WHERE OrderId = @orderId AND PartId = @partId) IS NOT NULL)
			BEGIN
				UPDATE OrderParts
				SET Quantity += @quantity
				WHERE OrderId = @orderId AND PartId = @partId
			END
			ELSE
			BEGIN
				INSERT INTO OrderParts(OrderId, PartId, Quantity) VALUES
				(@orderId, @partId, @quantity)
			END
		END
	ELSE
		BEGIN
			INSERT INTO Orders(JobId, IssueDate) VALUES
			(@jobId, NULL)

			DECLARE @id INT = (SELECT TOP(1) OrderId FROM Orders WHERE JobId = @jobId)

			INSERT INTO OrderParts(OrderId, PartId, Quantity) VALUES
			(@id, @partId, @quantity)
		END
END

DECLARE @err_msg AS NVARCHAR(MAX);
BEGIN TRY
  EXEC usp_PlaceOrder 1, 'ZeroQuantity', 0
END TRY

BEGIN CATCH
  SET @err_msg = ERROR_MESSAGE();
  SELECT @err_msg
END CATCH
GO

--19.	Detect Delivery
CREATE TRIGGER tr_DetectDelivery
ON Orders
FOR UPDATE 
AS
UPDATE Parts
   SET StockQty += op.Quantity
  FROM Parts AS p
  JOIN OrderParts AS op
    ON op.PartId = p.PartId
  JOIN Orders AS o
    ON o.OrderId = op.OrderId
  JOIN inserted AS i
    ON i.OrderId = o.OrderId
  JOIN deleted AS d
    ON d.OrderId = o.OrderId
 WHERE d.Delivered = 0 AND i.Delivered = 1

UPDATE Orders
SET Delivered = 1
WHERE OrderId = 21

--20.	Vendor Preference
WITH CTE_MechanicAllPartsCount AS(
	SELECT m.MechanicId,
			SUM(op.Quantity) AS AllPartsCount
	  FROM Mechanics AS m
	  JOIN Jobs AS j
		ON j.MechanicId = m.MechanicId
	  JOIN Orders AS o
		ON o.JobId = j.JobId
	  LEFT JOIN OrderParts AS op
		ON op.OrderId = o.OrderId
	  LEFT JOIN Parts AS p
		ON p.PartId = op.PartId
	  LEFT JOIN Vendors As v
		ON v.VendorId = p.VendorId
	 GROUP BY m.MechanicId, m.FirstName, m.LastName)

SELECT m.FirstName + ' ' + m.LastName AS Mechanic,
		v.Name AS Vendor,
		ISNULL(SUM(op.Quantity), 0) AS Parts,
		CONVERT(VARCHAR, (ISNULL(SUM(op.Quantity), 0) * 100) /cte.AllPartsCount) + '%' AS Preference
  FROM Mechanics AS m
  JOIN Jobs AS j
	ON j.MechanicId = m.MechanicId
  JOIN Orders AS o
	ON o.JobId = j.JobId
  JOIN OrderParts AS op
	ON op.OrderId = o.OrderId
  JOIN Parts AS p
	ON p.PartId = op.PartId
  JOIN Vendors As v
	ON v.VendorId = p.VendorId
  LEFT JOIN CTE_MechanicAllPartsCount AS cte
    ON cte.MechanicId = m.MechanicId
 GROUP BY m.MechanicId, m.FirstName, m.LastName, v.VendorId, v.Name, cte.AllPartsCount
 ORDER BY Mechanic, Parts DESC, Vendor