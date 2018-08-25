USE Geography
GO

--Problem 8.	Peaks and Mountains
SELECT p.PeakName, m.MountainRange, p.Elevation
  FROM Peaks AS p
  JOIN Mountains AS m
    ON m.Id = p.MountainId
 ORDER BY Elevation DESC, PeakName
GO

--Problem 9.	Peaks with Their Mountain, Country and Continent
SELECT p.PeakName, m.MountainRange, c.CountryName, ct.ContinentName
  FROM Peaks AS p
  JOIN Mountains AS m
    ON m.Id = p.MountainId
  JOIN MountainsCountries as mc
    ON mc.MountainId = m.Id
  JOIN Countries AS c
    ON c.CountryCode = mc.CountryCode
  JOIN Continents AS ct
    ON ct.ContinentCode = c.ContinentCode
 ORDER BY PeakName, CountryName
GO

--Problem 10.	Rivers by Country
SELECT c.CountryName, 
		ct.ContinentName, 
		COUNT(r.Id) AS RiversCount, 
		ISNULL(SUM(r.Length), 0) AS TotalLength
  FROM Countries AS c
  LEFT JOIN CountriesRivers AS cr
    ON cr.CountryCode = c.CountryCode
  LEFT JOIN Rivers AS r
    ON r.Id = cr.RiverId
  LEFT JOIN Continents AS ct
    ON ct.ContinentCode = c.ContinentCode
 GROUP BY CountryName, ContinentName
 ORDER BY RiversCount DESC, TotalLength DESC, CountryName
GO

--Problem 11.	Count of Countries by Currency
SELECT cr.CurrencyCode, cr.Description AS Currency, COUNT(c.CountryCode) AS NumberOfCountries
  FROM Currencies AS cr
  LEFT JOIN Countries AS c
    ON c.CurrencyCode = cr.CurrencyCode
 GROUP BY cr.CurrencyCode, cr.Description
 ORDER BY NumberOfCountries DESC, Currency
GO

--Problem 12.	Population and Area by Continent
SELECT ct.ContinentName, SUM(c.AreaInSqKm) AS CountriesArea, SUM(CAST(c.Population AS DECIMAL)) AS CountriesPopulation
  FROM Continents AS ct
  LEFT JOIN Countries AS c
    ON c.ContinentCode = ct.ContinentCode
 GROUP BY ContinentName
 ORDER BY CountriesPopulation DESC
GO

--Problem 13.	Monasteries by Country
CREATE TABLE Monasteries(
Id INT PRIMARY KEY IDENTITY, 
Name NVARCHAR(50), 
CountryCode CHAR(2) FOREIGN KEY REFERENCES Countries(CountryCode))

INSERT INTO Monasteries(Name, CountryCode) VALUES
('Rila Monastery “St. Ivan of Rila”', 'BG'), 
('Bachkovo Monastery “Virgin Mary”', 'BG'),
('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
('Kopan Monastery', 'NP'),
('Thrangu Tashi Yangtse Monastery', 'NP'),
('Shechen Tennyi Dargyeling Monastery', 'NP'),
('Benchen Monastery', 'NP'),
('Southern Shaolin Monastery', 'CN'),
('Dabei Monastery', 'CN'),
('Wa Sau Toi', 'CN'),
('Lhunshigyia Monastery', 'CN'),
('Rakya Monastery', 'CN'),
('Monasteries of Meteora', 'GR'),
('The Holy Monastery of Stavronikita', 'GR'),
('Taung Kalat Monastery', 'MM'),
('Pa-Auk Forest Monastery', 'MM'),
('Taktsang Palphug Monastery', 'BT'),
('S?mela Monastery', 'TR')

UPDATE Countries
 SET IsDeleted = 1
 WHERE CountryCode IN (
					SELECT c.CountryCode
					  FROM Countries AS c
					  JOIN CountriesRivers AS cr
						ON cr.CountryCode = c.CountryCode
					  JOIN Rivers as r
						ON r.Id = cr.RiverId
					 GROUP BY c.CountryCode
					HAVING COUNT(r.Id) > 3)

SELECT m.Name AS Monastery, c.CountryName AS Country
  FROM Monasteries AS m
  JOIN Countries AS c
    ON c.CountryCode = m.CountryCode
 WHERE c.IsDeleted = 0
 ORDER BY Monastery
GO

--Problem 14.	Monasteries by Continents and Countries
UPDATE Countries
   SET CountryName = 'Burma'
 WHERE CountryName = 'Myanmar'

INSERT INTO Monasteries (Name, CountryCode) VALUES
('Hanga Abbey', (SELECT CountryCode FROM Countries WHERE CountryName = 'Tanzania'))

INSERT INTO Monasteries (Name, CountryCode) VALUES
('Myin-Tin-Daik', (SELECT CountryCode FROM Countries WHERE CountryName = 'Myanmar'))

SELECT ct.ContinentName, c.CountryName, COUNT(m.Name) AS MonasteriesCount
  FROM Continents AS ct
  LEFT JOIN Countries AS c
    ON ct.ContinentCode = c.ContinentCode
  LEFT JOIN Monasteries AS m
    ON m.CountryCode = c.CountryCode
 WHERE c.IsDeleted = 0
 GROUP BY ct.ContinentName, c.CountryName
 ORDER BY MonasteriesCount DESC, CountryName

SELECT * FROM Monasteries
WHERE CountryCode = 'MM'