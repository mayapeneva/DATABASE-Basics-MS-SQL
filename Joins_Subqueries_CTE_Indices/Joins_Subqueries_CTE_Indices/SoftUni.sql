USE SoftUni
GO

SELECT TOP (5) e.EmployeeID, e.JobTitle, e.AddressID, a.AddressText  
  FROM Employees AS e
  JOIN Addresses AS a
    ON a.AddressID = e.AddressID
 ORDER BY e.AddressID
GO

SELECT TOP (50) e.FirstName, e.LastName, t.Name, a.AddressText  
  FROM Employees AS e
  JOIN Addresses AS a
    ON a.AddressID = e.AddressID
  JOIN Towns AS t
    ON t.TownID = a.TownID
 ORDER BY e.FirstName, e.LastName
GO

SELECT e.EmployeeID, e. FirstName, e.LastName, d.Name 
  FROM Employees AS e
  JOIN Departments AS d
    ON d.DepartmentID = e.DepartmentID
 WHERE d.Name = 'Sales'
 ORDER BY e.EmployeeID
GO

SELECT TOP (5) e.EmployeeID, e. FirstName, e.Salary, d.Name 
  FROM Employees AS e
  JOIN Departments AS d
    ON d.DepartmentID = e.DepartmentID
 WHERE e.Salary > 15000
 ORDER BY e.DepartmentID
GO

SELECT TOP (3) e.EmployeeID, e.FirstName 
  FROM Employees AS e
  LEFT JOIN EmployeesProjects AS ep
    ON ep.EmployeeID = e.EmployeeID
 WHERE ep.EmployeeID IS NULL
 ORDER BY e.EmployeeID
GO

SELECT e.FirstName, e.LastName, e.HireDate, d.Name 
  FROM Employees AS e
  JOIN Departments AS d
    ON d.DepartmentID = e.DepartmentID
 WHERE e.HireDate > '01/01/1999' AND d.Name IN ('Sales', 'Finance')
 ORDER BY e.HireDate
GO

SELECT TOP (5) e.EmployeeID, e.FirstName, p.Name AS ProjectName 
  FROM Employees AS e
  JOIN EmployeesProjects as ep
    ON ep.EmployeeID = e.EmployeeID
  JOIN Projects AS p
    ON p.ProjectID = ep.ProjectID
 WHERE p.StartDate > '08/13/2002' AND p.EndDate IS NULL
 ORDER BY e.EmployeeID
GO

SELECT e.EmployeeID, e.FirstName,
  CASE
	WHEN p.StartDate > '12/31/2004' THEN NULL
	ELSE p.Name
  END
  FROM Employees AS e
  JOIN EmployeesProjects as ep
    ON ep.EmployeeID = e.EmployeeID
  JOIN Projects AS p
    ON p.ProjectID = ep.ProjectID
 WHERE e.EmployeeID = 24 
GO

SELECT e.EmployeeID, e.FirstName, e.ManagerID, e2.FirstName
  FROM Employees AS e
  JOIN Employees AS e2
    ON e2.EmployeeID = e.ManagerID
 WHERE e.ManagerID IN (3, 7)
 ORDER BY EmployeeID
GO

SELECT TOP (50) 
		e.EmployeeID, 
		e.FirstName + ' ' + e.LastName AS EmployeeName,
		e2.FirstName + ' ' + e2.LastName AS ManagerName, 
		d.Name AS DepartmentName
  FROM Employees AS e
  JOIN Employees AS e2
    ON e2.EmployeeID = e.ManagerID
  JOIN Departments AS d
    ON d.DepartmentID = e.DepartmentID
 ORDER BY EmployeeID
GO

SELECT TOP (1) AVG(Salary) AS MinAverageSalary
  FROM Employees
 GROUP BY DepartmentID
 ORDER BY AVG(Salary)
GO