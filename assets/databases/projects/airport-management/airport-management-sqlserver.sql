-- airport-management-sqlserver.sql
-- Airport Management System — SQL Server version.
-- Run this script in SQL Server Management Studio (SSMS) or in Visual
-- Studio's SQL Server Object Explorer. It creates the AirportDB database,
-- 5 tables (Airlines, Flights, Passengers, Bookings, Staff), inserts the
-- sample data, and then runs 5 practical SELECT queries.
-- Needs: SQL Server Express, SQL Server Developer, or LocalDB.
-- The matching Oracle version of this script is airport-management-oracle.sql.

CREATE DATABASE AirportDB;
GO

USE AirportDB;
GO

CREATE TABLE Airlines (
    AirlineId INT PRIMARY KEY IDENTITY(1,1),
    AirlineName NVARCHAR(100) NOT NULL,
    Country NVARCHAR(100),
    ContactEmail NVARCHAR(100)
);
GO

CREATE TABLE Flights (
    FlightId INT PRIMARY KEY IDENTITY(1,1),
    FlightNumber NVARCHAR(20) NOT NULL UNIQUE,
    AirlineId INT FOREIGN KEY REFERENCES Airlines(AirlineId),
    SourceAirport NVARCHAR(100) NOT NULL,
    DestinationAirport NVARCHAR(100) NOT NULL,
    DepartureTime DATETIME NOT NULL,
    ArrivalTime DATETIME NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Scheduled',
    TotalSeats INT NOT NULL,
    FarePerSeat DECIMAL(10,2) NOT NULL
);
GO

CREATE TABLE Passengers (
    PassengerId INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    PassportNo NVARCHAR(20) NOT NULL UNIQUE,
    Nationality NVARCHAR(100),
    Phone NVARCHAR(20)
);
GO

CREATE TABLE Bookings (
    BookingId INT PRIMARY KEY IDENTITY(1,1),
    PassengerId INT FOREIGN KEY REFERENCES Passengers(PassengerId),
    FlightId INT FOREIGN KEY REFERENCES Flights(FlightId),
    BookingDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    SeatNumber NVARCHAR(10),
    TicketClass NVARCHAR(20),
    Fare DECIMAL(10,2) NOT NULL
);
GO

CREATE TABLE Staff (
    StaffId INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    Role NVARCHAR(100),
    AirlineId INT FOREIGN KEY REFERENCES Airlines(AirlineId),
    Phone NVARCHAR(20),
    Salary DECIMAL(10,2)
);
GO

INSERT INTO Airlines (AirlineName, Country, ContactEmail) VALUES
    ('PIA', 'Pakistan', 'info@pia.com.pk'),
    ('Emirates', 'UAE', 'info@emirates.com'),
    ('Qatar Airways', 'Qatar', 'info@qatarairways.com'),
    ('Turkish Airlines', 'Turkey', 'info@turkishairlines.com');
GO

-- DepartureTime / ArrivalTime are full date-and-time values.
-- PK-701 leaves Lahore at 09:00 on 20 Nov 2026 and reaches Dubai at 11:30.
INSERT INTO Flights (FlightNumber, AirlineId, SourceAirport, DestinationAirport, DepartureTime, ArrivalTime, Status, TotalSeats, FarePerSeat) VALUES
    ('PK-701', 1, 'Lahore', 'Dubai', '2026-11-20 09:00', '2026-11-20 11:30', 'Scheduled', 180, 85000),
    ('EK-612', 2, 'Karachi', 'Dubai', '2026-11-20 14:00', '2026-11-20 15:15', 'Scheduled', 220, 45000),
    ('QR-845', 3, 'Islamabad', 'Doha', '2026-11-21 10:30', '2026-11-21 12:00', 'Delayed', 200, 52000),
    ('TK-709', 4, 'Lahore', 'Istanbul', '2026-11-22 06:00', '2026-11-22 10:30', 'Scheduled', 190, 120000),
    ('PK-302', 1, 'Karachi', 'Islamabad', '2026-11-21 08:00', '2026-11-21 09:45', 'Cancelled', 150, 25000);
GO

INSERT INTO Passengers (FullName, PassportNo, Nationality, Phone) VALUES
    ('Ahmed Raza', 'AB1234567', 'Pakistani', '0300-1234567'),
    ('Fatima Khan', 'CD7654321', 'Pakistani', '0301-2345678'),
    ('Bilal Ahmed', 'EF9876543', 'Pakistani', '0302-3456789'),
    ('Ayesha Malik', 'GH1122334', 'Pakistani', '0303-4567890'),
    ('Usman Ghani', 'IJ5566778', 'Pakistani', '0304-5678901'),
    ('Maryam Siddiqui', 'KL9988776', 'Pakistani', '0305-6789012');
GO

-- A booking Fare always equals the FarePerSeat of its flight.
-- Booking 1: PK-701 at 85000. Booking 3: QR-845 at 52000.
-- Booking 6: PK-302 at 25000 (the flight is Cancelled, the booking stays).
INSERT INTO Bookings (PassengerId, FlightId, BookingDate, SeatNumber, TicketClass, Fare) VALUES
    (1, 1, '2026-11-15', '12A', 'Economy', 85000),
    (2, 2, '2026-11-16', '08B', 'Economy', 45000),
    (3, 3, '2026-11-17', '22C', 'Business', 52000),
    (4, 1, '2026-11-18', '12B', 'Economy', 85000),
    (5, 4, '2026-11-19', '30A', 'Economy', 120000),
    (6, 5, '2026-11-20', '05D', 'Economy', 25000);
GO

INSERT INTO Staff (FullName, Role, AirlineId, Phone, Salary) VALUES
    ('Capt. Ali Raza', 'Pilot', 1, '0300-1111111', 450000),
    ('Sara Ahmed', 'Cabin Crew', 2, '0301-2222222', 120000),
    ('Hassan Malik', 'Ground Staff', 1, '0302-3333333', 80000),
    ('Fatima Noor', 'Engineer', 3, '0303-4444444', 200000),
    ('Bilal Hussain', 'Manager', 4, '0304-5555555', 250000);
GO

-- Query 1: Flight status by flight number — the details of PK-701.
-- Expected result: 1 row, PK-701, Scheduled, Lahore to Dubai,
-- departure 2026-11-20 09:00, 180 seats.
SELECT
    f.FlightNumber,
    a.AirlineName,
    f.SourceAirport,
    f.DestinationAirport,
    f.DepartureTime,
    f.ArrivalTime,
    f.Status,
    f.TotalSeats,
    f.FarePerSeat
FROM Flights f
INNER JOIN Airlines a ON f.AirlineId = a.AirlineId
WHERE f.FlightNumber = 'PK-701';
GO

-- Query 2: Passenger list per flight — who is booked on flight 1 (PK-701)?
-- Expected result: 2 rows, Ahmed Raza (seat 12A) and Ayesha Malik (seat 12B).
SELECT
    p.FullName AS Passenger,
    p.PassportNo,
    b.SeatNumber,
    b.TicketClass,
    b.Fare
FROM Bookings b
INNER JOIN Passengers p ON b.PassengerId = p.PassengerId
INNER JOIN Flights f ON b.FlightId = f.FlightId
WHERE f.FlightId = 1
ORDER BY b.SeatNumber;
GO

-- Query 3: Flights departing on 2026-11-20.
-- Expected result: 2 flights, PK-701 (Lahore to Dubai, 09:00)
-- and EK-612 (Karachi to Dubai, 14:00).
SELECT
    f.FlightNumber,
    a.AirlineName,
    f.SourceAirport,
    f.DestinationAirport,
    f.DepartureTime,
    f.Status
FROM Flights f
INNER JOIN Airlines a ON f.AirlineId = a.AirlineId
WHERE CAST(f.DepartureTime AS DATE) = '2026-11-20'
ORDER BY f.DepartureTime;
GO

-- Query 4: Total revenue per airline (sum of all booking fares).
-- Expected result: PIA 195000 (85000 + 85000 + 25000), Emirates 45000,
-- Qatar Airways 52000, Turkish Airlines 120000.
SELECT
    a.AirlineName,
    COUNT(b.BookingId) AS TotalBookings,
    ISNULL(SUM(b.Fare), 0) AS TotalRevenue
FROM Airlines a
LEFT JOIN Flights f ON f.AirlineId = a.AirlineId
LEFT JOIN Bookings b ON b.FlightId = f.FlightId
GROUP BY a.AirlineName
ORDER BY TotalRevenue DESC;
GO

-- Query 5: Flights by route — all flights from Lahore to Dubai.
-- Expected result: 1 flight, PK-701, Scheduled, 09:00, fare 85000.
SELECT
    f.FlightNumber,
    a.AirlineName,
    f.SourceAirport,
    f.DestinationAirport,
    f.DepartureTime,
    f.ArrivalTime,
    f.Status,
    f.FarePerSeat
FROM Flights f
INNER JOIN Airlines a ON f.AirlineId = a.AirlineId
WHERE f.SourceAirport = 'Lahore' AND f.DestinationAirport = 'Dubai';
GO
