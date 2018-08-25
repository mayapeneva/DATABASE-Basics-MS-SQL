CREATE DATABASE SoftUni
COLLATE Cyrillic_General_100_CI_AI
GO

USE SoftUni

CREATE TABLE Towns(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Addresses(
	Id INT PRIMARY KEY IDENTITY,
	AddressText NVARCHAR(50) NOT NULL,
	TownId INT FOREIGN KEY REFERENCES Towns(Id)
)

CREATE TABLE Departments(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	JobTitle VARCHAR(50),
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id),
	HireDate DATETIME NOT NULL,
	Salary DECIMAL(15, 2),
	AddressId INT FOREIGN KEY REFERENCES Addresses(Id) 
)

INSERT INTO Towns VALUES
('Sofia'),
('Plovdiv'), 
('Varna'), 
('Burgas')

INSERT INTO Departments VALUES
('Engineering'),
('Sales'), 
('Marketing'), 
('Software Development'), 
('Quality Assurance')

INSERT INTO Employees(FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary) VALUES
('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '02/01/2013', 3500),
('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '03/02/2004', 4000),
('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '08/28/2016', 525.25),
('Georgi', 'Teziev', 'Ivanov', 'CEO', 2, '12/09/2007', 3000),
('Peter', 'Pan', 'Pan', 'Intern', 3, '08/28/2016', 599.88)


SELECT * FROM Towns

SELECT * FROM Departments

SELECT * FROM Employees


SELECT * FROM Towns
ORDER BY Name

SELECT * FROM Departments
ORDER BY Name

SELECT * FROM Employees
ORDER BY Salary DESC


SELECT Name FROM Towns
ORDER BY Name

SELECT Name FROM Departments
ORDER BY Name

SELECT FirstName, LastName, JobTitle, Salary 
FROM Employees
ORDER BY Salary DESC

UPDATE Employees
SET Salary += Salary * 0.1

SELECT Salary FROM Employees


UPDATE Employees
SET Salary += Salary * 0.1

SELECT Salary FROM Employees