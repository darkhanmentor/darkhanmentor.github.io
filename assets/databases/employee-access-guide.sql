-- ============================================================
-- employee-access-guide.sql
-- MS Access Employee Database — plain-text SQL guide
-- ============================================================
-- IMPORTANT — READ THIS FIRST:
-- This is NOT a Microsoft Access database file (.accdb).
-- A real .accdb file cannot be created by hand; it needs
-- Microsoft Access itself. This file is a plain-text guide
-- containing the exact table designs, field lists, relationship
-- definition and query definitions from the article
-- "MS Access Employee Database: Tables, Relationships,
-- Queries and Forms Step by Step".
-- Use it to build the same database in Access by hand:
-- create the tables in Design View using the field lists
-- below, create the relationship, type in the sample data,
-- then paste each query into Query Design > SQL View.
-- ============================================================

-- ============================================================
-- TABLE 1: Departments
-- ============================================================
-- Field Name     | Access Data Type | Properties
-- ---------------|------------------|----------------------------------
-- DepartmentID   | AutoNumber       | Primary Key
-- DepartmentName | Short Text       | Required = Yes; Indexed = Yes (No Duplicates)
-- Location       | Short Text       | Required = No
--
-- In Access Design View, create this table first, because
-- the Employees table will refer to it (DepartmentID).

-- ============================================================
-- TABLE 2: Employees
-- ============================================================
-- Field Name     | Access Data Type | Properties
-- ---------------|------------------|----------------------------------
-- EmployeeID     | AutoNumber       | Primary Key
-- FirstName      | Short Text       | Required = Yes
-- LastName       | Short Text       | Required = Yes
-- Email          | Short Text       | Required = Yes; Indexed = Yes (No Duplicates)
-- DepartmentID   | Number           | Field Size = Long Integer; Required = Yes
-- Salary         | Currency         | Required = No
-- HireDate       | Date/Time        | Format = Short Date; Required = No
--
-- AutoNumber: Access fills this in automatically (1, 2, 3, ...),
-- so you never type an EmployeeID or DepartmentID yourself.
-- Email is Indexed (No Duplicates) so the same email address
-- cannot be entered for two different employees.

-- ============================================================
-- RELATIONSHIP
-- ============================================================
-- Departments.DepartmentID (One side, Primary Key)
--   |
--   |  One-to-Many
--   |
-- Employees.DepartmentID (Many side, Foreign Key)
--
-- In Access: Database Tools > Relationships > add both tables,
-- drag DepartmentID from Departments onto DepartmentID in
-- Employees, and tick "Enforce Referential Integrity".
-- One department can have many employees, but each employee
-- belongs to only one department. With referential integrity
-- enforced, Access will not let you enter an employee with a
-- DepartmentID that does not exist in the Departments table.

-- ============================================================
-- SAMPLE DATA — Departments
-- ============================================================
-- (DepartmentID, DepartmentName, Location)
-- Location is optional and is not fixed in this guide:
-- type your own office location for each department,
-- or leave it blank.
--   (1, 'HR', ...)
--   (2, 'IT', ...)
--   (3, 'Sales', ...)
--   (4, 'Finance', ...)

-- ============================================================
-- SAMPLE DATA — Employees
-- ============================================================
-- (EmployeeID, FirstName, LastName, Email, DepartmentID, Salary, HireDate)
-- EmployeeID is AutoNumber, so Access fills it in; the numbers
-- below are the values Access will assign in this order.
-- Dates are shown year-month-day here; in Access they display
-- in day-month-year order (Short Date format).
--   (1, 'Ali', 'Khan', 'ali.khan@company.com', 2, 85000, 2022-03-15)
--   (2, 'Sara', 'Ahmed', 'sara.ahmed@company.com', 1, 72000, 2021-06-01)
--   (3, 'Usman', 'Malik', 'usman.malik@company.com', 2, 92000, 2020-11-20)
--   (4, 'Fatima', 'Noor', 'fatima.noor@company.com', 3, 68000, 2023-01-10)
--   (5, 'Hassan', 'Raza', 'hassan.raza@company.com', 3, 71000, 2022-08-05)
--   (6, 'Ayesha', 'Siddiqui', 'ayesha.siddiqui@company.com', 4, 88000, 2019-04-12)
--   (7, 'Bilal', 'Hussain', 'bilal.hussain@company.com', 2, 79000, 2023-05-22)
--   (8, 'Maryam', 'Tariq', 'maryam.tariq@company.com', 1, 65000, 2024-02-01)
--
-- Check your departments: HR = 2 employees (Sara, Maryam),
-- IT = 3 (Ali, Usman, Bilal), Sales = 2 (Fatima, Hassan),
-- Finance = 1 (Ayesha). Total = 8 employees.

-- ============================================================
-- QUERY 1: Employees earning more than 75000
-- (Join Employees to Departments; show name, department, salary)
-- ============================================================
SELECT Employees.FirstName, Employees.LastName, Departments.DepartmentName, Employees.Salary
FROM Employees
INNER JOIN Departments ON Employees.DepartmentID = Departments.DepartmentID
WHERE Employees.Salary > 75000;

-- This query returns 4 employees:
-- Ali Khan (IT, 85000), Usman Malik (IT, 92000),
-- Ayesha Siddiqui (Finance, 88000), Bilal Hussain (IT, 79000).
-- Sara (72000), Fatima (68000), Hassan (71000) and
-- Maryam (65000) are not included, because their salaries
-- are 75000 or less.

-- ============================================================
-- QUERY 2: Count of employees per department
-- (Totals row / GROUP BY with Count)
-- ============================================================
SELECT Departments.DepartmentName, Count(Employees.EmployeeID) AS NumberOfEmployees
FROM Departments
LEFT JOIN Employees ON Departments.DepartmentID = Employees.DepartmentID
GROUP BY Departments.DepartmentName;

-- This query returns one row per department:
-- Finance 1, HR 2, IT 3, Sales 2.
-- LEFT JOIN is used so that a department with no employees
-- yet would still appear in the list, with a count of 0.
