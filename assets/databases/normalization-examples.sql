-- ============================================
-- normalization-examples.sql
-- Database normalization: before and after
-- 1NF, 2NF, 3NF and BCNF with an employee database
-- Run with: sqlite3 company.db < normalization-examples.sql
-- ============================================

-- Turn foreign key checking ON.
-- SQLite checks foreign keys only when this setting is on,
-- so run it before creating or inserting into the tables.
PRAGMA foreign_keys = ON;

-- ============================================
-- PART 1 — THE PROBLEM: UNNORMALIZED TABLE
-- ============================================
-- One wide table holds everything: employee details,
-- department details, and several phone numbers in a
-- single cell. Notice how 'IT' and 'Head Office' are
-- repeated on three rows, and how phone numbers are
-- squeezed together with commas.

CREATE TABLE IF NOT EXISTS EmployeesUnnormalized (
    employee_id        INTEGER PRIMARY KEY,
    first_name         TEXT NOT NULL,
    last_name          TEXT NOT NULL,
    email              TEXT NOT NULL,
    department_name    TEXT,
    department_location TEXT,
    phone_numbers      TEXT
);

INSERT INTO EmployeesUnnormalized
    (employee_id, first_name, last_name, email, department_name, department_location, phone_numbers) VALUES
(1, 'Ali', 'Khan', 'ali.khan@company.com', 'IT', 'Head Office', '0300-1111111, 0300-2222222'),
(2, 'Sara', 'Ahmed', 'sara.ahmed@company.com', 'HR', 'Head Office', '0301-3333333'),
(3, 'Usman', 'Malik', 'usman.malik@company.com', 'IT', 'Head Office', '0302-4444444, 0302-5555555'),
(4, 'Fatima', 'Noor', 'fatima.noor@company.com', 'Sales', 'Branch Office', '0303-6666666'),
(5, 'Hassan', 'Raza', 'hassan.raza@company.com', 'Sales', 'Branch Office', '0304-7777777, 0304-8888888'),
(6, 'Ayesha', 'Siddiqui', 'ayesha.siddiqui@company.com', 'Finance', 'Head Office', '0305-9999999'),
(7, 'Bilal', 'Hussain', 'bilal.hussain@company.com', 'IT', 'Head Office', '0306-1010101'),
(8, 'Maryam', 'Tariq', 'maryam.tariq@company.com', 'HR', 'Head Office', '0307-1212121, 0307-1313131');

-- ============================================
-- PART 2 — THE FIX: NORMALIZED TABLES
-- ============================================
-- The same data, split into clean tables:
-- Departments, Employees, EmployeePhones,
-- Projects and EmployeeProjects.

-- Departments (3NF fix: department facts live here, once)
CREATE TABLE IF NOT EXISTS Departments (
    department_id   INTEGER PRIMARY KEY,
    department_name TEXT NOT NULL UNIQUE,
    location        TEXT
);

-- Employees (references Departments by id, not by name)
CREATE TABLE IF NOT EXISTS Employees (
    employee_id   INTEGER PRIMARY KEY,
    first_name    TEXT NOT NULL,
    last_name     TEXT NOT NULL,
    email         TEXT NOT NULL UNIQUE,
    department_id INTEGER,
    salary        REAL,
    hire_date     TEXT,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

-- EmployeePhones (1NF fix: one row per phone number)
CREATE TABLE IF NOT EXISTS EmployeePhones (
    phone_id     INTEGER PRIMARY KEY,
    employee_id  INTEGER NOT NULL,
    phone_number TEXT NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- Projects (2NF fix: project facts live here, once)
CREATE TABLE IF NOT EXISTS Projects (
    project_id   INTEGER PRIMARY KEY,
    project_name TEXT NOT NULL UNIQUE
);

-- EmployeeProjects (2NF fix: only hours_worked depends
-- on the whole key employee_id + project_id)
CREATE TABLE IF NOT EXISTS EmployeeProjects (
    employee_id  INTEGER NOT NULL,
    project_id   INTEGER NOT NULL,
    hours_worked INTEGER,
    PRIMARY KEY (employee_id, project_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);

-- Sample departments
INSERT INTO Departments (department_id, department_name, location) VALUES
(1, 'HR', 'Head Office'),
(2, 'IT', 'Head Office'),
(3, 'Sales', 'Branch Office'),
(4, 'Finance', 'Head Office');

-- Sample employees (same 8 employees as the unnormalized table)
INSERT INTO Employees (employee_id, first_name, last_name, email, department_id, salary, hire_date) VALUES
(1, 'Ali', 'Khan', 'ali.khan@company.com', 2, 85000, '2022-03-15'),
(2, 'Sara', 'Ahmed', 'sara.ahmed@company.com', 1, 72000, '2021-06-01'),
(3, 'Usman', 'Malik', 'usman.malik@company.com', 2, 92000, '2020-11-20'),
(4, 'Fatima', 'Noor', 'fatima.noor@company.com', 3, 68000, '2023-01-10'),
(5, 'Hassan', 'Raza', 'hassan.raza@company.com', 3, 71000, '2022-08-05'),
(6, 'Ayesha', 'Siddiqui', 'ayesha.siddiqui@company.com', 4, 88000, '2019-04-12'),
(7, 'Bilal', 'Hussain', 'bilal.hussain@company.com', 2, 79000, '2023-05-22'),
(8, 'Maryam', 'Tariq', 'maryam.tariq@company.com', 1, 65000, '2024-02-01');

-- Sample phone numbers: one row per number (12 rows in total)
INSERT INTO EmployeePhones (phone_id, employee_id, phone_number) VALUES
(1, 1, '0300-1111111'),
(2, 1, '0300-2222222'),
(3, 2, '0301-3333333'),
(4, 3, '0302-4444444'),
(5, 3, '0302-5555555'),
(6, 4, '0303-6666666'),
(7, 5, '0304-7777777'),
(8, 5, '0304-8888888'),
(9, 6, '0305-9999999'),
(10, 7, '0306-1010101'),
(11, 8, '0307-1212121'),
(12, 8, '0307-1313131');

-- Sample projects
INSERT INTO Projects (project_id, project_name) VALUES
(1, 'Website Redesign'),
(2, 'Mobile App'),
(3, 'Sales Report');

-- Which employee works on which project, and for how many hours
INSERT INTO EmployeeProjects (employee_id, project_id, hours_worked) VALUES
(1, 1, 40),
(1, 2, 15),
(2, 3, 12),
(3, 1, 25),
(3, 2, 30),
(4, 3, 20),
(5, 3, 35),
(6, 2, 10),
(7, 1, 20),
(8, 1, 8);

-- ============================================
-- PART 3 — QUERIES THAT SHOW THE IMPROVEMENT
-- ============================================

-- Query 1: Duplication in the unnormalized table.
-- The department name and location are repeated on
-- every employee row: IT appears 3 times, HR 2 times.
SELECT department_name, department_location, COUNT(*) AS repeated_on_rows
FROM EmployeesUnnormalized
GROUP BY department_name, department_location;

-- Query 2: The same data, rebuilt with a JOIN.
-- The normalized tables give the same full view, but
-- each fact is stored only once. GROUP_CONCAT collects
-- each employee's phone numbers into one line.
SELECT Employees.first_name, Employees.last_name,
       Departments.department_name, Departments.location,
       GROUP_CONCAT(EmployeePhones.phone_number, ', ') AS phone_numbers
FROM Employees
INNER JOIN Departments
    ON Employees.department_id = Departments.department_id
LEFT JOIN EmployeePhones
    ON EmployeePhones.employee_id = Employees.employee_id
GROUP BY Employees.employee_id;

-- Query 3: Count employees per department (normalized tables).
-- A department with no employees yet can still exist in
-- the Departments table — impossible in the unnormalized design.
SELECT Departments.department_name, COUNT(Employees.employee_id) AS employee_count
FROM Departments
LEFT JOIN Employees
    ON Employees.department_id = Departments.department_id
GROUP BY Departments.department_name;
