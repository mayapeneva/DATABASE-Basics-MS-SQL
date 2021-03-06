CREATE TABLE Credentials(
	Id INT PRIMARY KEY IDENTITY,
	Email VARCHAR(30),
	Password VARCHAR(20)
)

CREATE TABLE Locations(
	Id INT PRIMARY KEY IDENTITY(1,1),
	Latitude FLOAT,
	Longitude FLOAT
)

CREATE TABLE Users(
	Id INT PRIMARY KEY IDENTITY(1,1),
	Nickname VARCHAR(25),
	Gender CHAR(1),
	Age INT,
	LocationId INT FOREIGN KEY REFERENCES Locations(Id),
	CredentialId INT UNIQUE FOREIGN KEY REFERENCES Credentials(Id)
)

CREATE TABLE Chats(
	Id INT PRIMARY KEY IDENTITY(1,1),
	Title VARCHAR(32),
	StartDate DATE,
	IsActive BIT
)

CREATE TABLE UsersChats(
	UserId INT,
	ChatId INT,
	CONSTRAINT PK_ChatId_UserId PRIMARY KEY(ChatId, UserId),
	CONSTRAINT FK_UserId_Users FOREIGN KEY(UserId) REFERENCES Users(Id),
	CONSTRAINT FK_ChatId_Chats FOREIGN KEY(ChatId) REFERENCES Chats(Id)
)

CREATE TABLE Messages(
	Id INT PRIMARY KEY IDENTITY(1,1),
	Content VARCHAR(200),
	SentOn DATE,
	ChatId INT FOREIGN KEY REFERENCES Chats(Id),
	UserId INT FOREIGN KEY REFERENCES Users(Id)
)
