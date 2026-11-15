-- railway-reservation-oracle.sql
-- Railway Reservation System — Oracle version.
-- Run this script in Oracle SQL Developer (open the file and press F5,
-- Run Script) or in SQL*Plus (@railway-reservation-oracle.sql).
-- Oracle has no CREATE DATABASE statement like SQL Server: the tables are
-- created in the schema (user) you are connected as. If you want a
-- separate user for this project, create one first in SQL Developer or
-- SQL*Plus, for example:
--   CREATE USER railway_user IDENTIFIED BY your_password;
--   GRANT CONNECT, RESOURCE TO railway_user;
-- and then connect as railway_user and run this script.
-- Needs: Oracle Database XE (free) or any Oracle Database 19c or later.
-- The matching SQL Server version of this script is
-- railway-reservation-sqlserver.sql.

CREATE TABLE Stations (
    StationId NUMBER(10) PRIMARY KEY,
    StationName VARCHAR2(100) NOT NULL,
    City VARCHAR2(100) NOT NULL,
    PlatformCount NUMBER(10)
);

CREATE TABLE Trains (
    TrainId NUMBER(10) PRIMARY KEY,
    TrainName VARCHAR2(100) NOT NULL,
    TrainNumber VARCHAR2(20) NOT NULL UNIQUE,
    SourceStationId NUMBER(10) REFERENCES Stations(StationId),
    DestinationStationId NUMBER(10) REFERENCES Stations(StationId),
    DepartureTime VARCHAR2(5) NOT NULL,
    ArrivalTime VARCHAR2(5) NOT NULL,
    TotalSeats NUMBER(10) NOT NULL,
    FarePerSeat NUMBER(10,2) NOT NULL
);

CREATE TABLE Passengers (
    PassengerId NUMBER(10) PRIMARY KEY,
    FullName VARCHAR2(100) NOT NULL,
    CNIC VARCHAR2(15) NOT NULL UNIQUE,
    Phone VARCHAR2(20),
    Email VARCHAR2(100)
);

CREATE TABLE Bookings (
    BookingId NUMBER(10) PRIMARY KEY,
    PassengerId NUMBER(10) REFERENCES Passengers(PassengerId),
    TrainId NUMBER(10) REFERENCES Trains(TrainId),
    TravelDate DATE NOT NULL,
    SeatsBooked NUMBER(10) NOT NULL,
    TotalFare NUMBER(10,2) NOT NULL,
    BookingDate DATE NOT NULL DEFAULT SYSDATE
);

CREATE TABLE Tickets (
    TicketId NUMBER(10) PRIMARY KEY,
    BookingId NUMBER(10) REFERENCES Bookings(BookingId),
    SeatNumber VARCHAR2(10) NOT NULL,
    Status VARCHAR2(20) DEFAULT 'Confirmed' NOT NULL
);

-- Sequences for auto-increment IDs. Oracle has no IDENTITY like SQL Server,
-- so a sequence plus a trigger fills in the ID when a row is inserted
-- without one. Each sequence starts AFTER the highest sample ID below
-- (Stations and Trains have 5 sample rows, so their sequences start at 6;
-- Passengers and Bookings have 6 rows, so they start at 7; Tickets has
-- 13 rows, so its sequence starts at 14).
CREATE SEQUENCE stations_seq START WITH 6 INCREMENT BY 1;
CREATE SEQUENCE trains_seq START WITH 6 INCREMENT BY 1;
CREATE SEQUENCE passengers_seq START WITH 7 INCREMENT BY 1;
CREATE SEQUENCE bookings_seq START WITH 7 INCREMENT BY 1;
CREATE SEQUENCE tickets_seq START WITH 14 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_stations_bi
BEFORE INSERT ON Stations
FOR EACH ROW
BEGIN
    IF :NEW.StationId IS NULL THEN
        SELECT stations_seq.NEXTVAL INTO :NEW.StationId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_trains_bi
BEFORE INSERT ON Trains
FOR EACH ROW
BEGIN
    IF :NEW.TrainId IS NULL THEN
        SELECT trains_seq.NEXTVAL INTO :NEW.TrainId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_passengers_bi
BEFORE INSERT ON Passengers
FOR EACH ROW
BEGIN
    IF :NEW.PassengerId IS NULL THEN
        SELECT passengers_seq.NEXTVAL INTO :NEW.PassengerId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_bookings_bi
BEFORE INSERT ON Bookings
FOR EACH ROW
BEGIN
    IF :NEW.BookingId IS NULL THEN
        SELECT bookings_seq.NEXTVAL INTO :NEW.BookingId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_tickets_bi
BEFORE INSERT ON Tickets
FOR EACH ROW
BEGIN
    IF :NEW.TicketId IS NULL THEN
        SELECT tickets_seq.NEXTVAL INTO :NEW.TicketId FROM dual;
    END IF;
END;
/

INSERT INTO Stations (StationId, StationName, City, PlatformCount) VALUES
    (1, 'Lahore Junction', 'Lahore', 8);
INSERT INTO Stations (StationId, StationName, City, PlatformCount) VALUES
    (2, 'Karachi Cantt', 'Karachi', 10);
INSERT INTO Stations (StationId, StationName, City, PlatformCount) VALUES
    (3, 'Rawalpindi', 'Rawalpindi', 6);
INSERT INTO Stations (StationId, StationName, City, PlatformCount) VALUES
    (4, 'Multan Cantt', 'Multan', 5);
INSERT INTO Stations (StationId, StationName, City, PlatformCount) VALUES
    (5, 'Peshawar Cantt', 'Peshawar', 4);

-- Train times are departure / arrival clock times stored as text 'HH:MM'.
-- Green Line leaves Lahore at 08:00 and reaches Karachi at 06:00 next morning.
INSERT INTO Trains (TrainId, TrainName, TrainNumber, SourceStationId, DestinationStationId, DepartureTime, ArrivalTime, TotalSeats, FarePerSeat) VALUES
    (1, 'Green Line Express', 'GL-15UP', 1, 2, '08:00', '06:00', 240, 4500);
INSERT INTO Trains (TrainId, TrainName, TrainNumber, SourceStationId, DestinationStationId, DepartureTime, ArrivalTime, TotalSeats, FarePerSeat) VALUES
    (2, 'Tezgam', 'TG-7UP', 2, 3, '17:30', '13:00', 300, 3200);
INSERT INTO Trains (TrainId, TrainName, TrainNumber, SourceStationId, DestinationStationId, DepartureTime, ArrivalTime, TotalSeats, FarePerSeat) VALUES
    (3, 'Khyber Mail', 'KM-1UP', 2, 5, '22:00', '18:00', 280, 3800);
INSERT INTO Trains (TrainId, TrainName, TrainNumber, SourceStationId, DestinationStationId, DepartureTime, ArrivalTime, TotalSeats, FarePerSeat) VALUES
    (4, 'Awam Express', 'AW-13UP', 1, 5, '09:30', '16:00', 200, 1500);
INSERT INTO Trains (TrainId, TrainName, TrainNumber, SourceStationId, DestinationStationId, DepartureTime, ArrivalTime, TotalSeats, FarePerSeat) VALUES
    (5, 'Pakistan Express', 'PK-45UP', 2, 1, '19:00', '14:00', 260, 2800);

INSERT INTO Passengers (PassengerId, FullName, CNIC, Phone, Email) VALUES
    (1, 'Ahmed Raza', '35202-1234567-1', '0300-1234567', 'ahmed.raza@email.com');
INSERT INTO Passengers (PassengerId, FullName, CNIC, Phone, Email) VALUES
    (2, 'Fatima Khan', '35202-7654321-2', '0301-2345678', 'fatima.khan@email.com');
INSERT INTO Passengers (PassengerId, FullName, CNIC, Phone, Email) VALUES
    (3, 'Bilal Ahmed', '61101-9876543-3', '0302-3456789', 'bilal.ahmed@email.com');
INSERT INTO Passengers (PassengerId, FullName, CNIC, Phone, Email) VALUES
    (4, 'Ayesha Malik', '35202-1122334-4', '0303-4567890', 'ayesha.malik@email.com');
INSERT INTO Passengers (PassengerId, FullName, CNIC, Phone, Email) VALUES
    (5, 'Usman Ghani', '61101-5566778-5', '0304-5678901', 'usman.ghani@email.com');
INSERT INTO Passengers (PassengerId, FullName, CNIC, Phone, Email) VALUES
    (6, 'Maryam Siddiqui', '35202-9988776-6', '0305-6789012', 'maryam.siddiqui@email.com');

-- TotalFare = SeatsBooked x FarePerSeat of the train.
-- Booking 1: 2 x 4500 = 9000. Booking 3: 3 x 3800 = 11400.
-- Booking 6: 4 x 2800 = 11200.
INSERT INTO Bookings (BookingId, PassengerId, TrainId, TravelDate, SeatsBooked, TotalFare, BookingDate) VALUES
    (1, 1, 1, TO_DATE('2026-11-20', 'YYYY-MM-DD'), 2, 9000, TO_DATE('2026-11-15', 'YYYY-MM-DD'));
INSERT INTO Bookings (BookingId, PassengerId, TrainId, TravelDate, SeatsBooked, TotalFare, BookingDate) VALUES
    (2, 2, 2, TO_DATE('2026-11-21', 'YYYY-MM-DD'), 1, 3200, TO_DATE('2026-11-15', 'YYYY-MM-DD'));
INSERT INTO Bookings (BookingId, PassengerId, TrainId, TravelDate, SeatsBooked, TotalFare, BookingDate) VALUES
    (3, 3, 3, TO_DATE('2026-11-22', 'YYYY-MM-DD'), 3, 11400, TO_DATE('2026-11-16', 'YYYY-MM-DD'));
INSERT INTO Bookings (BookingId, PassengerId, TrainId, TravelDate, SeatsBooked, TotalFare, BookingDate) VALUES
    (4, 4, 1, TO_DATE('2026-11-20', 'YYYY-MM-DD'), 1, 4500, TO_DATE('2026-11-16', 'YYYY-MM-DD'));
INSERT INTO Bookings (BookingId, PassengerId, TrainId, TravelDate, SeatsBooked, TotalFare, BookingDate) VALUES
    (5, 5, 4, TO_DATE('2026-11-23', 'YYYY-MM-DD'), 2, 3000, TO_DATE('2026-11-17', 'YYYY-MM-DD'));
INSERT INTO Bookings (BookingId, PassengerId, TrainId, TravelDate, SeatsBooked, TotalFare, BookingDate) VALUES
    (6, 6, 5, TO_DATE('2026-11-24', 'YYYY-MM-DD'), 4, 11200, TO_DATE('2026-11-17', 'YYYY-MM-DD'));

INSERT INTO Tickets (TicketId, BookingId, SeatNumber, Status) VALUES
    (1, 1, 'A1', 'Confirmed');
INSERT INTO Tickets (TicketId, BookingId, SeatNumber, Status) VALUES
    (2, 1, 'A2', 'Confirmed');
INSERT INTO Tickets (TicketId, BookingId, SeatNumber, Status) VALUES
    (3, 2, 'B1', 'Confirmed');
INSERT INTO Tickets (TicketId, BookingId, SeatNumber, Status) VALUES
    (4, 3, 'C1', 'Confirmed');
INSERT INTO Tickets (TicketId, BookingId, SeatNumber, Status) VALUES
    (5, 3, 'C2', 'Confirmed');
INSERT INTO Tickets (TicketId, BookingId, SeatNumber, Status) VALUES
    (6, 3, 'C3', 'Confirmed');
INSERT INTO Tickets (TicketId, BookingId, SeatNumber, Status) VALUES
    (7, 4, 'A3', 'Confirmed');
INSERT INTO Tickets (TicketId, BookingId, SeatNumber, Status) VALUES
    (8, 5, 'D1', 'Confirmed');
INSERT INTO Tickets (TicketId, BookingId, SeatNumber, Status) VALUES
    (9, 5, 'D2', 'Confirmed');
INSERT INTO Tickets (TicketId, BookingId, SeatNumber, Status) VALUES
    (10, 6, 'E1', 'Confirmed');
INSERT INTO Tickets (TicketId, BookingId, SeatNumber, Status) VALUES
    (11, 6, 'E2', 'Confirmed');
INSERT INTO Tickets (TicketId, BookingId, SeatNumber, Status) VALUES
    (12, 6, 'E3', 'Confirmed');
INSERT INTO Tickets (TicketId, BookingId, SeatNumber, Status) VALUES
    (13, 6, 'E4', 'Cancelled');

COMMIT;

-- Query 1: Seat availability — how many seats are still free on
-- Green Line Express (TrainId 1) for travel on 2026-11-20?
-- Expected result: 240 total seats - 3 booked seats (2 + 1) = 237 free.
-- (Oracle uses NVL where SQL Server uses ISNULL.)
SELECT
    t.TrainName,
    t.TotalSeats,
    NVL(SUM(b.SeatsBooked), 0) AS BookedSeats,
    t.TotalSeats - NVL(SUM(b.SeatsBooked), 0) AS FreeSeats
FROM Trains t
LEFT JOIN Bookings b ON b.TrainId = t.TrainId AND b.TravelDate = TO_DATE('2026-11-20', 'YYYY-MM-DD')
WHERE t.TrainId = 1
GROUP BY t.TrainName, t.TotalSeats;

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

COMMIT;
