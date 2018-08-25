USE RentACar
GO

--17.	Find My Ride
CREATE FUNCTION udf_CheckForVehicle(@townName NVARCHAR(50), @seatsNumber INT) 
RETURNS NVARCHAR(50) AS
BEGIN

	RETURN ISNULL((SELECT TOP(1) CONCAT(o.Name, ' - ', m.Model)
					 FROM Vehicles AS v
					 JOIN Models AS m ON m.Id = v.ModelId
					 JOIN Offices AS o ON o.Id = v.OfficeId
					 JOIN Towns AS t ON t.Id = o.TownId
					WHERE t.Name = @townName AND m.Seats = @seatsNumber
					ORDER BY o.Name), 'NO SUCH VEHICLE FOUND')
END

SELECT dbo.udf_CheckForVehicle ('La Escondida', 9) 
GO

--18.	Move a Vehicle
CREATE PROC usp_MoveVehicle(@vehicleId INT, @officeId INT)
AS
BEGIN
	UPDATE Vehicles
	SET OfficeId = @officeId
	WHERE Id = @vehicleId

	DECLARE @vehiclesInOfficeCount INT = (SELECT COUNT(Id) FROM Vehicles WHERE OfficeId = @officeId)

	DECLARE @parkingSpacesCount INT = (SELECT ParkingPlaces FROM Offices WHERE Id = @officeId)

	IF(@parkingSpacesCount <= @vehiclesInOfficeCount)
	BEGIN
		RAISERROR('Not enough room in this office!', 16, 1);
		ROLLBACK;
		RETURN;
	END
END

EXEC usp_MoveVehicle 7, 32;
SELECT OfficeId FROM Vehicles WHERE Id = 7
GO

-- 19.	Move the Tally
CREATE TRIGGER tr_MoveTheTally 
ON Orders
AFTER UPDATE
AS
BEGIN
		DECLARE @newTotalMileage INT = (SELECT TotalMileage 
						  FROM inserted)

		DECLARE @oldTotalMileage INT = (SELECT TotalMileage 
						  FROM deleted)

		IF(@oldTotalMileage IS NULL)
		UPDATE Vehicles
		SET Mileage += @newTotalMileage
		WHERE Id = (SELECT VehicleId from inserted)
END