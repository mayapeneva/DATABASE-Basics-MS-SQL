USE ReportService
GO

--5.	Users by Age
SELECT Username, Age
  FROM Users
 ORDER BY Age, Username DESC

--6.	Unassigned Reports
SELECT r.Description, r.OpenDate
  FROM Reports AS r
 WHERE r.EmployeeId IS NULL
 ORDER BY r.OpenDate, r.Description

--7.	Employees & Reports
SELECT e.FirstName, e.LastName, r.Description, FORMAT(r.OpenDate, 'yyyy-MM-dd')
  FROM Employees AS e
  JOIN Reports AS r ON r.EmployeeId = e.Id
 ORDER BY e.Id, r.OpenDate, r.Id

--8.	Most reported Category
SELECT c.Name AS CategoryName, COUNT(r.Id) AS ReportsNumber
  FROM Reports AS r
  JOIN Categories AS c ON c.Id = r.CategoryId
 GROUP BY c.Id, c.Name
 ORDER BY ReportsNumber DESC, c.Name

--9.	Employees in Category
SELECT c.Name AS CategoryName, COUNT(e.Id) AS EmployeesNumber
  FROM Categories AS c
  LEFT JOIN Departments AS d ON d.Id = c.DepartmentId
  LEFT JOIN Employees AS e ON e.DepartmentId = d.Id
 GROUP BY c.Name
 ORDER BY c.Name

--10.	Users per Employee 
SELECT CONCAT(e.FirstName, ' ', e.LastName) AS Name, 
		COUNT(DISTINCT r.UserId) AS UsersNumber
  FROM Employees AS e
  LEFT JOIN Reports AS r ON r.EmployeeId = e.Id
 GROUP BY e.FirstName, e.LastName
 ORDER BY UsersNumber DESC, Name

--11.	Emergency Patrol
SELECT r.OpenDate, r.Description, u.Email AS [Reporter Email]
  FROM Reports AS r
  JOIN Categories AS c ON c.Id = r.CategoryId
  JOIN Users AS u ON u.Id = r.UserId
 WHERE r.CloseDate IS NULL
		AND (LEN(r.Description) > 20
		AND r.Description LIKE '%str%')
		AND c.DepartmentId IN(SELECT Id FROM Departments WHERE Name IN('Infrastructure', 'Emergency', 'Roads Maintenance'))
 ORDER BY r.OpenDate, u.Email, r.Id

--12.	Birthday Report
SELECT DISTINCT c.Name AS CategoryName
  FROM Categories AS c
  JOIN Reports AS r ON r.CategoryId = c.Id
  JOIN Users AS u ON u.Id = r.UserId
 WHERE DAY(r.OpenDate) = DAY(u.BirthDate) 
		AND MONTH(r.OpenDate) = MONTH(u.BirthDate) 
 ORDER BY CategoryName

--13.	Numbers Coincidence
SELECT DISTINCT u.Username
  FROM Users AS u
  JOIN Reports AS r ON r.UserId = u.Id
  JOIN Categories AS c ON c.Id = r.CategoryId
 WHERE (u.Username LIKE '[0-9]%' AND CAST(c.Id as VARCHAR) = LEFT(u.Username, 1))
		OR (u.Username LIKE '%[0-9]' AND CONVERT(VARCHAR, c.Id) = RIGHT(u.Username, 1))
 ORDER BY Username

--14.	Open/Closed Statistics
SELECT CONCAT(e.FirstName, ' ', e.LastName) AS Name, 
		CONCAT(ISNULL(ClosedReports, 0), '/', ISNULL(OpenedReports, 0))
  FROM Employees AS e
  JOIN 
   (SELECT EmployeeId AS Id,
			COUNT(*) AS OpenedReports
	  FROM Reports
	 WHERE DATEPART(YEAR, OpenDate) = 2016
	 GROUP BY EmployeeId) AS Opened ON Opened.Id = e.Id
  LEFT JOIN
   (SELECT EmployeeId AS Id,
			COUNT(*) AS ClosedReports
	  FROM Reports
	 WHERE DATEPART(YEAR, CloseDate) = 2016
	 GROUP BY EmployeeId) AS Closed ON Closed.Id = e.Id
 ORDER BY Name, e.Id

--15.	Average Closing Time
SELECT d.Name AS [Department Name],
		CASE
			WHEN AVG(DATEDIFF(DAY, r.OpenDate, r.CloseDate)) IS NULL THEN 'no info'
			ELSE STR(AVG(DATEDIFF(DAY, r.OpenDate, r.CloseDate))) 
		END AS [Average Duration]
 FROM Departments AS d
 JOIN Categories AS c On c.DepartmentId = d.Id
 JOIN Reports AS r ON r.CategoryId = c.Id
GROUP BY d.Name
GO

--16.	Favorite Categories
WITH CTE_CategoriesCount AS(	
	SELECT d.Name AS [Department Name],
			c.Name AS [Category Name],
			COUNT(c.Id) AS Categories
	  FROM Departments AS d
	  JOIN Categories AS c ON c.DepartmentId = d.Id
	  JOIN Reports AS r On r.CategoryId = c.Id
	 GROUP BY d.Name, c.Name)

SELECT cte.[Department Name],
		cte.[Category Name],
		CAST(ROUND(cte.Categories * 100.00 / a.AllReports, 0) as INT) AS Percentage
  FROM CTE_CategoriesCount AS cte 
  JOIN (SELECT d.Name, COUNT(r.Id) AS AllReports
		  FROM Departments AS d
		  JOIN Categories AS c ON c.DepartmentId = d.Id
		  JOIN Reports AS r ON r.CategoryId = c.Id
		 GROUP BY d.Name) AS a ON a.Name = cte.[Department Name]
 ORDER BY cte.[Department Name], cte.[Category Name], Percentage