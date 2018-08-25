USE TableRelations
GO

CREATE TABLE Manufacturers(
ManufacturerID INT NOT NULL,
Name NVARCHAR(50) NOT NULL,
EstablishedOn DATE
)
GO

CREATE TABLE Models(
ModelID INT NOT NULL,
Name NVARCHAR(50) NOT NULL,
ManufacturerID INT NOT NULL
)
GO

INSERT INTO Manufacturers
VALUES
(1, 'BMW', '03/07/1916'),
(2, 'Tesla', '01/01/2003'),
(3, 'Lada', '05/01/1966')
GO

INSERT INTO Models
VALUES
(101, 'X1', 1),
(102, 'i6', 1),
(103, 'Model S', 2),
(104, 'Model X', 2),
(105, 'Model 3', 2),
(106, 'Nova', 3)
GO

ALTER TABLE Models
ADD CONSTRAINT PK_Models_ModelID
PRIMARY KEY (ModelID)
GO

ALTER TABLE Manufacturers
ADD CONSTRAINT PK_Manufacturers_ManufacturerID
PRIMARY KEY (ManufacturerID)
GO

ALTER TABLE Models
ADD CONSTRAINT FK_Models_Manufacturers_ManufacturerID
FOREIGN KEY (ManufacturerID)
REFERENCES Manufacturers(ManufacturerID)