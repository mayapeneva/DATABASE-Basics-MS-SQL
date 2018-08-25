USE SoftUni
GO

CREATE PROC usp_GetEmployeesSalaryAbove35000 AS(
	SELECT FirstName AS [First Name], LastName AS [Last Name]
	  FROM Employees
	 WHERE Salary > 35000
)
GO

CREATE PROC usp_GetEmployeesSalaryAboveNumber (@targetSalary DECIMAL(15, 2)) AS(
	SELECT FirstName AS [First Name], LastName AS [Last Name]
	  FROM Employees
	 WHERE Salary >= @targetSalary
)
GO

CREATE PROC usp_GetTownsStartingWith(@prefix VARCHAR(50)) AS 
BEGIN
	SELECT Name
	  FROM Towns
	 WHERE SUBSTRING(Name, 1, LEN(@prefix)) = @Prefix
END
GO

CREATE PROC usp_GetEmployeesFromTown(@townName VARCHAR(50)) AS
BEGIN
	SELECT FirstName AS [First Name], LastName AS [Last Name] 
	  FROM Employees AS e
	  JOIN Addresses AS a
	    ON a.AddressID = e.AddressID
	  JOIN Towns AS t
	    ON t.TownID = a.TownID
	 WHERE t.Name = @townName
END
GO

CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @salaryLevel VARCHAR(50);
	IF (@salary < 30000)
	BEGIN 
		SET @salaryLevel = 'Low';
	END
	ELSE IF (@salary >= 30000 AND @salary <= 50000)
	BEGIN 
		SET @salaryLevel = 'Average';
	END
	ELSE
	BEGIN 
		SET @salaryLevel = 'High';
	END
	RETURN @salaryLevel
END
GO

SELECT dbo.ufn_GetSalaryLevel(30000)
GO

CREATE PROC usp_EmployeesBySalaryLevel (@salaryLevel VARCHAR(50)) AS(
	SELECT FirstName AS [First Name], LastName AS [Last Name]
	  FROM Employees
	 WHERE dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel
)
GO

CREATE FUNCTION ufn_IsWordComprised (@setOfLetters VARCHAR(MAX), @word VARCHAR(MAX)) 
RETURNS BIT 
AS
BEGIN
	DECLARE @wordLength INT = LEN(@word);
	DECLARE @index INT = 1;
	DECLARE @letter CHAR(1);

	WHILE (@index <= @wordLength)
	BEGIN
		SET @letter = SUBSTRING(@word, @index, 1)
		IF (@setOfLetters NOT LIKE CONCAT('%', @letter, '%'))
			RETURN 0;
		SET @index += 1;
	END

	RETURN 1
END

SELECT dbo.ufn_IsWordComprised('bobr', 'Rob')
GO

CREATE PROC usp_DeleteEmployeesFromDepartment(@departmentId INT) 
AS 
BEGIN 
	 ALTER TABLE Departments
	 ALTER COLUMN ManagerID INT

	DELETE FROM EmployeesProjects
	 WHERE EmployeeID IN (
		SELECT EmployeeID FROM Employees
		 WHERE DepartmentID = @departmentId)

	UPDATE Employees
	   SET ManagerID = NULL
	 WHERE ManagerID IN (
		SELECT EmployeeID FROM Employees
		 WHERE DepartmentID = @departmentId)

	UPDATE Departments
	   SET ManagerID = NULL
	 WHERE ManagerID IN (
		SELECT EmployeeID FROM Employees
		 WHERE DepartmentID = @departmentId)

	DELETE FROM Employees
	 WHERE DepartmentID = @departmentId

	 DELETE FROM Departments
	 WHERE DepartmentID = @departmentId

	 SELECT COUNT(*)
	   FROM Employees
	  WHERE DepartmentID = @departmentId
END
GO