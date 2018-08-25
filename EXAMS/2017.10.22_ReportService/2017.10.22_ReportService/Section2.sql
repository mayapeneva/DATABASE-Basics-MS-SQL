USE ReportService
GO

--2.	Insert
INSERT INTO Employees(FirstName, LastName, Gender, BirthDate, DepartmentId) VALUES
('Marlo', 'O’Malley', 'M',	'9/21/1958', (SELECT Id FROM Departments WHERE Name = 'Infrastructure')),
('Niki',	'Stanaghan',	'F',	'11/26/1969', (SELECT Id FROM Departments WHERE Name = 'Emergency')),
('Ayrton',	'Senna',	'M',	'03/21/1960', 	(SELECT Id FROM Departments WHERE Name = 'Event Management')),
('Ronnie',	'Peterson',	'M',	'02/14/1944',	(SELECT Id FROM Departments WHERE Name = 'Event Management')),
('Giovanna',	'Amati',	'F',	'07/20/1959',	(SELECT Id FROM Departments WHERE Name = 'Roads Maintenance'))

INSERT INTO Reports(CategoryId, StatusId, OpenDate, CloseDate, Description, UserId, EmployeeId) VALUES
((SELECT Id FROM Categories WHERE Name = 'Snow Removal'), (SELECT Id FROM Status WHERE Label = 'waiting'), '04/13/2017', NULL, 'Stuck Road on Str.133', 6,	2),
((SELECT Id FROM Categories WHERE Name = 'Sports Events'),	(SELECT Id FROM Status WHERE Label = 'completed'),	'09/05/2015',	'12/06/2015',	'Charity trail running', 3,	5),
((SELECT Id FROM Categories WHERE Name = 'Dangerous Building'),	(SELECT Id FROM Status WHERE Label = 'in progress'),	'09/07/2015', NULL, 'Falling bricks on Str.58',	5, 2),
((SELECT Id FROM Categories WHERE Name = 'Streetlight'), (SELECT Id FROM Status WHERE Label = 'completed'),	'07/03/2017',	'07/06/2017',	'Cut off streetlight on Str.11', 1,	1)

--3.	Update
UPDATE Reports
SET StatusID = 2
WHERE CategoryId = 4 AND StatusId = 1

SELECT * FROM Status
--4.	Delete
DELETE Reports
WHERE StatusID = 4