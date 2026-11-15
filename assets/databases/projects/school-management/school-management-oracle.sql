-- school-management-oracle.sql
-- School Management System — Oracle version.
-- Run this script in Oracle SQL Developer (open the file and press F5,
-- Run Script) or in SQL*Plus (@school-management-oracle.sql).
-- Oracle has no CREATE DATABASE statement like SQL Server: the tables are
-- created in the schema (user) you are connected as. If you want a
-- separate user for this project, create one first in SQL Developer or
-- SQL*Plus, for example:
--   CREATE USER school_user IDENTIFIED BY your_password;
--   GRANT CONNECT, RESOURCE TO school_user;
-- and then connect as school_user and run this script.
-- Needs: Oracle Database XE (free) or any Oracle Database 19c or later.
-- The matching SQL Server version of this script is
-- school-management-sqlserver.sql.

CREATE TABLE Teachers (
    TeacherId NUMBER(10) PRIMARY KEY,
    FullName VARCHAR2(100) NOT NULL,
    Subject VARCHAR2(100) NOT NULL,
    Phone VARCHAR2(20),
    Salary NUMBER(10,2) NOT NULL
);

CREATE TABLE Classes (
    ClassId NUMBER(10) PRIMARY KEY,
    ClassName VARCHAR2(50) NOT NULL,
    Section VARCHAR2(10),
    TeacherId NUMBER(10) REFERENCES Teachers(TeacherId)
);

CREATE TABLE Subjects (
    SubjectId NUMBER(10) PRIMARY KEY,
    SubjectName VARCHAR2(100) NOT NULL,
    ClassId NUMBER(10) REFERENCES Classes(ClassId),
    TeacherId NUMBER(10) REFERENCES Teachers(TeacherId)
);

CREATE TABLE Students (
    StudentId NUMBER(10) PRIMARY KEY,
    FullName VARCHAR2(100) NOT NULL,
    ClassId NUMBER(10) REFERENCES Classes(ClassId),
    RollNo VARCHAR2(20) NOT NULL,
    DateOfBirth DATE,
    Phone VARCHAR2(20),
    GuardianName VARCHAR2(100)
);

CREATE TABLE Exams (
    ExamId NUMBER(10) PRIMARY KEY,
    StudentId NUMBER(10) REFERENCES Students(StudentId),
    SubjectId NUMBER(10) REFERENCES Subjects(SubjectId),
    MarksObtained NUMBER(10) NOT NULL,
    TotalMarks NUMBER(10) NOT NULL,
    ExamDate DATE NOT NULL
);

CREATE TABLE Fees (
    FeeId NUMBER(10) PRIMARY KEY,
    StudentId NUMBER(10) REFERENCES Students(StudentId),
    Month VARCHAR2(20) NOT NULL,
    Amount NUMBER(10,2) NOT NULL,
    PaidDate DATE,
    Status VARCHAR2(20) DEFAULT 'Unpaid' NOT NULL
);

-- Sequences for auto-increment IDs. Oracle has no IDENTITY like SQL Server,
-- so a sequence plus a trigger fills in the ID when a row is inserted
-- without one. Each sequence starts AFTER the highest sample ID below
-- (Teachers has 4 sample rows, so its sequence starts at 5; Classes has
-- 3 rows, so it starts at 4; Subjects has 4 rows, so it starts at 5;
-- Students, Exams and Fees each have 6 rows, so they start at 7).
CREATE SEQUENCE teachers_seq START WITH 5 INCREMENT BY 1;
CREATE SEQUENCE classes_seq START WITH 4 INCREMENT BY 1;
CREATE SEQUENCE subjects_seq START WITH 5 INCREMENT BY 1;
CREATE SEQUENCE students_seq START WITH 7 INCREMENT BY 1;
CREATE SEQUENCE exams_seq START WITH 7 INCREMENT BY 1;
CREATE SEQUENCE fees_seq START WITH 7 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_teachers_bi
BEFORE INSERT ON Teachers
FOR EACH ROW
BEGIN
    IF :NEW.TeacherId IS NULL THEN
        SELECT teachers_seq.NEXTVAL INTO :NEW.TeacherId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_classes_bi
BEFORE INSERT ON Classes
FOR EACH ROW
BEGIN
    IF :NEW.ClassId IS NULL THEN
        SELECT classes_seq.NEXTVAL INTO :NEW.ClassId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_subjects_bi
BEFORE INSERT ON Subjects
FOR EACH ROW
BEGIN
    IF :NEW.SubjectId IS NULL THEN
        SELECT subjects_seq.NEXTVAL INTO :NEW.SubjectId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_students_bi
BEFORE INSERT ON Students
FOR EACH ROW
BEGIN
    IF :NEW.StudentId IS NULL THEN
        SELECT students_seq.NEXTVAL INTO :NEW.StudentId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_exams_bi
BEFORE INSERT ON Exams
FOR EACH ROW
BEGIN
    IF :NEW.ExamId IS NULL THEN
        SELECT exams_seq.NEXTVAL INTO :NEW.ExamId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_fees_bi
BEFORE INSERT ON Fees
FOR EACH ROW
BEGIN
    IF :NEW.FeeId IS NULL THEN
        SELECT fees_seq.NEXTVAL INTO :NEW.FeeId FROM dual;
    END IF;
END;
/

INSERT INTO Teachers (TeacherId, FullName, Subject, Phone, Salary) VALUES
    (1, 'Mr. Ahmed Raza', 'Mathematics', '0300-1111111', 60000);
INSERT INTO Teachers (TeacherId, FullName, Subject, Phone, Salary) VALUES
    (2, 'Ms. Fatima Khan', 'English', '0301-2222222', 55000);
INSERT INTO Teachers (TeacherId, FullName, Subject, Phone, Salary) VALUES
    (3, 'Mr. Bilal Ahmed', 'Science', '0302-3333333', 58000);
INSERT INTO Teachers (TeacherId, FullName, Subject, Phone, Salary) VALUES
    (4, 'Ms. Ayesha Malik', 'Urdu', '0303-4444444', 52000);

INSERT INTO Classes (ClassId, ClassName, Section, TeacherId) VALUES
    (1, 'Class 9', 'A', 1);
INSERT INTO Classes (ClassId, ClassName, Section, TeacherId) VALUES
    (2, 'Class 10', 'B', 2);
INSERT INTO Classes (ClassId, ClassName, Section, TeacherId) VALUES
    (3, 'Class 8', 'C', 3);

INSERT INTO Subjects (SubjectId, SubjectName, ClassId, TeacherId) VALUES
    (1, 'Mathematics', 1, 1);
INSERT INTO Subjects (SubjectId, SubjectName, ClassId, TeacherId) VALUES
    (2, 'English', 2, 2);
INSERT INTO Subjects (SubjectId, SubjectName, ClassId, TeacherId) VALUES
    (3, 'Science', 3, 3);
INSERT INTO Subjects (SubjectId, SubjectName, ClassId, TeacherId) VALUES
    (4, 'Urdu', 1, 4);

INSERT INTO Students (StudentId, FullName, ClassId, RollNo, DateOfBirth, Phone, GuardianName) VALUES
    (1, 'Ali Khan', 1, '1', TO_DATE('2010-05-12', 'YYYY-MM-DD'), '0300-1234567', 'Mr. Raza Khan');
INSERT INTO Students (StudentId, FullName, ClassId, RollNo, DateOfBirth, Phone, GuardianName) VALUES
    (2, 'Sara Ahmed', 1, '2', TO_DATE('2010-08-20', 'YYYY-MM-DD'), '0301-2345678', 'Mr. Ahmed Khan');
INSERT INTO Students (StudentId, FullName, ClassId, RollNo, DateOfBirth, Phone, GuardianName) VALUES
    (3, 'Usman Malik', 2, '1', TO_DATE('2009-03-15', 'YYYY-MM-DD'), '0302-3456789', 'Mr. Malik Hussain');
INSERT INTO Students (StudentId, FullName, ClassId, RollNo, DateOfBirth, Phone, GuardianName) VALUES
    (4, 'Fatima Noor', 2, '2', TO_DATE('2009-11-25', 'YYYY-MM-DD'), '0303-4567890', 'Mr. Noor Ahmed');
INSERT INTO Students (StudentId, FullName, ClassId, RollNo, DateOfBirth, Phone, GuardianName) VALUES
    (5, 'Hassan Raza', 3, '1', TO_DATE('2011-01-30', 'YYYY-MM-DD'), '0304-5678901', 'Mr. Raza Ali');
INSERT INTO Students (StudentId, FullName, ClassId, RollNo, DateOfBirth, Phone, GuardianName) VALUES
    (6, 'Maryam Tariq', 3, '2', TO_DATE('2011-06-18', 'YYYY-MM-DD'), '0305-6789012', 'Mr. Tariq Aziz');

-- All exams were held on 2026-11-10 and are out of 100 marks.
-- Class 9: Ali Khan 85, Sara Ahmed 92 — class average (85 + 92) / 2 = 88.5.
INSERT INTO Exams (ExamId, StudentId, SubjectId, MarksObtained, TotalMarks, ExamDate) VALUES
    (1, 1, 1, 85, 100, TO_DATE('2026-11-10', 'YYYY-MM-DD'));
INSERT INTO Exams (ExamId, StudentId, SubjectId, MarksObtained, TotalMarks, ExamDate) VALUES
    (2, 2, 1, 92, 100, TO_DATE('2026-11-10', 'YYYY-MM-DD'));
INSERT INTO Exams (ExamId, StudentId, SubjectId, MarksObtained, TotalMarks, ExamDate) VALUES
    (3, 3, 2, 78, 100, TO_DATE('2026-11-10', 'YYYY-MM-DD'));
INSERT INTO Exams (ExamId, StudentId, SubjectId, MarksObtained, TotalMarks, ExamDate) VALUES
    (4, 4, 2, 88, 100, TO_DATE('2026-11-10', 'YYYY-MM-DD'));
INSERT INTO Exams (ExamId, StudentId, SubjectId, MarksObtained, TotalMarks, ExamDate) VALUES
    (5, 5, 3, 70, 100, TO_DATE('2026-11-10', 'YYYY-MM-DD'));
INSERT INTO Exams (ExamId, StudentId, SubjectId, MarksObtained, TotalMarks, ExamDate) VALUES
    (6, 6, 3, 95, 100, TO_DATE('2026-11-10', 'YYYY-MM-DD'));

-- November 2026 fees are 5000 per student. 3 students have paid and
-- 3 have not: collected = 3 x 5000 = 15000, pending = 3 x 5000 = 15000.
INSERT INTO Fees (FeeId, StudentId, Month, Amount, PaidDate, Status) VALUES
    (1, 1, 'November 2026', 5000, TO_DATE('2026-11-05', 'YYYY-MM-DD'), 'Paid');
INSERT INTO Fees (FeeId, StudentId, Month, Amount, PaidDate, Status) VALUES
    (2, 2, 'November 2026', 5000, NULL, 'Unpaid');
INSERT INTO Fees (FeeId, StudentId, Month, Amount, PaidDate, Status) VALUES
    (3, 3, 'November 2026', 5000, TO_DATE('2026-11-06', 'YYYY-MM-DD'), 'Paid');
INSERT INTO Fees (FeeId, StudentId, Month, Amount, PaidDate, Status) VALUES
    (4, 4, 'November 2026', 5000, NULL, 'Unpaid');
INSERT INTO Fees (FeeId, StudentId, Month, Amount, PaidDate, Status) VALUES
    (5, 5, 'November 2026', 5000, TO_DATE('2026-11-08', 'YYYY-MM-DD'), 'Paid');
INSERT INTO Fees (FeeId, StudentId, Month, Amount, PaidDate, Status) VALUES
    (6, 6, 'November 2026', 5000, NULL, 'Unpaid');

COMMIT;

-- Query 1: Class result — average marks per student in Class 9.
-- Expected result: Ali Khan 85, Sara Ahmed 92; class average 88.5.
SELECT
    s.FullName AS Student,
    AVG(CAST(e.MarksObtained AS NUMBER(5,2))) AS AverageMarks
FROM Students s
INNER JOIN Exams e ON e.StudentId = s.StudentId
WHERE s.ClassId = 1
GROUP BY s.FullName
ORDER BY s.FullName;

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

-- Query 5: Monthly fee collection for November 2026.
-- Expected result: 15000 collected (3 Paid x 5000), 15000 pending (3 Unpaid x 5000).
-- (Oracle uses NVL where SQL Server uses ISNULL; this query needs neither,
-- because CASE ... ELSE 0 already turns missing values into 0.)
SELECT
    Month,
    SUM(CASE WHEN Status = 'Paid' THEN Amount ELSE 0 END) AS Collected,
    SUM(CASE WHEN Status = 'Unpaid' THEN Amount ELSE 0 END) AS Pending
FROM Fees
WHERE Month = 'November 2026'
GROUP BY Month;

COMMIT;
