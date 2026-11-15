-- railway-reservation-sqlserver.sql
-- Railway Reservation System — SQL Server version.
-- Run this script in SQL Server Management Studio (SSMS) or in Visual
-- Studio's SQL Server Object Explorer. It creates the RailwayDB database,
-- 5 tables (Stations, Trains, Passengers, Bookings, Tickets), inserts the
-- sample data, and then runs 5 practical SELECT queries.
-- Needs: SQL Server Express, SQL Server Developer, or LocalDB.
-- The matching Oracle version of this script is railway-reservation-oracle.sql.

CREATE DATABASE RailwayDB;
GO

USE RailwayDB;
GO

CREATE TABLE Stations (
    StationId INT PRIMARY KEY IDENTITY(1,1),
    StationName NVARCHAR(100) NOT NULL,
    City NVARCHAR(100) NOT NULL,
    PlatformCount INT
);
GO

CREATE TABLE Trains (
    TrainId INT PRIMARY KEY IDENTITY(1,1),
    TrainName NVARCHAR(100) NOT NULL,
    TrainNumber NVARCHAR(20) NOT NULL UNIQUE,
    SourceStationId INT FOREIGN KEY REFERENCES Stations(StationId),
    DestinationStationId INT FOREIGN KEY REFERENCES Stations(StationId),
    DepartureTime TIME NOT NULL,
    ArrivalTime TIME NOT NULL,
    TotalSeats INT NOT NULL,
    FarePerSeat DECIMAL(10,2) NOT NULL
);
GO

CREATE TABLE Passengers (
    PassengerId INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    CNIC NVARCHAR(15) NOT NULL UNIQUE,
    Phone NVARCHAR(20),
    Email NVARCHAR(100)
);
GO

CREATE TABLE Bookings (
    BookingId INT PRIMARY KEY IDENTITY(1,1),
    PassengerId INT FOREIGN KEY REFERENCES Passengers(PassengerId),
    TrainId INT FOREIGN KEY REFERENCES Trains(TrainId),
    TravelDate DATE NOT NULL,
    SeatsBooked INT NOT NULL,
    TotalFare DECIMAL(10,2) NOT NULL,
    BookingDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE)
);
GO

CREATE TABLE Tickets (
    TicketId INT PRIMARY KEY IDENTITY(1,1),
    BookingId INT FOREIGN KEY REFERENCES Bookings(BookingId),
    SeatNumber NVARCHAR(10) NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Confirmed'
);
GO

INSERT INTO Stations (StationName, City, PlatformCount) VALUES
    ('Lahore Junction', 'Lahore', 8),
    ('Karachi Cantt', 'Karachi', 10),
    ('Rawalpindi', 'Rawalpindi', 6),
    ('Multan Cantt', 'Multan', 5),
    ('Peshawar Cantt', 'Peshawar', 4);
GO

-- Train times are departure / arrival times on the same day clock.
-- Green Line leaves Lahore at 08:00 and reaches Karachi at 06:00 next morning;
-- the TIME column only stores the clock time, not the day.
INSERT INTO Trains (TrainName, TrainNumber, SourceStationId, DestinationStationId, DepartureTime, ArrivalTime, TotalSeats, FarePerSeat) VALUES
    ('Green Line Express', 'GL-15UP', 1, 2, '08:00', '06:00', 240, 4500),
    ('Tezgam', 'TG-7UP', 2, 3, '17:30', '13:00', 300, 3200),
    ('Khyber Mail', 'KM-1UP', 2, 5, '22:00', '18:00', 280, 3800),
    ('Awam Express', 'AW-13UP', 1, 5, '09:30', '16:00', 200, 1500),
    ('Pakistan Express', 'PK-45UP', 2, 1, '19:00', '14:00', 260, 2800);
GO

INSERT INTO Passengers (FullName, CNIC, Phone, Email) VALUES
    ('Ahmed Raza', '35202-1234567-1', '0300-1234567', 'ahmed.raza@email.com'),
    ('Fatima Khan', '35202-7654321-2', '0301-2345678', 'fatima.khan@email.com'),
    ('Bilal Ahmed', '61101-9876543-3', '0302-3456789', 'bilal.ahmed@email.com'),
    ('Ayesha Malik', '35202-1122334-4', '0303-4567890', 'ayesha.malik@email.com'),
    ('Usman Ghani', '61101-5566778-5', '0304-5678901', 'usman.ghani@email.com'),
    ('Maryam Siddiqui', '35202-9988776-6', '0305-6789012', 'maryam.siddiqui@email.com');
GO

-- TotalFare = SeatsBooked x FarePerSeat of the train.
-- Booking 1: 2 x 4500 = 9000. Booking 3: 3 x 3800 = 11400.
-- Booking 6: 4 x 2800 = 11200.
INSERT INTO Bookings (PassengerId, TrainId, TravelDate, SeatsBooked, TotalFare, BookingDate) VALUES
    (1, 1, '2026-11-20', 2, 9000, '2026-11-15'),
    (2, 2, '2026-11-21', 1, 3200, '2026-11-15'),
    (3, 3, '2026-11-22', 3, 11400, '2026-11-16'),
    (4, 1, '2026-11-20', 1, 4500, '2026-11-16'),
    (5, 4, '2026-11-23', 2, 3000, '2026-11-17'),
    (6, 5, '2026-11-24', 4, 11200, '2026-11-17');
GO

INSERT INTO Tickets (BookingId, SeatNumber, Status) VALUES
    (1, 'A1', 'Confirmed'),
    (1, 'A2', 'Confirmed'),
    (2, 'B1', 'Confirmed'),
    (3, 'C1', 'Confirmed'),
    (3, 'C2', 'Confirmed'),
    (3, 'C3', 'Confirmed'),
    (4, 'A3', 'Confirmed'),
    (5, 'D1', 'Confirmed'),
    (5, 'D2', 'Confirmed'),
    (6, 'E1', 'Confirmed'),
    (6, 'E2', 'Confirmed'),
    (6, 'E3', 'Confirmed'),
    (6, 'E4', 'Cancelled');
GO

-- Query 1: Seat availability — how many seats are still free on
-- Green Line Express (TrainId 1) for travel on 2026-11-20?
-- Expected result: 240 total seats - 3 booked seats (2 + 1) = 237 free.
SELECT
    t.TrainName,
    t.TotalSeats,
    ISNULL(SUM(b.SeatsBooked), 0) AS BookedSeats,
    t.TotalSeats - ISNULL(SUM(b.SeatsBooked), 0) AS FreeSeats
FROM Trains t
LEFT JOIN Bookings b ON b.TrainId = t.TrainId AND b.TravelDate = '2026-11-20'
WHERE t.TrainId = 1
GROUP BY t.TrainName, t.TotalSeats;
GO

-- Query 2: Train schedule — all trains from Lahore to Karachi.
-- Expected result: 1 row, Green Line Express, 08:00 - 06:00, fare 4500.
SELECT
    t.TrainName,
    t.TrainNumber,
    s1.StationName AS SourceStation,
    s2.StationName AS DestinationStation,
    t.DepartureTime,
    t.ArrivalTime,
    t.FarePerSeat
FROM Trains t
INNER JOIN Stations s1 ON t.SourceStationId = s1.StationId
INNER JOIN Stations s2 ON t.DestinationStationId = s2.StationId
WHERE s1.City = 'Lahore' AND s2.City = 'Karachi';
GO

-- Query 3: All bookings of one passenger (Ahmed Raza) with train names.
-- Expected result: 1 row, Green Line Express, 2026-11-20, 2 seats, 9000.
SELECT
    p.FullName AS Passenger,
    t.TrainName,
    t.TrainNumber,
    b.TravelDate,
    b.SeatsBooked,
    b.TotalFare
FROM Bookings b
INNER JOIN Passengers p ON b.PassengerId = p.PassengerId
INNER JOIN Trains t ON b.TrainId = t.TrainId
WHERE p.FullName = 'Ahmed Raza'
ORDER BY b.TravelDate;
GO

-- Query 4: Total revenue per train (sum of all booking fares).
-- Expected result: Green Line 13500, Tezgam 3200, Khyber Mail 11400,
-- Awam Express 3000, Pakistan Express 11200.
SELECT
    t.TrainName,
    COUNT(b.BookingId) AS TotalBookings,
    SUM(b.TotalFare) AS TotalRevenue
FROM Trains t
LEFT JOIN Bookings b ON b.TrainId = t.TrainId
GROUP BY t.TrainName
ORDER BY TotalRevenue DESC;
GO

-- Query 5: All confirmed tickets with passenger and train names.
-- Expected result: 12 rows (13 tickets in total, 1 is Cancelled).
SELECT
    tk.TicketId,
    p.FullName AS Passenger,
    t.TrainName,
    b.TravelDate,
    tk.SeatNumber,
    tk.Status
FROM Tickets tk
INNER JOIN Bookings b ON tk.BookingId = b.BookingId
INNER JOIN Passengers p ON b.PassengerId = p.PassengerId
INNER JOIN Trains t ON b.TrainId = t.TrainId
WHERE tk.Status = 'Confirmed'
ORDER BY tk.TicketId;
GO
