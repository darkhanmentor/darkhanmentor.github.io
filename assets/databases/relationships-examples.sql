-- ============================================
-- relationships-examples.sql
-- Database relationships: one-to-one, one-to-many
-- and many-to-many, with primary keys, foreign
-- keys and JOIN examples (SQLite)
-- Run with: sqlite3 company.db < relationships-examples.sql
-- ============================================

-- Turn foreign key checking ON.
-- SQLite checks foreign keys only when this setting is on,
-- so run it before creating or inserting into the tables.
PRAGMA foreign_keys = ON;

-- Departments table
-- department_id is the primary key.
CREATE TABLE Departments (
    department_id   INTEGER PRIMARY KEY,
    department_name TEXT NOT NULL UNIQUE,
    location        TEXT
);

-- Employees table
-- department_id is a foreign key pointing to
-- Departments(department_id): one department has many employees.
CREATE TABLE Employees (
    employee_id   INTEGER PRIMARY KEY,
    first_name    TEXT NOT NULL,
    last_name     TEXT NOT NULL,
    email         TEXT NOT NULL UNIQUE,
    department_id INTEGER,
    salary        REAL,
    hire_date     TEXT,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

-- EmployeeDetails table (one-to-one with Employees)
-- employee_id is BOTH the primary key of this table
-- AND a foreign key to Employees(employee_id), so each
-- employee can have at most one details row.
CREATE TABLE EmployeeDetails (
    employee_id       INTEGER PRIMARY KEY,
    passport_number   TEXT UNIQUE,
    emergency_contact TEXT,
    blood_group       TEXT,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- Projects table
CREATE TABLE Projects (
    project_id   INTEGER PRIMARY KEY,
    project_name TEXT NOT NULL UNIQUE,
    start_date   TEXT
);

-- EmployeeProjects: junction (linking) table for the
-- many-to-many relationship between Employees and Projects.
-- The composite primary key (employee_id, project_id) means
-- the same employee cannot be added to the same project twice.
-- Both columns are foreign keys.
CREATE TABLE EmployeeProjects (
    employee_id  INTEGER,
    project_id   INTEGER,
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

-- Sample employee details (one-to-one: one row per employee)
INSERT INTO EmployeeDetails (employee_id, passport_number, emergency_contact, blood_group) VALUES
(1, 'AB1234567', 'Father: 0300-1111111', 'O+'),
(2, 'AB2345678', 'Husband: 0300-2222222', 'A+'),
(6, 'AB3456789', 'Brother: 0300-3333333', 'B+');

-- Sample projects
INSERT INTO Projects (project_id, project_name, start_date) VALUES
(1, 'Website Redesign', '2026-01-05'),
(2, 'Payroll System', '2026-02-10'),
(3, 'Mobile App', '2026-03-01');

-- Sample project assignments (many-to-many through the junction table)
-- Ali and Usman work on Website Redesign,
-- Ayesha works on Payroll System,
-- Ali and Bilal work on Mobile App.
INSERT INTO EmployeeProjects (employee_id, project_id, hours_worked) VALUES
(1, 1, 120),
(3, 1, 95),
(6, 2, 140),
(1, 3, 80),
(7, 3, 110);

-- Query 1: One-to-many JOIN — every employee with their department name
SELECT Employees.first_name, Employees.last_name, Departments.department_name
FROM Employees
INNER JOIN Departments
ON Employees.department_id = Departments.department_id
ORDER BY Departments.department_name, Employees.first_name;

-- Query 2: One-to-one JOIN — employees with their private details
SELECT Employees.first_name, Employees.last_name, EmployeeDetails.passport_number, EmployeeDetails.blood_group
FROM Employees
INNER JOIN EmployeeDetails
ON Employees.employee_id = EmployeeDetails.employee_id;

-- Query 3: Many-to-many JOIN — employees with their projects, through the junction table
SELECT Employees.first_name, Employees.last_name, Projects.project_name, EmployeeProjects.hours_worked
FROM Employees
INNER JOIN EmployeeProjects
ON Employees.employee_id = EmployeeProjects.employee_id
INNER JOIN Projects
ON EmployeeProjects.project_id = Projects.project_id
ORDER BY Projects.project_name, Employees.first_name;

-- Query 4: Count employees per department
SELECT Departments.department_name, COUNT(*) AS employee_count
FROM Employees
INNER JOIN Departments
ON Employees.department_id = Departments.department_id
GROUP BY Departments.department_name;
