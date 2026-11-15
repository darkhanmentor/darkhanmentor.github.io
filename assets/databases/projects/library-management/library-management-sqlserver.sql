-- library-management-sqlserver.sql
-- Library Management System — SQL Server version.
-- Run this script in SQL Server Management Studio (SSMS) or in Visual
-- Studio's SQL Server Object Explorer. It creates the LibraryDB database,
-- 3 tables (Books, Members, Issues), inserts the sample data, and then
-- runs 5 practical SELECT queries.
-- Needs: SQL Server Express, SQL Server Developer, or LocalDB.
-- The matching Oracle version of this script is library-management-oracle.sql.

CREATE DATABASE LibraryDB;
GO

USE LibraryDB;
GO

CREATE TABLE Books (
    BookId INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(200) NOT NULL,
    Author NVARCHAR(100) NOT NULL,
    ISBN NVARCHAR(20) NOT NULL UNIQUE,
    Category NVARCHAR(100),
    TotalCopies INT NOT NULL,
    AvailableCopies INT NOT NULL
);
GO

CREATE TABLE Members (
    MemberId INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    JoinDate DATE NOT NULL
);
GO

CREATE TABLE Issues (
    IssueId INT PRIMARY KEY IDENTITY(1,1),
    BookId INT FOREIGN KEY REFERENCES Books(BookId),
    MemberId INT FOREIGN KEY REFERENCES Members(MemberId),
    IssueDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    ReturnDate DATE NULL,
    Fine DECIMAL(10,2) NOT NULL DEFAULT 0
);
GO

INSERT INTO Books (Title, Author, ISBN, Category, TotalCopies, AvailableCopies) VALUES
    ('Learn C Programming', 'A. Rahman', '978-0001', 'Programming', 5, 3),
    ('Database Systems', 'S. Khan', '978-0002', 'Programming', 4, 2),
    ('English Grammar', 'M. Iqbal', '978-0003', 'Language', 6, 5),
    ('Mathematics Basics', 'R. Ahmed', '978-0004', 'Mathematics', 3, 1),
    ('Physics for Beginners', 'N. Ali', '978-0005', 'Science', 4, 4),
    ('Pakistan Studies', 'F. Hussain', '978-0006', 'Social Studies', 5, 2);
GO

INSERT INTO Members (FullName, Email, Phone, JoinDate) VALUES
    ('Ahmed Raza', 'ahmed.raza@email.com', '0300-1234567', '2026-01-10'),
    ('Fatima Khan', 'fatima.khan@email.com', '0301-2345678', '2026-02-15'),
    ('Bilal Ahmed', 'bilal.ahmed@email.com', '0302-3456789', '2026-03-20'),
    ('Ayesha Malik', 'ayesha.malik@email.com', '0303-4567890', '2026-04-25'),
    ('Usman Ghani', 'usman.ghani@email.com', '0304-5678901', '2026-06-30');
GO

-- Fine is 100 only on Issue 5 (Physics for Beginners, returned 1 day late).
-- Issues 1 and 3 are still out (ReturnDate is NULL); Issue 1 was due
-- 2026-11-10 and Issue 3 was due 2026-11-12, so both are overdue
-- on 2026-11-20. Issue 2 was returned on time (2026-11-18, due 2026-11-19).
INSERT INTO Issues (BookId, MemberId, IssueDate, DueDate, ReturnDate, Fine) VALUES
    (1, 1, '2026-11-01', '2026-11-10', NULL, 0),
    (2, 2, '2026-11-05', '2026-11-19', '2026-11-18', 0),
    (3, 1, '2026-11-08', '2026-11-12', NULL, 0),
    (4, 3, '2026-11-10', '2026-11-24', NULL, 0),
    (5, 4, '2026-11-03', '2026-11-17', '2026-11-18', 100),
    (1, 5, '2026-11-12', '2026-11-26', NULL, 0);
GO

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
WHERE i.DueDate < '2026-11-20' AND i.ReturnDate IS NULL
ORDER BY i.DueDate;
GO

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
GO

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
GO

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
GO

-- Query 5: Total fine collected.
-- Expected result: 100 (only Issue 5 has a fine of 100; all others are 0).
SELECT
    SUM(Fine) AS TotalFineCollected
FROM Issues;
GO
