--18. Available Room
CREATE FUNCTION udf_GetAvailableRoom(@HotelId INT, @Date DATE, @People INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @result NVARCHAR(MAX);

	DECLARE @roomId INT = 
		(SELECT TOP(1) r.Id
		  FROM Rooms AS r
		  JOIN Trips AS t ON t.RoomId = r.Id
		  JOIN Hotels AS h ON h.Id = r.HotelId
		 WHERE (HotelId = @HotelId AND Beds = @People) 
			AND (@Date < ALL(SELECT t.ArrivalDate FROM Trips WHERE RoomId = r.Id) OR @DATE > ALL(SELECT t.ArrivalDate FROM Trips WHERE RoomId = r.Id))
		 GROUP BY h.BaseRate, r.Id, r.Price
		 ORDER BY ((h.BaseRate + r.Price) * @People) DESC)

	DECLARE @roomType NVARCHAR(20) = 
		(SELECT Type FROM Rooms WHERE Id = @roomId)

	DECLARE @beds INT = 
		(SELECT Beds FROM Rooms WHERE Id = @roomId)

	DECLARE @totalPrice DECIMAL(15, 2) = 
		(SELECT ((h.BaseRate + r.Price) * @People) FROM Rooms AS r JOIN Hotels AS h ON h.Id = r.HotelId WHERE r.Id = @roomId)

	IF(@roomId IS NULL)
	BEGIN
		SET @result = 'No rooms available';
	END
	ELSE
	BEGIN		
		SET @result = CONCAT('Room ', @roomId, ': ', @roomType, ' (', @beds, ' beds) - $', @totalPrice)
	END

	RETURN @result;
END

SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2)

SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3)
GO

--19. Switch Room
CREATE PROC usp_SwitchRoom(@TripId INT, @TargetRoomId INT) AS
BEGIN
	IF((SELECT r.HotelId FROM Trips AS T JOIN Rooms AS r ON r.Id = t.RoomId WHERE t.Id = @TripId) <> (SELECT HotelId FROM Rooms WHERE Id = @TargetRoomId))
	BEGIN
		RAISERROR('Target room is in another hotel!', 16, 1)
	END

	IF((SELECT Beds FROM Rooms WHERE Id = @TargetRoomId) < (SELECT COUNT(*) FROM AccountsTrips WHERE TripId = @TripId))
	BEGIN
		RAISERROR('Not enough beds in target room!', 16, 2)
	END

	UPDATE Trips
	   SET RoomId = @TargetRoomId
	 WHERE Id = @TripId
END

EXEC usp_SwitchRoom 10, 11
SELECT RoomId FROM Trips WHERE Id = 10
GO

--20. Cancel Trip
CREATE TRIGGER tr_CancelTrip 
ON Trips
INSTEAD OF DELETE
AS
BEGIN
	UPDATE Trips
		   SET CancelDate = GETDATE()
		 WHERE Id IN (SELECT Id FROM deleted 
					  WHERE CancelDate IS NULL)
END

DELETE FROM Trips
WHERE Id IN (48, 49, 50)
