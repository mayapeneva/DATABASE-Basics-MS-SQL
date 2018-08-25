USE TableRelations
GO

CREATE TABLE Students
(
StudentID INT NOT NULL,
Name NVARCHAR(50) NOT NULL
)
GO

CREATE TABLE Exams
(
ExamID INT NOT NULL,
Name NVARCHAR(50) NOT NULL
)
GO

CREATE TABLE StudentsExams
(
StudentID INT NOT NULL,
ExamID INT NOT NULL
)
GO

INSERT INTO Students
VALUES
(1, 'Mila'),
(2, 'Toni'),
(3, 'Ron')
GO

INSERT INTO Exams
VALUES
(101, 'SpringMVC'),
(102, 'Neo4j'),
(103, 'Oracle 11g')
GO

INSERT INTO StudentsExams
VALUES
(1, 101),
(1, 102),
(2, 101),
(3, 103),
(2, 102),
(2, 103)
GO

ALTER TABLE Students
ADD CONSTRAINT PK_StudentID
PRIMARY KEY (StudentID)
GO

ALTER TABLE Exams
ADD CONSTRAINT PK_ExamID
PRIMARY KEY (ExamID)
GO

ALTER TABLE StudentsExams
ADD CONSTRAINT FK_StudentsExams_Students_StudentID
FOREIGN KEY(StudentID)
REFERENCES Students(StudentID)
GO

ALTER TABLE StudentsExams
ADD CONSTRAINT FK_StudentsExams_Exams_ExamID
FOREIGN KEY(ExamID)
REFERENCES Exams(ExamID)
GO

ALTER TABLE StudentsExams
ADD CONSTRAINT PK_StudentID_ExamID
PRIMARY KEY (StudentID, ExamID)