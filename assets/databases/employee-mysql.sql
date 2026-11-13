-- ============================================
-- employee-mysql.sql
-- MySQL Employee Database — complete runnable script
-- Creates the company_db database, Departments and
-- Employees tables, inserts sample data, and runs
-- five sample SELECT queries.
-- ============================================

CREATE DATABASE IF NOT EXISTS company_db;
USE company_db;

-- Departments table
CREATE TABLE IF NOT EXISTS Departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(50) NOT NULL UNIQUE,
    location VARCHAR(100)
);

-- Employees table
CREATE TABLE IF NOT EXISTS Employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    department_id INT,
    salary DECIMAL(10,2),
    hire_date DATE,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

-- Sample departments
INSERT INTO Departments (department_name, location) VALUES
('HR', 'Head Office'),
('IT', 'Head Office'),
('Sales', 'Branch Office'),
('Finance', 'Head Office');

-- Sample employees
INSERT INTO Employees (first_name, last_name, email, department_id, salary, hire_date) VALUES
('Ali', 'Khan', 'ali.khan@company.com', 2, 85000.00, '2022-03-15'),
('Sara', 'Ahmed', 'sara.ahmed@company.com', 1, 72000.00, '2021-06-01'),
('Usman', 'Malik', 'usman.malik@company.com', 2, 92000.00, '2020-11-20'),
('Fatima', 'Noor', 'fatima.noor@company.com', 3, 68000.00, '2023-01-10'),
('Hassan', 'Raza', 'hassan.raza@company.com', 3, 71000.00, '2022-08-05'),
('Ayesha', 'Siddiqui', 'ayesha.siddiqui@company.com', 4, 88000.00, '2019-04-12'),
('Bilal', 'Hussain', 'bilal.hussain@company.com', 2, 79000.00, '2023-05-22'),
('Maryam', 'Tariq', 'maryam.tariq@company.com', 1, 65000.00, '2024-02-01');

-- Query 1: Show all employees
SELECT * FROM Employees;

-- Query 2: Show employees with their department names
SELECT Employees.first_name, Employees.last_name, Departments.department_name
FROM Employees
INNER JOIN Departments ON Employees.department_id = Departments.department_id;

-- Query 3: Show employees earning more than 75000
SELECT first_name, last_name, salary
FROM Employees
WHERE salary > 75000;

-- Query 4: Count employees in each department
SELECT department_id, COUNT(*) AS total_employees
FROM Employees
GROUP BY department_id;

-- Query 5: Show employees ordered by salary, highest first
SELECT first_name, last_name, salary
FROM Employees
ORDER BY salary DESC;
