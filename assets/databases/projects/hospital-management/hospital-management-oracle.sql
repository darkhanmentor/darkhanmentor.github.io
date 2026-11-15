-- hospital-management-oracle.sql
-- Hospital Management System — Oracle version.
-- Run this script in Oracle SQL Developer (open the file and press F5,
-- Run Script) or in SQL*Plus (@hospital-management-oracle.sql).
-- Oracle has no CREATE DATABASE statement like SQL Server: the tables are
-- created in the schema (user) you are connected as. If you want a
-- separate user for this project, create one first in SQL Developer or
-- SQL*Plus, for example:
--   CREATE USER hospital_user IDENTIFIED BY your_password;
--   GRANT CONNECT, RESOURCE TO hospital_user;
-- and then connect as hospital_user and run this script.
-- Needs: Oracle Database XE (free) or any Oracle Database 19c or later.
-- The matching SQL Server version of this script is
-- hospital-management-sqlserver.sql.

CREATE TABLE Doctors (
    DoctorId NUMBER(10) PRIMARY KEY,
    FullName VARCHAR2(100) NOT NULL,
    Specialization VARCHAR2(100) NOT NULL,
    Phone VARCHAR2(20),
    Fee NUMBER(10,2) NOT NULL
);

CREATE TABLE Patients (
    PatientId NUMBER(10) PRIMARY KEY,
    FullName VARCHAR2(100) NOT NULL,
    Age NUMBER(10) NOT NULL,
    Gender VARCHAR2(10) NOT NULL,
    Phone VARCHAR2(20),
    Address VARCHAR2(200)
);

CREATE TABLE Appointments (
    AppointmentId NUMBER(10) PRIMARY KEY,
    PatientId NUMBER(10) REFERENCES Patients(PatientId),
    DoctorId NUMBER(10) REFERENCES Doctors(DoctorId),
    AppointmentDate DATE NOT NULL,
    AppointmentTime VARCHAR2(5) NOT NULL,
    Status VARCHAR2(20) DEFAULT 'Scheduled' NOT NULL
);

CREATE TABLE Treatments (
    TreatmentId NUMBER(10) PRIMARY KEY,
    AppointmentId NUMBER(10) REFERENCES Appointments(AppointmentId),
    Diagnosis VARCHAR2(200) NOT NULL,
    Prescription VARCHAR2(300),
    TreatmentCost NUMBER(10,2) NOT NULL
);

CREATE TABLE Bills (
    BillId NUMBER(10) PRIMARY KEY,
    PatientId NUMBER(10) REFERENCES Patients(PatientId),
    AppointmentId NUMBER(10) REFERENCES Appointments(AppointmentId),
    TotalAmount NUMBER(10,2) NOT NULL,
    PaidAmount NUMBER(10,2) NOT NULL,
    BillDate DATE NOT NULL,
    Status VARCHAR2(20) NOT NULL
);

-- Sequences for auto-increment IDs. Oracle has no IDENTITY like SQL Server,
-- so a sequence plus a trigger fills in the ID when a row is inserted
-- without one. Each sequence starts AFTER the highest sample ID below
-- (Doctors has 5 sample rows, so its sequence starts at 6;
-- Patients and Appointments have 6 rows, so they start at 7;
-- Treatments has 3 rows, so it starts at 4; Bills has 4 rows, so it
-- starts at 5).
CREATE SEQUENCE doctors_seq START WITH 6 INCREMENT BY 1;
CREATE SEQUENCE patients_seq START WITH 7 INCREMENT BY 1;
CREATE SEQUENCE appointments_seq START WITH 7 INCREMENT BY 1;
CREATE SEQUENCE treatments_seq START WITH 4 INCREMENT BY 1;
CREATE SEQUENCE bills_seq START WITH 5 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_doctors_bi
BEFORE INSERT ON Doctors
FOR EACH ROW
BEGIN
    IF :NEW.DoctorId IS NULL THEN
        SELECT doctors_seq.NEXTVAL INTO :NEW.DoctorId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_patients_bi
BEFORE INSERT ON Patients
FOR EACH ROW
BEGIN
    IF :NEW.PatientId IS NULL THEN
        SELECT patients_seq.NEXTVAL INTO :NEW.PatientId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_appointments_bi
BEFORE INSERT ON Appointments
FOR EACH ROW
BEGIN
    IF :NEW.AppointmentId IS NULL THEN
        SELECT appointments_seq.NEXTVAL INTO :NEW.AppointmentId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_treatments_bi
BEFORE INSERT ON Treatments
FOR EACH ROW
BEGIN
    IF :NEW.TreatmentId IS NULL THEN
        SELECT treatments_seq.NEXTVAL INTO :NEW.TreatmentId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_bills_bi
BEFORE INSERT ON Bills
FOR EACH ROW
BEGIN
    IF :NEW.BillId IS NULL THEN
        SELECT bills_seq.NEXTVAL INTO :NEW.BillId FROM dual;
    END IF;
END;
/

INSERT INTO Doctors (DoctorId, FullName, Specialization, Phone, Fee) VALUES
    (1, 'Dr. Ahmed Khan', 'Cardiology', '0300-1111111', 3000);
INSERT INTO Doctors (DoctorId, FullName, Specialization, Phone, Fee) VALUES
    (2, 'Dr. Sara Malik', 'Pediatrics', '0301-2222222', 2000);
INSERT INTO Doctors (DoctorId, FullName, Specialization, Phone, Fee) VALUES
    (3, 'Dr. Bilal Hussain', 'Orthopedic', '0302-3333333', 2500);
INSERT INTO Doctors (DoctorId, FullName, Specialization, Phone, Fee) VALUES
    (4, 'Dr. Fatima Noor', 'Gynecology', '0303-4444444', 2500);
INSERT INTO Doctors (DoctorId, FullName, Specialization, Phone, Fee) VALUES
    (5, 'Dr. Usman Raza', 'General Physician', '0304-5555555', 1500);

INSERT INTO Patients (PatientId, FullName, Age, Gender, Phone, Address) VALUES
    (1, 'Ali Raza', 45, 'Male', '0300-1234567', 'House 12 Street 3 Lahore');
INSERT INTO Patients (PatientId, FullName, Age, Gender, Phone, Address) VALUES
    (2, 'Ayesha Khan', 32, 'Female', '0301-2345678', 'House 5 Street 7 Karachi');
INSERT INTO Patients (PatientId, FullName, Age, Gender, Phone, Address) VALUES
    (3, 'Hassan Ali', 28, 'Male', '0302-3456789', 'House 8 Street 2 Islamabad');
INSERT INTO Patients (PatientId, FullName, Age, Gender, Phone, Address) VALUES
    (4, 'Maryam Tariq', 55, 'Female', '0303-4567890', 'House 20 Street 9 Lahore');
INSERT INTO Patients (PatientId, FullName, Age, Gender, Phone, Address) VALUES
    (5, 'Bilal Ahmed', 40, 'Male', '0304-5678901', 'House 3 Street 4 Rawalpindi');
INSERT INTO Patients (PatientId, FullName, Age, Gender, Phone, Address) VALUES
    (6, 'Zainab Noor', 22, 'Female', '0305-6789012', 'House 15 Street 6 Multan');

-- Appointment times are clock times stored as text 'HH:MM'.
INSERT INTO Appointments (AppointmentId, PatientId, DoctorId, AppointmentDate, AppointmentTime, Status) VALUES
    (1, 1, 1, TO_DATE('2026-11-20', 'YYYY-MM-DD'), '10:00', 'Scheduled');
INSERT INTO Appointments (AppointmentId, PatientId, DoctorId, AppointmentDate, AppointmentTime, Status) VALUES
    (2, 2, 2, TO_DATE('2026-11-20', 'YYYY-MM-DD'), '11:00', 'Completed');
INSERT INTO Appointments (AppointmentId, PatientId, DoctorId, AppointmentDate, AppointmentTime, Status) VALUES
    (3, 3, 3, TO_DATE('2026-11-20', 'YYYY-MM-DD'), '12:00', 'Completed');
INSERT INTO Appointments (AppointmentId, PatientId, DoctorId, AppointmentDate, AppointmentTime, Status) VALUES
    (4, 4, 4, TO_DATE('2026-11-21', 'YYYY-MM-DD'), '09:30', 'Scheduled');
INSERT INTO Appointments (AppointmentId, PatientId, DoctorId, AppointmentDate, AppointmentTime, Status) VALUES
    (5, 5, 5, TO_DATE('2026-11-21', 'YYYY-MM-DD'), '10:30', 'Completed');
INSERT INTO Appointments (AppointmentId, PatientId, DoctorId, AppointmentDate, AppointmentTime, Status) VALUES
    (6, 6, 1, TO_DATE('2026-11-21', 'YYYY-MM-DD'), '11:00', 'Cancelled');

INSERT INTO Treatments (TreatmentId, AppointmentId, Diagnosis, Prescription, TreatmentCost) VALUES
    (1, 2, 'Cold', 'Paracetamol', 1200);
INSERT INTO Treatments (TreatmentId, AppointmentId, Diagnosis, Prescription, TreatmentCost) VALUES
    (2, 3, 'Fracture', 'Plaster and painkillers', 5000);
INSERT INTO Treatments (TreatmentId, AppointmentId, Diagnosis, Prescription, TreatmentCost) VALUES
    (3, 5, 'Fever', 'Paracetamol', 800);

-- TotalAmount = doctor fee + treatment cost (where a treatment exists).
-- Bill 1: Dr. Ahmed Khan fee 3000, no treatment = 3000.
-- Bill 2: Dr. Sara Malik fee 2000 + treatment 1200 = 3200.
-- Bill 3: Dr. Bilal Hussain fee 2500 + treatment 5000 = 7500.
-- Bill 4: Dr. Usman Raza fee 1500 + treatment 800 = 2300.
-- Status: Paid if PaidAmount = TotalAmount, Partial if some amount
-- is paid, Unpaid if nothing is paid.
INSERT INTO Bills (BillId, PatientId, AppointmentId, TotalAmount, PaidAmount, BillDate, Status) VALUES
    (1, 1, 1, 3000, 3000, TO_DATE('2026-11-20', 'YYYY-MM-DD'), 'Paid');
INSERT INTO Bills (BillId, PatientId, AppointmentId, TotalAmount, PaidAmount, BillDate, Status) VALUES
    (2, 2, 2, 3200, 2000, TO_DATE('2026-11-20', 'YYYY-MM-DD'), 'Partial');
INSERT INTO Bills (BillId, PatientId, AppointmentId, TotalAmount, PaidAmount, BillDate, Status) VALUES
    (3, 3, 3, 7500, 0, TO_DATE('2026-11-20', 'YYYY-MM-DD'), 'Unpaid');
INSERT INTO Bills (BillId, PatientId, AppointmentId, TotalAmount, PaidAmount, BillDate, Status) VALUES
    (4, 5, 5, 2300, 2300, TO_DATE('2026-11-21', 'YYYY-MM-DD'), 'Paid');

COMMIT;

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
WHERE a.AppointmentDate = TO_DATE('2026-11-20', 'YYYY-MM-DD')
ORDER BY a.AppointmentTime;

-- Query 5: Total collection per doctor (sum of PaidAmount on their bills).
-- Expected result: Dr. Ahmed Khan 3000, Dr. Usman Raza 2300,
-- Dr. Sara Malik 2000, Dr. Bilal Hussain 0, Dr. Fatima Noor 0.
-- Doctors with no paid bills still appear with 0, because of the
-- LEFT JOIN and NVL. (Oracle uses NVL where SQL Server uses ISNULL.)
SELECT
    d.FullName AS Doctor,
    NVL(SUM(b.PaidAmount), 0) AS TotalCollected
FROM Doctors d
LEFT JOIN Appointments a ON a.DoctorId = d.DoctorId
LEFT JOIN Bills b ON b.AppointmentId = a.AppointmentId
GROUP BY d.FullName
ORDER BY TotalCollected DESC;

COMMIT;
