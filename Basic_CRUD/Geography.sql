USE Geography
GO

SELECT PeakName FROM Peaks
 ORDER BY PeakName
GO

SELECT TOP (30) CountryName, Population FROM Countries
 WHERE ContinentCode = (SELECT ContinentCode 
						   FROM Continents
						  WHERE ContinentName = 'Europe')
 ORDER BY Population DESC, CountryName ASC

SELECT * FROM Countries

SELECT CountryName, CountryCode, CurrencyCode = 
  CASE CurrencyCode
		WHEN 'EUR' THEN 'Euro'
		ELSE 'Not Euro'
   END
  FROM Countries
 ORDER BY CountryName