-- school-management-sqlserver.sql
-- School Management System — SQL Server version.
-- Run this script in SQL Server Management Studio (SSMS) or in Visual
-- Studio's SQL Server Object Explorer. It creates the SchoolDB database,
-- 6 tables (Teachers, Classes, Subjects, Students, Exams, Fees), inserts
-- the sample data, and then runs 5 practical SELECT queries.
-- Needs: SQL Server Express, SQL Server Developer, or LocalDB.
-- The matching Oracle version of this script is school-management-oracle.sql.

CREATE DATABASE SchoolDB;
GO

USE SchoolDB;
GO

CREATE TABLE Teachers (
    TeacherId INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    Subject NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Salary DECIMAL(10,2) NOT NULL
);
GO

CREATE TABLE Classes (
    ClassId INT PRIMARY KEY IDENTITY(1,1),
    ClassName NVARCHAR(50) NOT NULL,
    Section NVARCHAR(10),
    TeacherId INT FOREIGN KEY REFERENCES Teachers(TeacherId)
);
GO

CREATE TABLE Subjects (
    SubjectId INT PRIMARY KEY IDENTITY(1,1),
    SubjectName NVARCHAR(100) NOT NULL,
    ClassId INT FOREIGN KEY REFERENCES Classes(ClassId),
    TeacherId INT FOREIGN KEY REFERENCES Teachers(TeacherId)
);
GO

CREATE TABLE Students (
    StudentId INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    ClassId INT FOREIGN KEY REFERENCES Classes(ClassId),
    RollNo NVARCHAR(20) NOT NULL,
    DateOfBirth DATE,
    Phone NVARCHAR(20),
    GuardianName NVARCHAR(100)
);
GO

CREATE TABLE Exams (
    ExamId INT PRIMARY KEY IDENTITY(1,1),
    StudentId INT FOREIGN KEY REFERENCES Students(StudentId),
    SubjectId INT FOREIGN KEY REFERENCES Subjects(SubjectId),
    MarksObtained INT NOT NULL,
    TotalMarks INT NOT NULL,
    ExamDate DATE NOT NULL
);
GO

CREATE TABLE Fees (
    FeeId INT PRIMARY KEY IDENTITY(1,1),
    StudentId INT FOREIGN KEY REFERENCES Students(StudentId),
    Month NVARCHAR(20) NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaidDate DATE,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Unpaid'
);
GO

INSERT INTO Teachers (FullName, Subject, Phone, Salary) VALUES
    ('Mr. Ahmed Raza', 'Mathematics', '0300-1111111', 60000),
    ('Ms. Fatima Khan', 'English', '0301-2222222', 55000),
    ('Mr. Bilal Ahmed', 'Science', '0302-3333333', 58000),
    ('Ms. Ayesha Malik', 'Urdu', '0303-4444444', 52000);
GO

INSERT INTO Classes (ClassName, Section, TeacherId) VALUES
    ('Class 9', 'A', 1),
    ('Class 10', 'B', 2),
    ('Class 8', 'C', 3);
GO

INSERT INTO Subjects (SubjectName, ClassId, TeacherId) VALUES
    ('Mathematics', 1, 1),
    ('English', 2, 2),
    ('Science', 3, 3),
    ('Urdu', 1, 4);
GO

INSERT INTO Students (FullName, ClassId, RollNo, DateOfBirth, Phone, GuardianName) VALUES
    ('Ali Khan', 1, '1', '2010-05-12', '0300-1234567', 'Mr. Raza Khan'),
    ('Sara Ahmed', 1, '2', '2010-08-20', '0301-2345678', 'Mr. Ahmed Khan'),
    ('Usman Malik', 2, '1', '2009-03-15', '0302-3456789', 'Mr. Malik Hussain'),
    ('Fatima Noor', 2, '2', '2009-11-25', '0303-4567890', 'Mr. Noor Ahmed'),
    ('Hassan Raza', 3, '1', '2011-01-30', '0304-5678901', 'Mr. Raza Ali'),
    ('Maryam Tariq', 3, '2', '2011-06-18', '0305-6789012', 'Mr. Tariq Aziz');
GO

-- All exams were held on 2026-11-10 and are out of 100 marks.
-- Class 9: Ali Khan 85, Sara Ahmed 92 — class average (85 + 92) / 2 = 88.5.
INSERT INTO Exams (StudentId, SubjectId, MarksObtained, TotalMarks, ExamDate) VALUES
    (1, 1, 85, 100, '2026-11-10'),
    (2, 1, 92, 100, '2026-11-10'),
    (3, 2, 78, 100, '2026-11-10'),
    (4, 2, 88, 100, '2026-11-10'),
    (5, 3, 70, 100, '2026-11-10'),
    (6, 3, 95, 100, '2026-11-10');
GO

-- November 2026 fees are 5000 per student. 3 students have paid and
-- 3 have not: collected = 3 x 5000 = 15000, pending = 3 x 5000 = 15000.
INSERT INTO Fees (StudentId, Month, Amount, PaidDate, Status) VALUES
    (1, 'November 2026', 5000, '2026-11-05', 'Paid'),
    (2, 'November 2026', 5000, NULL, 'Unpaid'),
    (3, 'November 2026', 5000, '2026-11-06', 'Paid'),
    (4, 'November 2026', 5000, NULL, 'Unpaid'),
    (5, 'November 2026', 5000, '2026-11-08', 'Paid'),
    (6, 'November 2026', 5000, NULL, 'Unpaid');
GO

-- Query 1: Class result — average marks per student in Class 9.
-- Expected result: Ali Khan 85, Sara Ahmed 92; class average 88.5.
SELECT
    s.FullName AS Student,
    AVG(CAST(e.MarksObtained AS DECIMAL(5,2))) AS AverageMarks
FROM Students s
INNER JOIN Exams e ON e.StudentId = s.StudentId
WHERE s.ClassId = 1
GROUP BY s.FullName
ORDER BY s.FullName;
GO

-- Query 2: Fee defaulters — students whose fee Status is Unpaid.
-- Expected result: 3 rows — Sara Ahmed, Fatima Noor, Maryam Tariq.
SELECT
    s.FullName AS Student,
    c.ClassName,
    f.Month,
    f.Amount
FROM Fees f
INNER JOIN Students s ON f.StudentId = s.StudentId
INNER JOIN Classes c ON s.ClassId = c.ClassId
WHERE f.Status = 'Unpaid'
ORDER BY s.FullName;
GO

-- Query 3: Students by class — all students of Class 9.
-- Expected result: 2 rows — Ali Khan (Roll No 1), Sara Ahmed (Roll No 2).
SELECT
    s.FullName AS Student,
    s.RollNo,
    c.ClassName,
    c.Section
FROM Students s
INNER JOIN Classes c ON s.ClassId = c.ClassId
WHERE c.ClassName = 'Class 9'
ORDER BY s.RollNo;
GO

-- Query 4: Topper per class — the highest marks in each class.
-- Expected result: Class 9 — Sara Ahmed 92; Class 10 — Fatima Noor 88;
-- Class 8 — Maryam Tariq 95.
SELECT
    c.ClassName,
    s.FullName AS Topper,
    e.MarksObtained AS HighestMarks
FROM Exams e
INNER JOIN Students s ON e.StudentId = s.StudentId
INNER JOIN Classes c ON s.ClassId = c.ClassId
WHERE e.MarksObtained = (
    SELECT MAX(e2.MarksObtained)
    FROM Exams e2
    INNER JOIN Students s2 ON e2.StudentId = s2.StudentId
    WHERE s2.ClassId = s.ClassId
)
ORDER BY c.ClassName;
GO

-- Query 5: Monthly fee collection for November 2026.
-- Expected result: 15000 collected (3 Paid x 5000), 15000 pending (3 Unpaid x 5000).
SELECT
    Month,
    SUM(CASE WHEN Status = 'Paid' THEN Amount ELSE 0 END) AS Collected,
    SUM(CASE WHEN Status = 'Unpaid' THEN Amount ELSE 0 END) AS Pending
FROM Fees
WHERE Month = 'November 2026'
GROUP BY Month;
GO
