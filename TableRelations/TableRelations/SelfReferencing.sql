USE TableRelations
GO

CREATE TABLE Teachers
(
TeacherID INT NOT NULL,
Name NVARCHAR(50) NOT NULL,
ManagerID INT
)
GO

INSERT INTO Teachers
VALUES
(101, 'John', NULL),
(102, 'Maya', 106),
(103, 'Silvia', 106),
(104, 'Ted', 105),
(105, 'Mark', 101),
(106, 'Greta', 101)
GO

ALTER TABLE Teachers
ADD CONSTRAINT PK_Teachers_TeacherID
PRIMARY Key(TeacherID)
GO

ALTER TABLE Teachers
ADD CONSTRAINT FK_Teachers_Teachers_ManagerID
FOREIGN KEY(ManagerID)
REFERENCES Teachers(TeacherID)