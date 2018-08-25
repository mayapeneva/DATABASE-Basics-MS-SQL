USE SoftUni
GO

SELECT * FROM Departments
GO

SELECT Name FROM Departments
GO

SELECT FirstName, LastName, Salary FROM Employees
GO

SELECT FirstName, MiddleName, LastName FROM Employees
GO

SELECT FirstName + '.' + LastName + '@softuni.bg' 
	AS [Full Email Address] 
  FROM Employees
GO

SELECT DISTINCT Salary FROM Employees
GO

SELECT * FROM Employees
WHERE JobTitle = 'Sales Representative'
GO

SELECT FirstName, LastName, JobTitle FROM Employees
WHERE Salary BETWEEN 20000 AND 30000
GO

SELECT FirstName + ' ' + MiddleName + ' ' + LastName AS [Full Name] 
  FROM Employees
 WHERE Salary IN (25000, 14000, 12500, 23600)
GO

SELECT FirstName, LastName FROM Employees
 WHERE ManagerID IS NULL
GO

SELECT FirstName, LastName, Salary FROM Employees
 WHERE Salary > 50000
 ORDER BY Salary DESC
GO

SELECT TOP(5) FirstName, LastName FROM Employees
 ORDER BY Salary DESC
GO

SELECT FirstName, LastName FROM Employees
 WHERE NOT (DepartmentId = 4)
GO

SELECT * FROM Employees
 ORDER BY Salary DESC, FirstName ASC, LastName DESC, MiddleName ASC
GO

CREATE VIEW V_EmployeesSalaries AS
SELECT FirstName, LastName, Salary FROM Employees
GO

CREATE VIEW V_EmployeeNameJobTitle AS
SELECT FirstName + ' ' + ISNULL(MiddleName, '') + ' ' + LastName AS [Full Name],
	   JobTitle AS [Job Title]
  FROM Employees
GO

SELECT DISTINCT JobTitle FROM Employees
GO

SELECT TOP (10) * FROM Projects
 ORDER BY StartDate, Name
GO

SELECT TOP (7) FirstName, LastName, HireDate FROM Employees
 ORDER BY HireDate DESC
GO

UPDATE Employees
SET Salary += Salary * 0.12
 WHERE DepartmentId IN (SELECT DepartmentId 
						  FROM Departments 
						  WHERE Name IN('Engineering', 'Tool Design', 'Marketing', 'Information Services') )

SELECT Salary FROM Employees
GO