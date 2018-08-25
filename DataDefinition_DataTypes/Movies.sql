CREATE DATABASE Movies
COLLATE Cyrillic_General_CI_AI

USE Movies

CREATE TABLE Directors(
	Id INT PRIMARY KEY IDENTITY,
	DirectorName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Genres(
	Id INT PRIMARY KEY IDENTITY,
	GenreName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	CategoryName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Movies(
	Id INT PRIMARY KEY IDENTITY,
	Title NVARCHAR(50) NOT NULL,
	DirectorId INT FOREIGN KEY REFERENCES Directors(Id) NOT NULL,
	CopyrightYear DECIMAL(4, 0) NOT NULL, 
	[Length] DECIMAL(15, 2), 
	GenreId INT FOREIGN KEY REFERENCES Genres(Id) NOT NULL, 
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL, 
	Rating INT, 
	Notes NVARCHAR(MAX),
	CONSTRAINT CH_RatingLow CHECK (LEN(Rating) > 0),
	CONSTRAINT CH_RatingUp CHECK (LEN(Rating) < 11),
	CONSTRAINT UQ_TitleDirector UNIQUE (Title, DirectorId)
)

INSERT INTO Directors(DirectorName) VALUES
('Christopher Nolan'),
('Steven Spielberg'),
('Quentin Tarantino'),
('George Lucas'),
('Martin Scorsese')

INSERT INTO Genres(GenreName) VALUES
('Thriller'),
('Fiction'),
('Crime'),
('Sci-Fi'),
('Drama')

INSERT INTO Categories(CategoryName) VALUES
('Film'),
('Documentary'),
('Animated'),
('Musical'),
('Short Film')

INSERT INTO Movies(Title, DirectorId, CopyrightYear, GenreId, CategoryId, Rating) VALUES
('Dunkirk', 1, 2017, 5, 2, 8),
('A.I. Artificial Intelligence', 2, 2001, 2, 1, 7),
('The Hateful Eight', 3, 2015, 3, 1, 8),
('The Lego Movie', 4, 2014, 2, 3, 8),
('The 50 Year Argument', 5, 2014, 5, 2, 7)