USE SoftUni
GO

--Problem 21. Employees with Three Projects
CREATE PROC usp_AssignProject(@emloyeeId INT, @projectID INT) 
AS
BEGIN
	DECLARE @employeesProjectsCount INT = (
		SELECT COUNT(*)
		  FROM EmployeesProjects
		 GROUP BY EmployeeID
		HAVING EmployeeID = @emloyeeId)
	IF(@employeesProjectsCount > 2)
	BEGIN
		RAISERROR('The employee has too many projects!', 16, 1)
		ROLLBACK
	END

	INSERT INTO EmployeesProjects VALUES
	(@emloyeeId, @projectID)
END 
GO

--Problem 22. Delete Employees
CREATE TABLE Deleted_Employees(
EmployeeId INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50), 
LastName NVARCHAR(50),
MiddleName NVARCHAR(50),
JobTitle VARCHAR(50), 
DepartmentId INT,
Salary DECIMAL(15, 2) 
)

CREATE TRIGGER tr_DeleteEmployees
ON Employees
AFTER DELETE AS
BEGIN
	INSERT INTO Deleted_Employees
	SELECT FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary
	  FROM deleted
END