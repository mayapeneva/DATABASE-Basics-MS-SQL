CREATE DATABASE TableRelations
COLLATE Cyrillic_General_100_CI_AI
GO

USE TableRelations
GO

CREATE TABLE Passports(
PassportID INT PRIMARY KEY,
PassportNumber VARCHAR(50)
)
GO

CREATE TABLE Persons(
PersonId INT NOT NULL,
FirstName NVARCHAR(50),
Salary DECIMAL(15, 2),
PassportID INT
)
GO

INSERT INTO Passports
VALUES
(101, 'N34FG21B'),
(102, 'K65LO4R7'),
(103, 'ZE657QP2')
GO 

INSERT INTO Persons
VALUES
(1, 'Roberto', 43300, 102),
(2, 'Tom', 56100, 103),
(3, 'Yana', 60200, 101)
GO

ALTER TABLE Persons
ADD CONSTRAINT PK_Persons_ID
PRIMARY KEY (PersonID)
GO

ALTER TABLE Persons
ADD CONSTRAINT PK_Persons_Passports_PassportID
FOREIGN KEY (PassportID) 
REFERENCES Passports(PassportID)
GO