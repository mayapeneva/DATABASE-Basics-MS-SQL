USE Geography
GO

SELECT c.CountryCode, m.MountainRange, p.PeakName, p.Elevation
  FROM Countries AS c
  JOIN MountainsCountries AS mc
    ON mc.CountryCode = c.CountryCode
  JOIN Mountains AS m
    ON m.Id = mc.MountainId
  JOIN Peaks as p
    ON p.MountainId = m.Id
 WHERE c.CountryCode = 'BG' AND p.Elevation > 2835
 ORDER BY p.Elevation DESC
GO

SELECT c.CountryCode, COUNT(m.MountainRange) AS MountainRanges
  FROM Countries AS c
  JOIN MountainsCountries AS mc
    ON mc.CountryCode = c.CountryCode
  JOIN Mountains AS m
    ON m.Id = mc.MountainId AND c.CountryName IN ('United States', 'Russia', 'Bulgaria')
 GROUP BY c.CountryCode
GO

SELECT TOP (5) c.CountryName, r.RiverName 
  FROM Countries AS c
  LEFT JOIN CountriesRivers AS cr
    ON cr.CountryCode = c.CountryCode
  LEFT JOIN Rivers AS r
    ON r.Id = cr.RiverId
  JOIN Continents as ct
    ON ct.ContinentCode = c.ContinentCode
 WHERE ct.ContinentName = 'Africa'
 ORDER BY c.CountryName
GO

WITH CTE_CountriesInfo (ContinentCode, CurrencyCode, CurrencyUsage) AS (
  SELECT ContinentCode, CurrencyCode, COUNT(CurrencyCode) AS CurrencyUsage
	FROM Countries
   GROUP BY ContinentCode, CurrencyCode
  HAVING COUNT(CurrencyCode) > 1)

SELECT a.ContinentCode, c.CurrencyCode, a.CurrencyUsage
  FROM (SELECT ContinentCode, MAX(CurrencyUsage) AS CurrencyUsage
		  FROM CTE_CountriesInfo
		 GROUP BY ContinentCode) AS a
  JOIN CTE_CountriesInfo AS c
    ON c.ContinentCode = a.ContinentCode AND c.CurrencyUsage = a.CurrencyUsage
GO

SELECT COUNT(c.CountryCode) AS CountryCode  
  FROM Countries AS c
  LEFT JOIN MountainsCountries AS mc
    ON mc.CountryCode = c.CountryCode
  LEFT JOIN Mountains AS m
    ON m.Id = mc.MountainId
 WHERE mc.MountainId IS NULL
GO

SELECT TOP (5) c.CountryName, MAX(p.Elevation) AS HighestPeakElevation, MAX(r.Length) AS LongestRiverLength
  FROM Countries AS c
  JOIN MountainsCountries AS mc
    ON mc.CountryCode = c.CountryCode
  JOIN Mountains AS m
    ON m.Id = mc.MountainId
  JOIN Peaks as p
    ON p.MountainId = m.Id
  JOIN CountriesRivers as cr
    ON cr.CountryCode = c.CountryCode
  JOIN Rivers as r
    ON r.Id = cr.RiverId
 GROUP BY c.CountryName
 ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, c.CountryName