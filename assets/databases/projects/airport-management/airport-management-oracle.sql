-- airport-management-oracle.sql
-- Airport Management System — Oracle version.
-- Run this script in Oracle SQL Developer (open the file and press F5,
-- Run Script) or in SQL*Plus (@airport-management-oracle.sql).
-- Oracle has no CREATE DATABASE statement like SQL Server: the tables are
-- created in the schema (user) you are connected as. If you want a
-- separate user for this project, create one first in SQL Developer or
-- SQL*Plus, for example:
--   CREATE USER airport_user IDENTIFIED BY your_password;
--   GRANT CONNECT, RESOURCE TO airport_user;
-- and then connect as airport_user and run this script.
-- Needs: Oracle Database XE (free) or any Oracle Database 19c or later.
-- The matching SQL Server version of this script is
-- airport-management-sqlserver.sql.

CREATE TABLE Airlines (
    AirlineId NUMBER(10) PRIMARY KEY,
    AirlineName VARCHAR2(100) NOT NULL,
    Country VARCHAR2(100),
    ContactEmail VARCHAR2(100)
);

CREATE TABLE Flights (
    FlightId NUMBER(10) PRIMARY KEY,
    FlightNumber VARCHAR2(20) NOT NULL UNIQUE,
    AirlineId NUMBER(10) REFERENCES Airlines(AirlineId),
    SourceAirport VARCHAR2(100) NOT NULL,
    DestinationAirport VARCHAR2(100) NOT NULL,
    DepartureTime DATE NOT NULL,
    ArrivalTime DATE NOT NULL,
    Status VARCHAR2(20) DEFAULT 'Scheduled' NOT NULL,
    TotalSeats NUMBER(10) NOT NULL,
    FarePerSeat NUMBER(10,2) NOT NULL
);

CREATE TABLE Passengers (
    PassengerId NUMBER(10) PRIMARY KEY,
    FullName VARCHAR2(100) NOT NULL,
    PassportNo VARCHAR2(20) NOT NULL UNIQUE,
    Nationality VARCHAR2(100),
    Phone VARCHAR2(20)
);

CREATE TABLE Bookings (
    BookingId NUMBER(10) PRIMARY KEY,
    PassengerId NUMBER(10) REFERENCES Passengers(PassengerId),
    FlightId NUMBER(10) REFERENCES Flights(FlightId),
    BookingDate DATE NOT NULL DEFAULT SYSDATE,
    SeatNumber VARCHAR2(10),
    TicketClass VARCHAR2(20),
    Fare NUMBER(10,2) NOT NULL
);

CREATE TABLE Staff (
    StaffId NUMBER(10) PRIMARY KEY,
    FullName VARCHAR2(100) NOT NULL,
    Role VARCHAR2(100),
    AirlineId NUMBER(10) REFERENCES Airlines(AirlineId),
    Phone VARCHAR2(20),
    Salary NUMBER(10,2)
);

-- Sequences for auto-increment IDs. Oracle has no IDENTITY like SQL Server,
-- so a sequence plus a trigger fills in the ID when a row is inserted
-- without one. Each sequence starts after the highest sample ID below
-- (Airlines has 4 sample rows and Flights has 5, so both sequences start
-- at 6; Passengers and Bookings have 6 rows, so they start at 7;
-- Staff has 5 rows, so its sequence starts at 6).
CREATE SEQUENCE airlines_seq START WITH 6 INCREMENT BY 1;
CREATE SEQUENCE flights_seq START WITH 6 INCREMENT BY 1;
CREATE SEQUENCE passengers_seq START WITH 7 INCREMENT BY 1;
CREATE SEQUENCE bookings_seq START WITH 7 INCREMENT BY 1;
CREATE SEQUENCE staff_seq START WITH 6 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_airlines_bi
BEFORE INSERT ON Airlines
FOR EACH ROW
BEGIN
    IF :NEW.AirlineId IS NULL THEN
        SELECT airlines_seq.NEXTVAL INTO :NEW.AirlineId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_flights_bi
BEFORE INSERT ON Flights
FOR EACH ROW
BEGIN
    IF :NEW.FlightId IS NULL THEN
        SELECT flights_seq.NEXTVAL INTO :NEW.FlightId FROM dual;
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

CREATE OR REPLACE TRIGGER trg_staff_bi
BEFORE INSERT ON Staff
FOR EACH ROW
BEGIN
    IF :NEW.StaffId IS NULL THEN
        SELECT staff_seq.NEXTVAL INTO :NEW.StaffId FROM dual;
    END IF;
END;
/

INSERT INTO Airlines (AirlineId, AirlineName, Country, ContactEmail) VALUES
    (1, 'PIA', 'Pakistan', 'info@pia.com.pk');
INSERT INTO Airlines (AirlineId, AirlineName, Country, ContactEmail) VALUES
    (2, 'Emirates', 'UAE', 'info@emirates.com');
INSERT INTO Airlines (AirlineId, AirlineName, Country, ContactEmail) VALUES
    (3, 'Qatar Airways', 'Qatar', 'info@qatarairways.com');
INSERT INTO Airlines (AirlineId, AirlineName, Country, ContactEmail) VALUES
    (4, 'Turkish Airlines', 'Turkey', 'info@turkishairlines.com');

-- DepartureTime / ArrivalTime are DATE values with a time, written with
-- TO_DATE('2026-11-20 09:00', 'YYYY-MM-DD HH24:MI').
INSERT INTO Flights (FlightId, FlightNumber, AirlineId, SourceAirport, DestinationAirport, DepartureTime, ArrivalTime, Status, TotalSeats, FarePerSeat) VALUES
    (1, 'PK-701', 1, 'Lahore', 'Dubai', TO_DATE('2026-11-20 09:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-20 11:30', 'YYYY-MM-DD HH24:MI'), 'Scheduled', 180, 85000);
INSERT INTO Flights (FlightId, FlightNumber, AirlineId, SourceAirport, DestinationAirport, DepartureTime, ArrivalTime, Status, TotalSeats, FarePerSeat) VALUES
    (2, 'EK-612', 2, 'Karachi', 'Dubai', TO_DATE('2026-11-20 14:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-20 15:15', 'YYYY-MM-DD HH24:MI'), 'Scheduled', 220, 45000);
INSERT INTO Flights (FlightId, FlightNumber, AirlineId, SourceAirport, DestinationAirport, DepartureTime, ArrivalTime, Status, TotalSeats, FarePerSeat) VALUES
    (3, 'QR-845', 3, 'Islamabad', 'Doha', TO_DATE('2026-11-21 10:30', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-21 12:00', 'YYYY-MM-DD HH24:MI'), 'Delayed', 200, 52000);
INSERT INTO Flights (FlightId, FlightNumber, AirlineId, SourceAirport, DestinationAirport, DepartureTime, ArrivalTime, Status, TotalSeats, FarePerSeat) VALUES
    (4, 'TK-709', 4, 'Lahore', 'Istanbul', TO_DATE('2026-11-22 06:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-22 10:30', 'YYYY-MM-DD HH24:MI'), 'Scheduled', 190, 120000);
INSERT INTO Flights (FlightId, FlightNumber, AirlineId, SourceAirport, DestinationAirport, DepartureTime, ArrivalTime, Status, TotalSeats, FarePerSeat) VALUES
    (5, 'PK-302', 1, 'Karachi', 'Islamabad', TO_DATE('2026-11-21 08:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-21 09:45', 'YYYY-MM-DD HH24:MI'), 'Cancelled', 150, 25000);

INSERT INTO Passengers (PassengerId, FullName, PassportNo, Nationality, Phone) VALUES
    (1, 'Ahmed Raza', 'AB1234567', 'Pakistani', '0300-1234567');
INSERT INTO Passengers (PassengerId, FullName, PassportNo, Nationality, Phone) VALUES
    (2, 'Fatima Khan', 'CD7654321', 'Pakistani', '0301-2345678');
INSERT INTO Passengers (PassengerId, FullName, PassportNo, Nationality, Phone) VALUES
    (3, 'Bilal Ahmed', 'EF9876543', 'Pakistani', '0302-3456789');
INSERT INTO Passengers (PassengerId, FullName, PassportNo, Nationality, Phone) VALUES
    (4, 'Ayesha Malik', 'GH1122334', 'Pakistani', '0303-4567890');
INSERT INTO Passengers (PassengerId, FullName, PassportNo, Nationality, Phone) VALUES
    (5, 'Usman Ghani', 'IJ5566778', 'Pakistani', '0304-5678901');
INSERT INTO Passengers (PassengerId, FullName, PassportNo, Nationality, Phone) VALUES
    (6, 'Maryam Siddiqui', 'KL9988776', 'Pakistani', '0305-6789012');

-- A booking Fare always equals the FarePerSeat of its flight.
-- Booking 1: PK-701 at 85000. Booking 3: QR-845 at 52000.
-- Booking 6: PK-302 at 25000 (the flight is Cancelled, the booking stays).
INSERT INTO Bookings (BookingId, PassengerId, FlightId, BookingDate, SeatNumber, TicketClass, Fare) VALUES
    (1, 1, 1, TO_DATE('2026-11-15', 'YYYY-MM-DD'), '12A', 'Economy', 85000);
INSERT INTO Bookings (BookingId, PassengerId, FlightId, BookingDate, SeatNumber, TicketClass, Fare) VALUES
    (2, 2, 2, TO_DATE('2026-11-16', 'YYYY-MM-DD'), '08B', 'Economy', 45000);
INSERT INTO Bookings (BookingId, PassengerId, FlightId, BookingDate, SeatNumber, TicketClass, Fare) VALUES
    (3, 3, 3, TO_DATE('2026-11-17', 'YYYY-MM-DD'), '22C', 'Business', 52000);
INSERT INTO Bookings (BookingId, PassengerId, FlightId, BookingDate, SeatNumber, TicketClass, Fare) VALUES
    (4, 4, 1, TO_DATE('2026-11-18', 'YYYY-MM-DD'), '12B', 'Economy', 85000);
INSERT INTO Bookings (BookingId, PassengerId, FlightId, BookingDate, SeatNumber, TicketClass, Fare) VALUES
    (5, 5, 4, TO_DATE('2026-11-19', 'YYYY-MM-DD'), '30A', 'Economy', 120000);
INSERT INTO Bookings (BookingId, PassengerId, FlightId, BookingDate, SeatNumber, TicketClass, Fare) VALUES
    (6, 6, 5, TO_DATE('2026-11-20', 'YYYY-MM-DD'), '05D', 'Economy', 25000);

INSERT INTO Staff (StaffId, FullName, Role, AirlineId, Phone, Salary) VALUES
    (1, 'Capt. Ali Raza', 'Pilot', 1, '0300-1111111', 450000);
INSERT INTO Staff (StaffId, FullName, Role, AirlineId, Phone, Salary) VALUES
    (2, 'Sara Ahmed', 'Cabin Crew', 2, '0301-2222222', 120000);
INSERT INTO Staff (StaffId, FullName, Role, AirlineId, Phone, Salary) VALUES
    (3, 'Hassan Malik', 'Ground Staff', 1, '0302-3333333', 80000);
INSERT INTO Staff (StaffId, FullName, Role, AirlineId, Phone, Salary) VALUES
    (4, 'Fatima Noor', 'Engineer', 3, '0303-4444444', 200000);
INSERT INTO Staff (StaffId, FullName, Role, AirlineId, Phone, Salary) VALUES
    (5, 'Bilal Hussain', 'Manager', 4, '0304-5555555', 250000);

COMMIT;

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
WHERE TRUNC(f.DepartureTime) = TO_DATE('2026-11-20', 'YYYY-MM-DD')
ORDER BY f.DepartureTime;

-- Query 4: Total revenue per airline (sum of all booking fares).
-- Expected result: PIA 195000 (85000 + 85000 + 25000), Emirates 45000,
-- Qatar Airways 52000, Turkish Airlines 120000.
-- (Oracle uses NVL where SQL Server uses ISNULL.)
SELECT
    a.AirlineName,
    COUNT(b.BookingId) AS TotalBookings,
    NVL(SUM(b.Fare), 0) AS TotalRevenue
FROM Airlines a
LEFT JOIN Flights f ON f.AirlineId = a.AirlineId
LEFT JOIN Bookings b ON b.FlightId = f.FlightId
GROUP BY a.AirlineName
ORDER BY TotalRevenue DESC;

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

COMMIT;
