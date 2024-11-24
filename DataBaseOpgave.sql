CREATE DATABASE JumpForFun;
USE JumpForFun; -- K�re scriptet "USE JumpForFun;" for at v�lge Databasen, og derefter benyt SELECT til at fremvise en tabel, som for eksempel: SELECT * FROM Booking;


-- 2.1 Medlemmer
CREATE TABLE Member (
    MemberID INT IDENTITY(100000, 1) PRIMARY KEY, -- IDENTITY bruges til autoinkrement
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    PhoneNumber NVARCHAR(15) UNIQUE NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    BirthDate DATE NOT NULL CHECK (BirthDate <= DATEADD(YEAR, -18, GETDATE())), -- CHECK med DATEADD
    Address NVARCHAR(255) NOT NULL,
    JoinDate DATE DEFAULT GETDATE() NOT NULL, -- GETDATE() bruges som standardv�rdi
    SubscriptionType NVARCHAR(50) NOT NULL CHECK (SubscriptionType IN ('Basis', 'Premium')) -- ENUM simuleres med CHECK
);

-- 2.2 Centre
CREATE TABLE Center (
    CenterID INT IDENTITY(1, 1) PRIMARY KEY,
    CenterName NVARCHAR(100) NOT NULL,
    Location NVARCHAR(100) NOT NULL
);

-- 2.3 Tr�nere
CREATE TABLE Trainer (
    TrainerID INT IDENTITY(1, 1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(15) UNIQUE NOT NULL
);

-- 2.4 Tr�ningsrum
CREATE TABLE TrainingRoom (
    RoomID INT IDENTITY(1, 1) PRIMARY KEY,
    CenterID INT NOT NULL,
    RoomNumber INT NOT NULL,
    FOREIGN KEY (CenterID) REFERENCES Center(CenterID),
    CONSTRAINT UniqueRoom UNIQUE (CenterID, RoomNumber) -- Unik kombination af center og rum
);

-- 2.5 Hold
CREATE TABLE Class (
    ClassID INT IDENTITY(1, 1) PRIMARY KEY,
    ClassType NVARCHAR(50) NOT NULL,
    MaxParticipants INT DEFAULT 25 CHECK (MaxParticipants > 0),
    StartTime DATETIME NOT NULL,
    EndTime DATETIME NOT NULL,
    RoomID INT NOT NULL,
    TrainerID INT NOT NULL,
    FOREIGN KEY (RoomID) REFERENCES TrainingRoom(RoomID),
    FOREIGN KEY (TrainerID) REFERENCES Trainer(TrainerID)
);

-- 2.6 Bookinger
CREATE TABLE Booking (
    BookingID INT IDENTITY(1, 1) PRIMARY KEY,
    MemberID INT NOT NULL,
    ClassID INT NOT NULL,
    BookingDate DATE DEFAULT GETDATE() NOT NULL,
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    FOREIGN KEY (ClassID) REFERENCES Class(ClassID),
    CONSTRAINT UniqueBooking UNIQUE (MemberID, ClassID) -- Et medlem kan kun booke et hold �n gang
);

-- 3. Opretter Trigger
CREATE TRIGGER CheckTimeConstraint
ON Class
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Inserted
        WHERE StartTime >= EndTime
    )
    BEGIN
        RAISERROR ('StartTime skal v�re tidligere end EndTime.', 16, 1);
        ROLLBACK;
    END
END;

INSERT INTO Class (ClassType, MaxParticipants, StartTime, EndTime, RoomID, TrainerID) -- Tester Trigger ved at inds�tte ugyldigt StartTime og Endtime
VALUES ('Fejltest', 25, '2024-11-24 13:00:00', '2024-11-24 12:00:00', 1, 1);

-- 4.1 Centre
INSERT INTO Center (CenterName, Location)
VALUES ('Ringsted Center', 'Ringsted'),
       ('K�ge Center', 'K�ge'),
       ('Roskilde Center', 'Roskilde'),
       ('Holb�k Center', 'Holb�k');

-- 4.2 Tr�nere
INSERT INTO Trainer (Name, Phone)
VALUES ('Amir Jawad', '12345678'),
       ('Will Smith', '87654321');

-- 4.3 Tr�ningsrum
INSERT INTO TrainingRoom (CenterID, RoomNumber)
VALUES (1, 1), (1, 2), (2, 1), (2, 2);

-- 4.4 Hold
INSERT INTO Class (ClassType, MaxParticipants, StartTime, EndTime, RoomID, TrainerID)
VALUES ('Hop for begyndere', 20, '2024-11-24 10:00:00', '2024-11-24 11:00:00', 1, 1),
       ('Intensiv hop', 25, '2024-11-24 12:00:00', '2024-11-24 13:00:00', 2, 2);

-- 4.5 Medlemmer
INSERT INTO Member (FirstName, LastName, PhoneNumber, Email, BirthDate, Address, SubscriptionType)
VALUES ('Ali', 'Bashir', '12345678', 'ali.Bashir@gmail.com', '2000-01-01', 'Vej 12, 4000 Roskilde', 'Basis'),
       ('Sara', 'Larsen', '87654321', 'sara.larsen@gmail.com', '1995-05-15', 'Gade 34, 4100 Ringsted', 'Premium');

INSERT INTO Member (FirstName, LastName, PhoneNumber, Email, BirthDate, Address, SubscriptionType) -- Test for at tjekke om personer under 18 �r kan v�re medlem
VALUES ('Jens', 'Jensen', '92345678', 'Jens.Jensen@gmail.com', '2010-01-01', 'Vej 12, 4000 Roskilde', 'Basis');

-- 4.6 Bookinger
INSERT INTO Booking (MemberID, ClassID)
VALUES (100000, 1), (100001, 2);

-- Fremvise tabellerne

SELECT * FROM Member;
SELECT * FROM Center;
SELECT * FROM Trainer;
SELECT * FROM TrainingRoom;
SELECT * FROM Class;
SELECT * FROM Booking;


