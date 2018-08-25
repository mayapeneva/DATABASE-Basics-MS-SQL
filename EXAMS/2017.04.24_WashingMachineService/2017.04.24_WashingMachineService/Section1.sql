CREATE DATABASE WMS
COLLATE Cyrillic_General_100_CI_AI

USE WMS
GO

CREATE TABLE Clients(
ClientId INT PRIMARY KEY IDENTITY,  
FirstName NVARCHAR(50),
LastName NVARCHAR(50),
Phone VARCHAR(12) CHECK(LEN(Phone) = 12)
)

CREATE TABLE Mechanics(
MechanicId  INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50),
LastName NVARCHAR(50),
Address NVARCHAR(255)
)

CREATE TABLE Models(
ModelId INT PRIMARY KEY IDENTITY,
Name  NVARCHAR(50) UNIQUE
)

CREATE TABLE Jobs(
JobId  INT PRIMARY KEY IDENTITY,
ModelId INT FOREIGN KEY REFERENCES Models(ModelId),
Status NVARCHAR(11) CHECK(Status IN('Pending', 'In Progress', 'Finished')) DEFAULT('Pending'),
ClientId INT FOREIGN KEY REFERENCES Clients(ClientId),
MechanicId INT NULL FOREIGN KEY REFERENCES Mechanics(MechanicId),
IssueDate DATE,
FinishDate DATE NULL
)

CREATE TABLE Orders(
OrderId INT PRIMARY KEY IDENTITY,
JobId INT FOREIGN KEY REFERENCES Jobs(JobId),
IssueDate DATE NULL,
Delivered BIT DEFAULT 0
)

CREATE TABLE Vendors(
VendorId INT PRIMARY KEY IDENTITY,
Name NVARCHAR(50) UNIQUE
)

CREATE TABLE Parts(
PartId INT PRIMARY KEY IDENTITY,
SerialNumber NVARCHAR(50) UNIQUE,
Description NVARCHAR(255) NULL,
Price DECIMAL(6, 2) CHECK(Price > 0),
VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId),
StockQty INT CHECK(StockQty >= 0) DEFAULT 0
)

CREATE TABLE OrderParts(
OrderId INT FOREIGN KEY REFERENCES Orders(OrderId),
PartId INT FOREIGN KEY REFERENCES Parts(PartId),
Quantity INT CHECK(Quantity > 0) DEFAULT 1

CONSTRAINT pk_OrderParts_OrderId_PartId
PRIMARY KEY (OrderId, PartId)
)

CREATE TABLE PartsNeeded(
JobId INT FOREIGN KEY REFERENCES Jobs(JobId),
PartId INT FOREIGN KEY REFERENCES Parts(PartId),
Quantity INT CHECK(Quantity > 0) DEFAULT 1

CONSTRAINT pk_PartsNeeded_JobId_PartId
PRIMARY KEY (JobId, PartId)
)