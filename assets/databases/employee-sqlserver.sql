-- employee-sqlserver.sql
-- Matching script for "Visual Studio and C# Database: Create a Database,
-- Connect and Read Employee Data" (Sir Database).
-- Run this in SQL Server Management Studio (SSMS) or in Visual Studio's
-- SQL Server Object Explorer. It creates the CompanyDB database,
-- the Departments and Employees tables, inserts the sample data,
-- and then runs four sample SELECT queries.

CREATE DATABASE CompanyDB;
GO

USE CompanyDB;
GO

CREATE TABLE Departments (
    DepartmentId INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(50) NOT NULL UNIQUE,
    Location NVARCHAR(100)
);
GO

CREATE TABLE Employees (
    EmployeeId INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    DepartmentId INT FOREIGN KEY REFERENCES Departments(DepartmentId),
    Salary DECIMAL(10,2),
    HireDate DATE
);
GO

INSERT INTO Departments (DepartmentName) VALUES
    ('HR'),
    ('IT'),
    ('Sales'),
    ('Finance');
GO

INSERT INTO Employees (FirstName, LastName, Email, DepartmentId, Salary, HireDate) VALUES
    ('Ali', 'Khan', 'ali.khan@company.com', 2, 85000, '2022-03-15'),
    ('Sara', 'Ahmed', 'sara.ahmed@company.com', 1, 72000, '2021-06-01'),
    ('Usman', 'Malik', 'usman.malik@company.com', 2, 92000, '2020-11-20'),
    ('Fatima', 'Noor', 'fatima.noor@company.com', 3, 68000, '2023-01-10'),
    ('Hassan', 'Raza', 'hassan.raza@company.com', 3, 71000, '2022-08-05'),
    ('Ayesha', 'Siddiqui', 'ayesha.siddiqui@company.com', 4, 88000, '2019-04-12'),
    ('Bilal', 'Hussain', 'bilal.hussain@company.com', 2, 79000, '2023-05-22'),
    ('Maryam', 'Tariq', 'maryam.tariq@company.com', 1, 65000, '2024-02-01');
GO

-- Sample query 1: all employees
SELECT * FROM Employees;
GO

-- Sample query 2: employees with their department names
SELECT
    e.EmployeeId,
    e.FirstName,
    e.LastName,
    e.Email,
    d.DepartmentName,
    e.Salary,
    e.HireDate
FROM Employees e
INNER JOIN Departments d ON e.DepartmentId = d.DepartmentId
ORDER BY e.EmployeeId;
GO

-- Sample query 3: employees with a salary above 75000
SELECT FirstName, LastName, Email, Salary
FROM Employees
WHERE Salary > 75000
ORDER BY Salary DESC;
GO

-- Sample query 4: how many employees are in each department
SELECT
    d.DepartmentName,
    COUNT(e.EmployeeId) AS EmployeeCount
FROM Departments d
LEFT JOIN Employees e ON e.DepartmentId = d.DepartmentId
GROUP BY d.DepartmentName
ORDER BY d.DepartmentName;
GO
