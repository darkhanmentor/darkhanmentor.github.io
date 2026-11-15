-- hospital-management-sqlserver.sql
-- Hospital Management System — SQL Server version.
-- Run this script in SQL Server Management Studio (SSMS) or in Visual
-- Studio's SQL Server Object Explorer. It creates the HospitalDB database,
-- 5 tables (Doctors, Patients, Appointments, Treatments, Bills), inserts the
-- sample data, and then runs 5 practical SELECT queries.
-- Needs: SQL Server Express, SQL Server Developer, or LocalDB.
-- The matching Oracle version of this script is hospital-management-oracle.sql.

CREATE DATABASE HospitalDB;
GO

USE HospitalDB;
GO

CREATE TABLE Doctors (
    DoctorId INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    Specialization NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Fee DECIMAL(10,2) NOT NULL
);
GO

CREATE TABLE Patients (
    PatientId INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    Age INT NOT NULL,
    Gender NVARCHAR(10) NOT NULL,
    Phone NVARCHAR(20),
    Address NVARCHAR(200)
);
GO

CREATE TABLE Appointments (
    AppointmentId INT PRIMARY KEY IDENTITY(1,1),
    PatientId INT FOREIGN KEY REFERENCES Patients(PatientId),
    DoctorId INT FOREIGN KEY REFERENCES Doctors(DoctorId),
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Scheduled'
);
GO

CREATE TABLE Treatments (
    TreatmentId INT PRIMARY KEY IDENTITY(1,1),
    AppointmentId INT FOREIGN KEY REFERENCES Appointments(AppointmentId),
    Diagnosis NVARCHAR(200) NOT NULL,
    Prescription NVARCHAR(300),
    TreatmentCost DECIMAL(10,2) NOT NULL
);
GO

CREATE TABLE Bills (
    BillId INT PRIMARY KEY IDENTITY(1,1),
    PatientId INT FOREIGN KEY REFERENCES Patients(PatientId),
    AppointmentId INT FOREIGN KEY REFERENCES Appointments(AppointmentId),
    TotalAmount DECIMAL(10,2) NOT NULL,
    PaidAmount DECIMAL(10,2) NOT NULL,
    BillDate DATE NOT NULL,
    Status NVARCHAR(20) NOT NULL
);
GO

INSERT INTO Doctors (FullName, Specialization, Phone, Fee) VALUES
    ('Dr. Ahmed Khan', 'Cardiology', '0300-1111111', 3000),
    ('Dr. Sara Malik', 'Pediatrics', '0301-2222222', 2000),
    ('Dr. Bilal Hussain', 'Orthopedic', '0302-3333333', 2500),
    ('Dr. Fatima Noor', 'Gynecology', '0303-4444444', 2500),
    ('Dr. Usman Raza', 'General Physician', '0304-5555555', 1500);
GO

INSERT INTO Patients (FullName, Age, Gender, Phone, Address) VALUES
    ('Ali Raza', 45, 'Male', '0300-1234567', 'House 12 Street 3 Lahore'),
    ('Ayesha Khan', 32, 'Female', '0301-2345678', 'House 5 Street 7 Karachi'),
    ('Hassan Ali', 28, 'Male', '0302-3456789', 'House 8 Street 2 Islamabad'),
    ('Maryam Tariq', 55, 'Female', '0303-4567890', 'House 20 Street 9 Lahore'),
    ('Bilal Ahmed', 40, 'Male', '0304-5678901', 'House 3 Street 4 Rawalpindi'),
    ('Zainab Noor', 22, 'Female', '0305-6789012', 'House 15 Street 6 Multan');
GO

-- Appointment times are clock times on the appointment date.
INSERT INTO Appointments (PatientId, DoctorId, AppointmentDate, AppointmentTime, Status) VALUES
    (1, 1, '2026-11-20', '10:00', 'Scheduled'),
    (2, 2, '2026-11-20', '11:00', 'Completed'),
    (3, 3, '2026-11-20', '12:00', 'Completed'),
    (4, 4, '2026-11-21', '09:30', 'Scheduled'),
    (5, 5, '2026-11-21', '10:30', 'Completed'),
    (6, 1, '2026-11-21', '11:00', 'Cancelled');
GO

INSERT INTO Treatments (AppointmentId, Diagnosis, Prescription, TreatmentCost) VALUES
    (2, 'Cold', 'Paracetamol', 1200),
    (3, 'Fracture', 'Plaster and painkillers', 5000),
    (5, 'Fever', 'Paracetamol', 800);
GO

-- TotalAmount = doctor fee + treatment cost (where a treatment exists).
-- Bill 1: Dr. Ahmed Khan fee 3000, no treatment = 3000.
-- Bill 2: Dr. Sara Malik fee 2000 + treatment 1200 = 3200.
-- Bill 3: Dr. Bilal Hussain fee 2500 + treatment 5000 = 7500.
-- Bill 4: Dr. Usman Raza fee 1500 + treatment 800 = 2300.
-- Status: Paid if PaidAmount = TotalAmount, Partial if some amount
-- is paid, Unpaid if nothing is paid.
INSERT INTO Bills (PatientId, AppointmentId, TotalAmount, PaidAmount, BillDate, Status) VALUES
    (1, 1, 3000, 3000, '2026-11-20', 'Paid'),
    (2, 2, 3200, 2000, '2026-11-20', 'Partial'),
    (3, 3, 7500, 0, '2026-11-20', 'Unpaid'),
    (5, 5, 2300, 2300, '2026-11-21', 'Paid');
GO

-- Query 1: Appointments of one doctor (Dr. Ahmed Khan, DoctorId 1).
-- Expected result: 2 rows — Appointment 1 (20 Nov, 10:00, Scheduled)
-- and Appointment 6 (21 Nov, 11:00, Cancelled).
SELECT
    a.AppointmentId,
    p.FullName AS Patient,
    a.AppointmentDate,
    a.AppointmentTime,
    a.Status
FROM Appointments a
INNER JOIN Patients p ON a.PatientId = p.PatientId
WHERE a.DoctorId = 1
ORDER BY a.AppointmentDate, a.AppointmentTime;
GO

-- Query 2: Full history of one patient (Ali Raza) — his appointments,
-- doctor, treatment (if any) and bill (if any).
-- Expected result: 1 row — Appointment 1 with Dr. Ahmed Khan on
-- 2026-11-20 at 10:00, no treatment yet, Bill 1 (3000, Paid).
-- The LEFT JOINs matter: Ali Raza has no treatment for Appointment 1,
-- and an INNER JOIN to Treatments would have hidden his appointment.
SELECT
    p.FullName AS Patient,
    d.FullName AS Doctor,
    a.AppointmentDate,
    a.AppointmentTime,
    t.Diagnosis,
    t.Prescription,
    b.TotalAmount,
    b.PaidAmount,
    b.Status AS BillStatus
FROM Patients p
INNER JOIN Appointments a ON a.PatientId = p.PatientId
INNER JOIN Doctors d ON a.DoctorId = d.DoctorId
LEFT JOIN Treatments t ON t.AppointmentId = a.AppointmentId
LEFT JOIN Bills b ON b.AppointmentId = a.AppointmentId
WHERE p.FullName = 'Ali Raza'
ORDER BY a.AppointmentDate;
GO

-- Query 3: Pending bills — bills that are Unpaid or only partly paid.
-- Expected result: 2 rows — Bill 2 (Ayesha Khan, 3200 total, 2000 paid,
-- Partial) and Bill 3 (Hassan Ali, 7500 total, 0 paid, Unpaid).
SELECT
    b.BillId,
    p.FullName AS Patient,
    b.TotalAmount,
    b.PaidAmount,
    b.BillDate,
    b.Status
FROM Bills b
INNER JOIN Patients p ON b.PatientId = p.PatientId
WHERE b.Status IN ('Unpaid', 'Partial')
ORDER BY b.BillId;
GO

-- Query 4: All appointments on one date (2026-11-20).
-- Expected result: 3 rows — Appointments 1, 2 and 3.
SELECT
    a.AppointmentId,
    p.FullName AS Patient,
    d.FullName AS Doctor,
    a.AppointmentTime,
    a.Status
FROM Appointments a
INNER JOIN Patients p ON a.PatientId = p.PatientId
INNER JOIN Doctors d ON a.DoctorId = d.DoctorId
WHERE a.AppointmentDate = '2026-11-20'
ORDER BY a.AppointmentTime;
GO

-- Query 5: Total collection per doctor (sum of PaidAmount on their bills).
-- Expected result: Dr. Ahmed Khan 3000, Dr. Usman Raza 2300,
-- Dr. Sara Malik 2000, Dr. Bilal Hussain 0, Dr. Fatima Noor 0.
-- Doctors with no paid bills still appear with 0, because of the
-- LEFT JOIN and ISNULL. (In Oracle, write NVL instead of ISNULL.)
SELECT
    d.FullName AS Doctor,
    ISNULL(SUM(b.PaidAmount), 0) AS TotalCollected
FROM Doctors d
LEFT JOIN Appointments a ON a.DoctorId = d.DoctorId
LEFT JOIN Bills b ON b.AppointmentId = a.AppointmentId
GROUP BY d.FullName
ORDER BY TotalCollected DESC;
GO
