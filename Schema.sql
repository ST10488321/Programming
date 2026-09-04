--============================================
-- Phase 2 – SQL Database Scripy
--For SQL Server
-- ============================================

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS Results;
DROP TABLE IF EXISTS Enrolments;
DROP TABLE IF EXISTS EventOrganisers;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Events;
DROP TABLE IF EXISTS Users;
GO

-- ============================================
-- DDL – Create tables
-- ============================================

CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    Role VARCHAR(20) NOT NULL CHECK (Role IN ('Organiser', 'Participant', 'Admin')),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
GO

CREATE TRIGGER trg_Users_Update
ON Users
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Users SET UpdatedAt = GETDATE()
    FROM Users u INNER JOIN inserted i ON u.UserID = i.UserID;
END;
GO

CREATE TABLE Events (
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    EventDate DATE NOT NULL,
    Location VARCHAR(200),
    Status VARCHAR(20) DEFAULT 'Open' CHECK (Status IN ('Open', 'Closed', 'Cancelled')),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    CONSTRAINT FK_Categories_Event FOREIGN KEY (EventID) REFERENCES Events(EventID) ON DELETE CASCADE
);
GO

CREATE TABLE EventOrganisers (
    OrganiserID INT NOT NULL,
    EventID INT NOT NULL,
    RoleInEvent VARCHAR(50),
    AssignedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT PK_EventOrganisers PRIMARY KEY (OrganiserID, EventID),
    CONSTRAINT FK_EventOrganisers_User FOREIGN KEY (OrganiserID) REFERENCES Users(UserID),
    CONSTRAINT FK_EventOrganisers_Event FOREIGN KEY (EventID) REFERENCES Events(EventID)
);
GO

CREATE TABLE Enrolments (
    EnrolmentID INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID INT NOT NULL,
    EventID INT NOT NULL,
    CategoryID INT NOT NULL,
    RegistrationDate DATETIME DEFAULT GETDATE(),
    Status VARCHAR(20) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled')),
    Notes TEXT,
    CONSTRAINT FK_Enrolments_User FOREIGN KEY (ParticipantID) REFERENCES Users(UserID),
    CONSTRAINT FK_Enrolments_Event FOREIGN KEY (EventID) REFERENCES Events(EventID),
    CONSTRAINT FK_Enrolments_Category FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
GO

CREATE TABLE Results (
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID INT NOT NULL UNIQUE,   -- one-to-one
    Score DECIMAL(5,2),
    Rank INT,
    Comments TEXT,
    CONSTRAINT FK_Results_Enrolment FOREIGN KEY (EnrolmentID) REFERENCES Enrolments(EnrolmentID)
);
GO

-- ============================================
-- DML – Sample data insertion
-- ============================================

-- 1. Insert Users
INSERT INTO Users (Name, Email, PasswordHash, Role)
VALUES
    ('Alice Organiser', 'alice@org.com', 'hash1', 'Organiser'),
    ('Bob Organiser', 'bob@org.com', 'hash2', 'Organiser'),
    ('Charlie Participant', 'charlie@part.com', 'hash3', 'Participant'),
    ('Diana Participant', 'diana@part.com', 'hash4', 'Participant');
GO

-- Capture User IDs
DECLARE @AliceID INT = (SELECT UserID FROM Users WHERE Email = 'alice@org.com');
DECLARE @BobID INT = (SELECT UserID FROM Users WHERE Email = 'bob@org.com');
DECLARE @CharlieID INT = (SELECT UserID FROM Users WHERE Email = 'charlie@part.com');
DECLARE @DianaID INT = (SELECT UserID FROM Users WHERE Email = 'diana@part.com');

-- 2. Insert Events
INSERT INTO Events (Name, Description, EventDate, Location, Status)
VALUES
    ('Annual Marathon', 'City marathon with multiple categories', '2026-10-15', 'Central Park', 'Open'),
    ('Swimming Gala', 'Indoor swimming competition', '2026-11-20', 'Aquatic Centre', 'Open');


DECLARE @MarathonID INT = (SELECT EventID FROM Events WHERE Name = 'Annual Marathon');
DECLARE @SwimID INT = (SELECT EventID FROM Events WHERE Name = 'Swimming Gala');

-- 3. Insert Categories
INSERT INTO Categories (EventID, Name, Description)
VALUES
    (@MarathonID, 'Elite Men', 'For professional male runners'),
    (@MarathonID, 'Elite Women', 'For professional female runners'),
    (@MarathonID, 'Amateur', 'For recreational runners'),
    (@SwimID, 'Freestyle 100m', '100m freestyle'),
    (@SwimID, 'Breaststroke 50m', '50m breaststroke');


DECLARE @MarathonEliteMenID INT = (SELECT CategoryID FROM Categories WHERE EventID = @MarathonID AND Name = 'Elite Men');
DECLARE @MarathonAmateurID INT = (SELECT CategoryID FROM Categories WHERE EventID = @MarathonID AND Name = 'Amateur');
DECLARE @SwimFreestyleID INT = (SELECT CategoryID FROM Categories WHERE EventID = @SwimID AND Name = 'Freestyle 100m');

-- 4. Link Organisers to Events
INSERT INTO EventOrganisers (OrganiserID, EventID, RoleInEvent)
VALUES
    (@AliceID, @MarathonID, 'Head Organiser'),
    (@BobID, @MarathonID, 'Assistant'),
    (@AliceID, @SwimID, 'Head Organiser');


-- 5. Enrol Participants
INSERT INTO Enrolments (ParticipantID, EventID, CategoryID, Status, Notes)
VALUES
    (@CharlieID, @MarathonID, @MarathonEliteMenID, 'Confirmed', 'Elite runner'),
    (@DianaID, @MarathonID, @MarathonAmateurID, 'Pending', 'First time marathon'),
    (@CharlieID, @SwimID, @SwimFreestyleID, 'Confirmed', 'Also swims');


-- 6. Add a Result for one enrolment
DECLARE @CharlieMarathonEnrolmentID INT = (
    SELECT EnrolmentID FROM Enrolments
    WHERE ParticipantID = @CharlieID AND EventID = @MarathonID AND CategoryID = @MarathonEliteMenID
);

INSERT INTO Results (EnrolmentID, Score, Rank, Comments)
VALUES
    (@CharlieMarathonEnrolmentID, 2.5, 10, 'Finished 10th overall');
GO