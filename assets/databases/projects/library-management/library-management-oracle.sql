-- library-management-oracle.sql
-- Library Management System — Oracle version.
-- Run this script in Oracle SQL Developer (open the file and press F5,
-- Run Script) or in SQL*Plus (@library-management-oracle.sql).
-- Oracle has no CREATE DATABASE statement like SQL Server: the tables are
-- created in the schema (user) you are connected as. If you want a
-- separate user for this project, create one first in SQL Developer or
-- SQL*Plus, for example:
--   CREATE USER library_user IDENTIFIED BY your_password;
--   GRANT CONNECT, RESOURCE TO library_user;
-- and then connect as library_user and run this script.
-- Needs: Oracle Database XE (free) or any Oracle Database 19c or later.
-- The matching SQL Server version of this script is
-- library-management-sqlserver.sql.

CREATE TABLE Books (
    BookId NUMBER(10) PRIMARY KEY,
    Title VARCHAR2(200) NOT NULL,
    Author VARCHAR2(100) NOT NULL,
    ISBN VARCHAR2(20) NOT NULL UNIQUE,
    Category VARCHAR2(100),
    TotalCopies NUMBER(10) NOT NULL,
    AvailableCopies NUMBER(10) NOT NULL
);

CREATE TABLE Members (
    MemberId NUMBER(10) PRIMARY KEY,
    FullName VARCHAR2(100) NOT NULL,
    Email VARCHAR2(100),
    Phone VARCHAR2(20),
    JoinDate DATE NOT NULL
);

CREATE TABLE Issues (
    IssueId NUMBER(10) PRIMARY KEY,
    BookId NUMBER(10) REFERENCES Books(BookId),
    MemberId NUMBER(10) REFERENCES Members(MemberId),
    IssueDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    ReturnDate DATE NULL,
    Fine NUMBER(10,2) DEFAULT 0 NOT NULL
);

-- Sequences for auto-increment IDs. Oracle has no IDENTITY like SQL Server,
-- so a sequence plus a trigger fills in the ID when a row is inserted
-- without one. Each sequence starts AFTER the highest sample ID below
-- (Books has 6 sample rows, so its sequence starts at 7; Members has
-- 5 rows, so it starts at 6; Issues has 6 rows, so it starts at 7).
CREATE SEQUENCE books_seq START WITH 7 INCREMENT BY 1;
CREATE SEQUENCE members_seq START WITH 6 INCREMENT BY 1;
CREATE SEQUENCE issues_seq START WITH 7 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_books_bi
BEFORE INSERT ON Books
FOR EACH ROW
BEGIN
    IF :NEW.BookId IS NULL THEN
        SELECT books_seq.NEXTVAL INTO :NEW.BookId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_members_bi
BEFORE INSERT ON Members
FOR EACH ROW
BEGIN
    IF :NEW.MemberId IS NULL THEN
        SELECT members_seq.NEXTVAL INTO :NEW.MemberId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_issues_bi
BEFORE INSERT ON Issues
FOR EACH ROW
BEGIN
    IF :NEW.IssueId IS NULL THEN
        SELECT issues_seq.NEXTVAL INTO :NEW.IssueId FROM dual;
    END IF;
END;
/

INSERT INTO Books (BookId, Title, Author, ISBN, Category, TotalCopies, AvailableCopies) VALUES
    (1, 'Learn C Programming', 'A. Rahman', '978-0001', 'Programming', 5, 3);
INSERT INTO Books (BookId, Title, Author, ISBN, Category, TotalCopies, AvailableCopies) VALUES
    (2, 'Database Systems', 'S. Khan', '978-0002', 'Programming', 4, 2);
INSERT INTO Books (BookId, Title, Author, ISBN, Category, TotalCopies, AvailableCopies) VALUES
    (3, 'English Grammar', 'M. Iqbal', '978-0003', 'Language', 6, 5);
INSERT INTO Books (BookId, Title, Author, ISBN, Category, TotalCopies, AvailableCopies) VALUES
    (4, 'Mathematics Basics', 'R. Ahmed', '978-0004', 'Mathematics', 3, 1);
INSERT INTO Books (BookId, Title, Author, ISBN, Category, TotalCopies, AvailableCopies) VALUES
    (5, 'Physics for Beginners', 'N. Ali', '978-0005', 'Science', 4, 4);
INSERT INTO Books (BookId, Title, Author, ISBN, Category, TotalCopies, AvailableCopies) VALUES
    (6, 'Pakistan Studies', 'F. Hussain', '978-0006', 'Social Studies', 5, 2);

INSERT INTO Members (MemberId, FullName, Email, Phone, JoinDate) VALUES
    (1, 'Ahmed Raza', 'ahmed.raza@email.com', '0300-1234567', TO_DATE('2026-01-10', 'YYYY-MM-DD'));
INSERT INTO Members (MemberId, FullName, Email, Phone, JoinDate) VALUES
    (2, 'Fatima Khan', 'fatima.khan@email.com', '0301-2345678', TO_DATE('2026-02-15', 'YYYY-MM-DD'));
INSERT INTO Members (MemberId, FullName, Email, Phone, JoinDate) VALUES
    (3, 'Bilal Ahmed', 'bilal.ahmed@email.com', '0302-3456789', TO_DATE('2026-03-20', 'YYYY-MM-DD'));
INSERT INTO Members (MemberId, FullName, Email, Phone, JoinDate) VALUES
    (4, 'Ayesha Malik', 'ayesha.malik@email.com', '0303-4567890', TO_DATE('2026-04-25', 'YYYY-MM-DD'));
INSERT INTO Members (MemberId, FullName, Email, Phone, JoinDate) VALUES
    (5, 'Usman Ghani', 'usman.ghani@email.com', '0304-5678901', TO_DATE('2026-06-30', 'YYYY-MM-DD'));

-- Fine is 100 only on Issue 5 (Physics for Beginners, returned 1 day late).
-- Issues 1 and 3 are still out (ReturnDate is NULL); Issue 1 was due
-- 2026-11-10 and Issue 3 was due 2026-11-12, so both are overdue
-- on 2026-11-20. Issue 2 was returned on time (2026-11-18, due 2026-11-19).
INSERT INTO Issues (IssueId, BookId, MemberId, IssueDate, DueDate, ReturnDate, Fine) VALUES
    (1, 1, 1, TO_DATE('2026-11-01', 'YYYY-MM-DD'), TO_DATE('2026-11-10', 'YYYY-MM-DD'), NULL, 0);
INSERT INTO Issues (IssueId, BookId, MemberId, IssueDate, DueDate, ReturnDate, Fine) VALUES
    (2, 2, 2, TO_DATE('2026-11-05', 'YYYY-MM-DD'), TO_DATE('2026-11-19', 'YYYY-MM-DD'), TO_DATE('2026-11-18', 'YYYY-MM-DD'), 0);
INSERT INTO Issues (IssueId, BookId, MemberId, IssueDate, DueDate, ReturnDate, Fine) VALUES
    (3, 3, 1, TO_DATE('2026-11-08', 'YYYY-MM-DD'), TO_DATE('2026-11-12', 'YYYY-MM-DD'), NULL, 0);
INSERT INTO Issues (IssueId, BookId, MemberId, IssueDate, DueDate, ReturnDate, Fine) VALUES
    (4, 4, 3, TO_DATE('2026-11-10', 'YYYY-MM-DD'), TO_DATE('2026-11-24', 'YYYY-MM-DD'), NULL, 0);
INSERT INTO Issues (IssueId, BookId, MemberId, IssueDate, DueDate, ReturnDate, Fine) VALUES
    (5, 5, 4, TO_DATE('2026-11-03', 'YYYY-MM-DD'), TO_DATE('2026-11-17', 'YYYY-MM-DD'), TO_DATE('2026-11-18', 'YYYY-MM-DD'), 100);
INSERT INTO Issues (IssueId, BookId, MemberId, IssueDate, DueDate, ReturnDate, Fine) VALUES
    (6, 1, 5, TO_DATE('2026-11-12', 'YYYY-MM-DD'), TO_DATE('2026-11-26', 'YYYY-MM-DD'), NULL, 0);

COMMIT;

-- Query 1: Overdue books — issued, not returned, and past the due date.
-- "Today" for this query is 2026-11-20.
-- Expected result: 2 rows — Issue 1 (Learn C Programming, Ahmed Raza,
-- due 2026-11-10) and Issue 3 (English Grammar, Ahmed Raza, due 2026-11-12).
SELECT
    i.IssueId,
    b.Title,
    m.FullName AS Member,
    i.IssueDate,
    i.DueDate
FROM Issues i
INNER JOIN Books b ON i.BookId = b.BookId
INNER JOIN Members m ON i.MemberId = m.MemberId
WHERE i.DueDate < TO_DATE('2026-11-20', 'YYYY-MM-DD') AND i.ReturnDate IS NULL
ORDER BY i.DueDate;

-- Query 2: Borrowing history of one member (Ahmed Raza, MemberId 1).
-- Expected result: 2 rows — Issue 1 (Learn C Programming, issued
-- 2026-11-01) and Issue 3 (English Grammar, issued 2026-11-08).
SELECT
    m.FullName AS Member,
    b.Title,
    i.IssueDate,
    i.DueDate,
    i.ReturnDate,
    i.Fine
FROM Issues i
INNER JOIN Members m ON i.MemberId = m.MemberId
INNER JOIN Books b ON i.BookId = b.BookId
WHERE i.MemberId = 1
ORDER BY i.IssueDate;

-- Query 3: Available books by category.
-- Expected result: Programming 5 (Learn C Programming 3 + Database
-- Systems 2), Language 5, Mathematics 1, Science 4, Social Studies 2.
SELECT
    Category,
    SUM(AvailableCopies) AS AvailableBooks,
    COUNT(BookId) AS TotalTitles
FROM Books
GROUP BY Category
ORDER BY AvailableBooks DESC;

-- Query 4: Most issued books.
-- Expected result: Learn C Programming issued 2 times (Issues 1 and 6);
-- every other book issued 1 time.
SELECT
    b.Title,
    COUNT(i.IssueId) AS TimesIssued
FROM Books b
LEFT JOIN Issues i ON i.BookId = b.BookId
GROUP BY b.Title
ORDER BY TimesIssued DESC, b.Title;

-- Query 5: Total fine collected.
-- Expected result: 100 (only Issue 5 has a fine of 100; all others are 0).
SELECT
    SUM(Fine) AS TotalFineCollected
FROM Issues;

COMMIT;
