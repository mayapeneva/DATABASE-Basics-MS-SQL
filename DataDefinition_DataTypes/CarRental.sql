CREATE DATABASE CarRental
COLLATE Cyrillic_General_100_CI_AI
GO

USE CarRental

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	CategoryName NVARCHAR(50) NOT NULL,
	DailyRate DECIMAL(15, 2) NOT NULL, 
	WeeklyRate DECIMAL(15, 2) NOT NULL, 
	MonthlyRate DECIMAL(15, 2) NOT NULL, 
	WeekendRate DECIMAL(15, 2) NOT NULL
)

CREATE TABLE Cars(
	Id INT PRIMARY KEY IDENTITY,
	PlateNumber VARCHAR(50) NOT NULL, 
	Manufacturer VARCHAR(50) NOT NULL, 
	Model VARCHAR(50) NOT NULL, 
	CarYear DECIMAL(4, 0) NOT NULL, 
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL, 
	Doors DECIMAL(1, 0) NOT NULL, 
	Picture VARBINARY(MAX), 
	Condition VARCHAR(50),
	Available BIT DEFAULT 1
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL, 
	LastName NVARCHAR(50) NOT NULL,
	Title VARCHAR(10),
	Notes NVARCHAR(50)
)

CREATE TABLE Customers(
	Id INT PRIMARY KEY IDENTITY,
	DriverLicenceNumber DECIMAL(15, 0) NOT NULL, 
	FullName NVARCHAR(50) NOT NULL, 
	[Address] NVARCHAR(50) NOT NULL, 
	City NVARCHAR(50) NOT NULL, 
	ZIPCode INT NOT NULL,
	Notes NVARCHAR(50)
)

CREATE TABLE RentalOrders(
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL, 
	CustomerId INT FOREIGN KEY REFERENCES Customers(Id) NOT NULL, 
	CarId INT FOREIGN KEY REFERENCES Cars(Id) NOT NULL, 
	TankLevel DECIMAL(15, 2) NOT NULL, 
	KilometrageStart INT NOT NULL, 
	KilometrageEnd INT, 
	TotalKilometrage AS KilometrageEnd - KilometrageStart, 
	StartDate DATETIME NOT NULL, 
	EndDate DATETIME, 
	TotalDays AS EndDate - StartDate, 
	RateApplied VARCHAR(15), 
	TaxRate INT DEFAULT 20, 
	OrderStatus VARCHAR(10),
	Notes NVARCHAR(50),
	CONSTRAINT UQ_ UNIQUE (CarId, StartDate, EndDate)
)

INSERT INTO Categories(CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate) VALUES
('Low Cost', 30, 150, 450, 35),
('Middles Class', 40, 200, 600, 45),
('Luxures', 50, 300, 1000, 60)

INSERT INTO Cars(PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Condition) VALUES
('B 5124 AP', 'Renault', 'Clio', 2009, 1, 4, 'Perfect'),
('B 7624 AX', 'Toyota', 'Corolla', 2013, 2, 4, 'Perfect'),
('B 2365 BA', 'Mercedes', 'E-Class', 2016, 3, 4, 'Perfect')

INSERT INTO Employees(FirstName, LastName, Title) VALUES
('Ivan', 'Ivanov', 'Mr'),
('Petar', 'Petrov', 'Mr'),
('Georgi', 'Georgiev', 'Mr')

INSERT INTO Customers(DriverLicenceNumber, FullName, Address, City, ZIPCode) VALUES
(116868988, 'Petya Petrova', 'Hristo Botev Str. 54', 'Sofia', 1005),
(512399521, 'Hristo Hristov', 'Velko Gurdev 41', 'Plovdiv', 5004),
(566648633, 'Veliko Velikov', 'Straldja 5', 'Burgas', 8003)

INSERT INTO RentalOrders(EmployeeId, CustomerId, CarId, TankLevel, KilometrageStart, KilometrageEnd, StartDate, EndDate, RateApplied, OrderStatus) VALUES
(1, 1, 1, 35, 115653, 115795, 04/08/2018, 04/15/2018, 'WeeklyRate', 'Paid'),
(2, 2, 2, 40, 206233, 207637, 05/01/2018, 05/05/2018, 'DailyRate', 'Due'),
(3, 3, 3, 50, 10963, 10963, 05/24/2018, 06/24/2018, 'MontlyRate', 'On')

SELECT * FROM Customers