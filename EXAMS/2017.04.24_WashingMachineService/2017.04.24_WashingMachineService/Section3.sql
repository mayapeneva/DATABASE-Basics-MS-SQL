--5.	Clients by Name
SELECT FirstName, LastName, Phone 
  FROM Clients
 ORDER BY LastName, ClientId

--6.	Job Status
SELECT Status, IssueDate
  FROM Jobs
 WHERE Status <> 'Finished'
 ORDER BY IssueDate, JobId

--7.	Mechanic Assignments
SELECT m.FirstName + ' ' + m.LastName AS Mechanic,
		j.Status, j.IssueDate
  FROM Mechanics AS m
  JOIN Jobs AS j
    ON j.MechanicId = m.MechanicId
 ORDER BY m.MechanicId, IssueDate, JobId

--8.	Current Clients
SELECT c.FirstName + ' ' + c.LastName AS Client,
		DATEDIFF(DAY, j.IssueDate, '2017/04/24') AS [Days going],
		j.Status
  FROM Clients AS c
  JOIN Jobs AS j
    ON j.ClientId = c.ClientId
 WHERE j.Status <> 'Finished'
 ORDER BY [Days going] DESC, c.ClientId

--9.	Mechanic Performance
SELECT m.FirstName + ' ' + m.LastName AS Mechanic,
		CAST(SUM(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) / COUNT(j.JobId) as INT) AS [Average Days]
  FROM Mechanics AS m
  JOIN Jobs AS j
    ON j.MechanicId = m.MechanicId
 WHERE j.Status = 'Finished'
 GROUP BY m.MechanicId, m.FirstName, m.LastName
 ORDER BY m.MechanicId

--10.	Hard Earners
SELECT TOP(3) m.FirstName + ' ' + m.LastName AS Mechanic,
				COUNT(j.JobId) AS Jobs
  FROM Mechanics AS m
  JOIN Jobs AS j
    ON j.MechanicId = m.MechanicId
 WHERE j.Status <> 'Finished' AND (SELECT COUNT(JobId) FROM Jobs WHERE MechanicId = m.MechanicId AND Status <> 'Finished') > 1
 GROUP BY m.MechanicId, m.FirstName, m.LastName
 ORDER BY Jobs DESC, m.MechanicId

--11.	Available Mechanics
SELECT Available
  FROM(SELECT m.MechanicId, 
				m.FirstName + ' ' + m.LastName AS Available,
				SUM(CASE
						WHEN j.Status IN('Pending', 'In Progress') THEN 1 ELSE 0
					END) AS ActiveJobsCount
		 FROM Mechanics AS m
		 LEFT JOIN Jobs AS j
		   ON j.MechanicId = m.MechanicId
		GROUP BY m.MechanicId, m.FirstName, m.LastName) AS a
 WHERE ActiveJobsCount = 0
 ORDER BY MechanicId

--12.	Parts Cost
SELECT ISNULL(SUM(p.Price * op.Quantity), 0) AS [Parts Total]
  FROM Parts AS p
  JOIN OrderParts AS op
    ON op.PartId = p.PartId
  JOIN Orders AS o
    ON op.OrderId = o.OrderId
 WHERE o.IssueDate BETWEEN '2017/04/02' AND '2017/04/24'

--13.	Past Expenses
SELECT j.JobId, ISNULL(SUM(p.Price * op.Quantity), 0) AS Total
  FROM Jobs AS j
  LEFT JOIN Orders AS o
    ON o.JobId = j.JobId
  LEFT JOIN OrderParts AS op
    ON op.OrderId = o.OrderId
  LEFT JOIN Parts AS p
    ON p.PartId = op.PartId
 WHERE j.Status = 'Finished'
 GROUP BY j.JobId
 ORDER BY Total DESC, JobId

--14.	Model Repair Time
SELECT ModelId, Name, CAST([Average Service Time] AS VARCHAR) + ' days'
  FROM(
	SELECT m.ModelId, m.Name, CAST(SUM(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) / COUNT(j.JobId) AS INT) AS [Average Service Time]
	  FROM Models AS m
	  LEFT JOIN Jobs AS j
		ON j.ModelId = m.ModelId
	 GROUP BY m.ModelId, m.Name) AS a
 ORDER BY [Average Service Time]

--15.	Faultiest Model
WITH CTE_PartsTotal AS(
	SELECT j.ModelId, ISNULL(SUM(p.Price * op.Quantity), 0) AS [Parts Total]
	  FROM Orders AS o
	  JOIN OrderParts AS op
		ON op.OrderId = o.OrderId
	  JOIN Parts AS p
		ON p.PartId = op.PartId
	  JOIN Jobs AS j
	    ON j.JobId = o.JobId
	 GROUP BY j.ModelId) 

SELECT TOP(1) WITH TIES m.Name AS Model,
		COUNT(j.JobId) AS [Time Serviced],
		[Parts Total]
  FROM Models AS m 
  JOIN Jobs AS j
	ON j.ModelId = m.ModelId
  JOIN CTE_PartsTotal AS cte
	ON cte.ModelId = m.ModelId
 GROUP BY m.Name, [Parts Total]
 ORDER BY [Time Serviced] DESC

--16.	Missing Parts
SELECT p.PartId, 
		p.Description, 
		SUM(pn.Quantity) AS Required, 
		SUM(p.StockQty) AS [In Stock], 
		ISNULL(SUM(op.Quantity), 0) AS Ordered 
  FROM Parts AS p
  JOIN PartsNeeded AS pn
    ON pn.PartId = p.PartId
  JOIN Jobs AS j
    ON j.JobId = pn.JobId
  LEFT JOIN Orders AS o
    ON o.JobId = j.JobId
  LEFT JOIN OrderParts AS op
    ON op.OrderId = o.OrderId
 WHERE j.Status <> 'Finished'
 GROUP BY p.PartId, p.Description, op.Quantity
HAVING SUM(pn.Quantity) > SUM(p.StockQty) + ISNULL(SUM(op.Quantity), 0)