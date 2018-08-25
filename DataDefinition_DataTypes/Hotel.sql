CREATE DATABASE Hotel
COLLATE Cyrillic_General_100_CI_AI
GO

USE Hotel

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title VARCHAR(10) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Customers(
	AccountNumber INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL, 
	LastName NVARCHAR(50) NOT NULL, 
	PhoneNumber INT, 
	EmergencyName NVARCHAR(50), 
	EmergencyNumber INT, 
	Notes NVARCHAR(MAX)
)

CREATE TABLE RoomStatus(
	RoomStatus VARCHAR(20) PRIMARY KEY NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE RoomTypes(
	RoomType VARCHAR(20) PRIMARY KEY NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE BedTypes(
	BedType VARCHAR(20) PRIMARY KEY NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Rooms(
	RoomNumber INT PRIMARY KEY NOT NULL, 
	RoomType VARCHAR(20) FOREIGN KEY REFERENCES RoomTypes(RoomType) NOT NULL, 
	BedType VARCHAR(20) FOREIGN KEY REFERENCES BedTypes(BedType) NOT NULL, 
	Rate DECIMAL(15, 2) NOT NULL, 
	RoomStatus VARCHAR(20) FOREIGN KEY REFERENCES RoomStatus(RoomStatus) NOT NULL, 
	Notes NVARCHAR(MAX)
)

CREATE TABLE Payments(
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL, 
	PaymentDate DATETIME DEFAULT GETDATE(), 
	AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL, 
	FirstDateOccupied DATETIME NOT NULL, 
	LastDateOccupied DATETIME NOT NULL, 
	TotalDays AS LastDateOccupied - FirstDateOccupied, 
	AmountCharged AS PaymentTotal / 1.2, 
	TaxRate INT DEFAULT 9, 
	TaxAmount AS (PaymentTotal / 1.2) * TaxRate, 
	PaymentTotal DECIMAL(15, 2) NOT NULL, 
	Notes NVARCHAR(MAX)
)

CREATE TABLE Occupancies(
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL, 
	DateOccupied DATETIME NOT NULL, 
	AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL, 
	RoomNumber INT FOREIGN KEY REFERENCES Rooms(RoomNumber) NOT NULL, 
	RateApplied DECIMAL(15, 2) NOT NULL, 
	PhoneCharge DECIMAL(15, 2) DEFAULT 0, 
	Notes NVARCHAR(MAX)
)

INSERT INTO Employees(FirstName, LastName, Title) VALUES
('Ivan', 'Ivanov', 'Mr'), 
('Maria', 'Goranova', 'Ms'),
('Petya', 'Petrova', 'Mrs')

INSERT INTO Customers(FirstName, LastName, PhoneNumber) VALUES
('Iva', 'Ruseva', 0889205666), 
('Zara', 'Dimitrova', 0888265485),
('Teodora', 'Pavlova', 0882964752)

INSERT INTO RoomStatus(RoomStatus) VALUES
('Free'), 
('Occupied'),
('Being Cleaned')

INSERT INTO RoomTypes(RoomType) VALUES
('Single'), 
('Double'),
('Apartment')

INSERT INTO BedTypes(BedType) VALUES
('French bed'), 
('Single Beds'),
('French + Single Beds')

INSERT INTO Rooms(RoomNumber, RoomType, BedType, Rate, RoomStatus) VALUES
(101, 'Double', 'Single Beds', 60, 'Free'), 
(205, 'Apartment', 'French + Single Beds', 120, 'Free'),
(201, 'Double', 'French Bed', 70, 'Free')

INSERT INTO Payments(EmployeeId, AccountNumber, FirstDateOccupied, LastDateOccupied, PaymentTotal) VALUES
(1, 1, 04/25/2018, 04/28/2018, 180), 
(2, 2, 04/27/2018, 04/29/2018, 240),
(3, 3, 04/27/2018, 05/04/2018, 490)

INSERT INTO Occupancies(EmployeeId, DateOccupied, AccountNumber, RoomNumber, RateApplied) VALUES
(1, 04/25/2018, 1, 101, 60), 
(2, 04/27/2018, 2, 205, 120),
(3, 04/27/2018, 3, 201, 70)


UPDATE Payments
SET TaxRate -= 3;

SELECT TaxRate FROM Payments


TRUNCATE TABLE Occupancies