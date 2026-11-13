-- ============================================
-- employee-sqlite.sql
-- Employee database in SQLite
-- Run with: sqlite3 company.db < employee-sqlite.sql
-- ============================================

-- Turn foreign key checking ON.
-- SQLite checks foreign keys only when this setting is on,
-- so run it before creating or inserting into the tables.
PRAGMA foreign_keys = ON;

-- Departments table
CREATE TABLE IF NOT EXISTS Departments (
    department_id   INTEGER PRIMARY KEY,
    department_name TEXT NOT NULL UNIQUE,
    location        TEXT
);

-- Employees table
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

-- Sample departments
INSERT INTO Departments (department_id, department_name, location) VALUES
(1, 'HR', 'Head Office'),
(2, 'IT', 'Head Office'),
(3, 'Sales', 'Branch Office'),
(4, 'Finance', 'Head Office');

-- Sample employees
INSERT INTO Employees (employee_id, first_name, last_name, email, department_id, salary, hire_date) VALUES
(1, 'Ali', 'Khan', 'ali.khan@company.com', 2, 85000, '2022-03-15'),
(2, 'Sara', 'Ahmed', 'sara.ahmed@company.com', 1, 72000, '2021-06-01'),
(3, 'Usman', 'Malik', 'usman.malik@company.com', 2, 92000, '2020-11-20'),
(4, 'Fatima', 'Noor', 'fatima.noor@company.com', 3, 68000, '2023-01-10'),
(5, 'Hassan', 'Raza', 'hassan.raza@company.com', 3, 71000, '2022-08-05'),
(6, 'Ayesha', 'Siddiqui', 'ayesha.siddiqui@company.com', 4, 88000, '2019-04-12'),
(7, 'Bilal', 'Hussain', 'bilal.hussain@company.com', 2, 79000, '2023-05-22'),
(8, 'Maryam', 'Tariq', 'maryam.tariq@company.com', 1, 65000, '2024-02-01');

-- Query 1: All employees
SELECT * FROM Employees;

-- Query 2: Employees with their department names
SELECT Employees.first_name, Employees.last_name, Departments.department_name
FROM Employees
INNER JOIN Departments
ON Employees.department_id = Departments.department_id;

-- Query 3: Employees earning more than 75000
SELECT first_name, last_name, salary
FROM Employees
WHERE salary > 75000;

-- Query 4: Count employees per department
SELECT Departments.department_name, COUNT(*) AS employee_count
FROM Employees
INNER JOIN Departments
ON Employees.department_id = Departments.department_id
GROUP BY Departments.department_name;

-- Query 5: Employees hired after 2022-01-01
SELECT first_name, last_name, hire_date
FROM Employees
WHERE hire_date > '2022-01-01';
