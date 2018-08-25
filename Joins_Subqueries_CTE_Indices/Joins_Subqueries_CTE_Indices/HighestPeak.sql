USE Geography
GO

WITH CTE_HighestPeaks (Country, PeakName, Elevation, Mountain) AS(
	SELECT c.CountryName AS Country, p.PeakName, MAX(p.Elevation), m.MountainRange
	  FROM Countries AS c
	  LEFT JOIN MountainsCountries AS mc
		ON mc.CountryCode = c.CountryCode
	  LEFT JOIN Mountains AS m
		ON m.Id = mc.MountainId
	  LEFT JOIN Peaks as p
		ON p.MountainId = m.Id
	 GROUP BY c.CountryName, p.PeakName, m.MountainRange)

SELECT TOP (5) a.Country,
		ISNULL(b.PeakName, '(no highest peak)') AS [Highest Peak Name],
		ISNULL(a.MaxElevation, '0') AS [Highest Peak Elevation],
		ISNULL(b.Mountain, '(no mountain)') AS Mountain
  FROM (SELECT Country, MAX(Elevation) AS MaxElevation
		  FROM CTE_HighestPeaks
		 GROUP BY Country ) AS a
  LEFT JOIN CTE_HighestPeaks AS b
    ON b.Country = a.Country AND b.Elevation = a.MaxElevation
 ORDER BY a.Country, b.PeakName