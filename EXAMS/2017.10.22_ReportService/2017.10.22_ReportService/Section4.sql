USE ReportService
GO

--17.	Employee’s Load
CREATE FUNCTION udf_GetReportsCount(@employeeId INT, @statusId INT) 
RETURNS INT
AS
BEGIN
	RETURN 
		(SELECT COUNT(*)
		  FROM Reports AS r
		 WHERE r.EmployeeId = @employeeId AND r.StatusId = @statusId)
END

SELECT dbo.udf_GetReportsCount(5, 4)

--18.	Assign Employee
CREATE PROC usp_AssignEmployeeToReport(@employeeId INT, @reportId INT) AS
BEGIN
	BEGIN TRAN
		UPDATE Reports
		SET EmployeeId = @employeeId
		WHERE Id = @reportId 

		DECLARE @employeeDepartmentId INT = (
				SELECT DepartmentID 
				  FROM Employees 
				 WHERE Id = @employeeId)
		DECLARE @categoryDepartmentId INT = (
				SELECT c.DepartmentId 
				  FROM Reports AS r
				  JOIN Categories AS c
				    ON c.Id = r.CategoryId
				 WHERE r.Id = @reportId)

		IF(@employeeDepartmentId <> @categoryDepartmentId)
		BEGIN
			RAISERROR('Employee doesn''t belong to the appropriate department!', 16, 1);
			ROLLBACK;
			RETURN;
		END

	COMMIT;
END

EXEC usp_AssignEmployeeToReport 17, 2;
SELECT EmployeeId FROM Reports WHERE id = 2

--19.	Close Reports
CREATE TRIGGER tr_CloseReports 
ON Reports
AFTER UPDATE
AS
BEGIN
	IF ((SELECT CloseDate
		   FROM inserted
		  WHERE Id = (SELECT Max(Id) FROM inserted)) IS NOT NULL)
	BEGIN
		DECLARE @reportId INT = (SELECT Id
								   FROM inserted
								  WHERE Id = (SELECT Max(Id) FROM inserted))
		
		UPDATE Reports
		SET StatusId = (SELECT Id FROM Status WHERE Label = 'completed')
		WHERE Id = @reportId
	END
END

UPDATE Reports
SET CloseDate = GETDATE()
WHERE EmployeeId = 5

--20.	Categories Revision
SELECT c.Name AS [Category Name], 
		COUNT(r.Id) AS [Reports Number],
		CASE
				WHEN InProgressCount > WaitingCount THEN 'in progress'
				WHEN InProgressCount < WaitingCount THEN 'waiting'
				ELSE 'equal'
		END AS [Main Status]
  FROM Categories AS c
  JOIN Reports AS r
    ON r.CategoryId = c.Id
  JOIN Status AS s
    ON s.Id = r.StatusId
  JOIN (SELECT r.CategoryId,
				SUM(CASE WHEN s.Label = 'in progress' THEN 1 ELSE 0 END) AS InProgressCount,
				SUM(CASE WHEN s.Label = 'waiting' THEN 1 ELSE 0 END) AS WaitingCount
		  FROM Status AS s
		  JOIN Reports AS r
		    ON r.StatusId = s.Id
		 GROUP BY r.CategoryId) AS ct
	ON ct.CategoryId = c.Id
 WHERE s.Label IN('waiting', 'in progress')
 GROUP BY c.Name,
			CASE
				WHEN InProgressCount > WaitingCount THEN 'in progress'
				WHEN InProgressCount < WaitingCount THEN 'waiting'
				ELSE 'equal'
			END
 ORDER BY c.Name, [Reports Number], [Main Status]