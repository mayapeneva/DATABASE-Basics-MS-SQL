USE ReportService
GO

--5.	Users by Age
SELECT Username, Age
  FROM Users
 ORDER BY Age, Username DESC

--6.	Unassigned Reports
SELECT Description, OpenDate
  FROM Reports
 WHERE EmployeeId IS NULL
 ORDER BY OpenDate, Description

--7.	Employees & Reports
SELECT e.FirstName, e.LastName, r.Description, FORMAT(r.OpenDate, 'yyyy-MM-dd')
  FROM Employees AS e
  JOIN Reports AS r
    ON r.EmployeeId = e.Id
 GROUP BY e.ID, e.FirstName, e.LastName, r.Id, r.Description, r.OpenDate
 ORDER BY e.Id, r.OpenDate, r.Id

--8.	Most reported Category
SELECT c.Name AS CategoryName, COUNT(r.Id) AS ReportsNumber
  FROM Categories AS c
  JOIN Reports AS r
    ON r.CategoryId = c.Id
 GROUP BY c.Id, c.Name
 ORDER BY COUNT(r.Id) DESC, c.Name

--9.	Employees in Category
SELECT c.Name AS CategoryName, COUNT(e.Id) AS EmployeesNumber
  FROM Categories AS c
  JOIN Departments AS d
    ON d.Id = c.DepartmentId
  JOIN Employees AS e
    ON e.DepartmentId = d.Id
 GROUP BY c.Name
 ORDER BY c.Name

--10.	Users per Employee 
SELECT e.FirstName + ' ' + e.LastName AS Name, COUNT(r.UserId) AS UsersNumber
  FROM Employees AS e
  LEFT JOIN Reports AS r
    ON r.EmployeeId = e.Id
 GROUP BY e.Id, e.FirstName, e.LastName
 ORDER BY COUNT(r.UserId) DESC, Name

--11.	Emergency Patrol
SELECT r.OpenDate, r.Description, u.Email
  FROM Reports AS r
  JOIN Categories AS c
    ON c.Id = r.CategoryId
  JOIN Departments AS d
    ON d.Id = c.DepartmentId
  JOIN Users AS u
    ON u.Id = r.UserId
 WHERE CloseDate IS NULL 
		AND LEN(r.Description) > 20 
		AND r.Description LIKE '%str%'
		AND c.DepartmentId IN(SELECT Id FROM Departments WHERE Name IN('Infrastructure', 'Emergency', 'Roads Maintenance'))
 ORDER BY r.OpenDate, u.Email, r.Id

--12.	Birthday Report
SELECT c.Name AS [Category Name]
  FROM Categories AS c
  JOIN Reports AS r
    ON r.CategoryId = c.Id
  JOIN Users AS u
    ON u.Id = r.UserId
 WHERE DATEPART(DAY, r.OpenDate) = DATEPART(DAY, u.BirthDate) AND 
		DATEPART(MONTH, r.OpenDate) = DATEPART(MONTH, u.BirthDate) 
 GROUP BY c.Name
 ORDER BY c.Name

--13.	Numbers Coincidence
SELECT DISTINCT u.Username
  FROM Users AS u
  JOIN Reports AS r
    ON r.UserId = u.Id
  JOIN Categories AS c
    ON c.Id = r.CategoryId
 WHERE (u.Username LIKE '[0-9]%' AND CAST(c.Id AS VARCHAR) = LEFT(u.Username, 1))
		OR (u.Username LIKE '%[0-9]' AND CAST(c.Id AS VARCHAR) = RIGHT(u.Username, 1))
 ORDER BY Username

--14.	Open/Closed Statistics
SELECT e.FirstName + ' ' + e.LastName AS Name,
		ISNULL(CONVERT(varchar, cr.CloseReport), '0') 
		+ '/' +        
		ISNULL(CONVERT(varchar, orp.OpenReport), '0') AS ClosedReports
  FROM Employees AS e
  JOIN (SELECT EmployeeId, COUNT(*) AS OpenReport
		  FROM Reports
		 WHERE DATEPART(YEAR, OpenDate) = 2016
		 GROUP BY EmployeeId) AS orp
	ON orp.EmployeeId = e.Id
  LEFT JOIN (SELECT EmployeeId, COUNT(*) AS CloseReport
			   FROM Reports
			  WHERE DATEPART(YEAR, CloseDate) = 2016
			  GROUP BY EmployeeId) AS cr
	ON cr.EmployeeId = e.Id
 ORDER BY Name

--15.	Average Closing Time
SELECT d.Name AS [Department Name], 
		CASE
			WHEN AVG(ROUND(DATEDIFF(DAY, r.OpenDate, r.CloseDate), 0)) IS NULL THEN 'no info'
			ELSE STR(AVG(ROUND(DATEDIFF(DAY, r.OpenDate, r.CloseDate), 0)))
		END AS [Average Duration]
  FROM Departments AS d
  JOIN Categories AS c
    ON c.DepartmentId = d.Id
  JOIN Reports AS r
    ON r.CategoryId = c.Id
 GROUP BY d.Name

--16.	Favorite Categories
SELECT [Department Name], [Category Name], Percentage
  FROM
	(SELECT d.Name AS [Department Name], 
			c.Name AS [Category Name], 
			CAST(ROUND(
				COUNT(*) OVER(PARTITION BY c.Id) * 100.00 /
				COUNT(*) OVER(PARTITION BY d.Id), 0) as INT)
			AS Percentage
	  FROM Departments AS d
	  JOIN Categories AS c
		ON c.DepartmentId = d.Id
	  JOIN Reports AS r
		ON r.CategoryId = c.Id) AS a
 GROUP BY [Department Name], [Category Name], Percentage
 ORDER BY [Department Name], [Category Name], Percentage