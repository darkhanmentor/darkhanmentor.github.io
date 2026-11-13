-- ============================================================
-- Oracle Employee Database
-- An HR-style employee database built from scratch in Oracle SQL
-- Run the whole file in SQL Developer or SQL*Plus, then COMMIT.
-- ============================================================

-- Step 1: Create the Departments table
CREATE TABLE Departments (
    department_id   NUMBER PRIMARY KEY,
    department_name VARCHAR2(50) NOT NULL UNIQUE,
    location        VARCHAR2(100)
);

-- Step 2: Create the Employees table
CREATE TABLE Employees (
    employee_id   NUMBER PRIMARY KEY,
    first_name    VARCHAR2(50) NOT NULL,
    last_name     VARCHAR2(50) NOT NULL,
    email         VARCHAR2(100) NOT NULL UNIQUE,
    department_id NUMBER,
    salary        NUMBER(10,2),
    hire_date     DATE,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

-- Step 3: Sequences for automatic IDs
-- NOTE: The sample rows below use explicit IDs 1-8 so you can see
-- exactly which row is which. These sequences are ready for your
-- NEXT rows. Because they start at 1, set them past the sample IDs
-- (for example, recreate emp_seq with START WITH 9) before you use
-- emp_seq.NEXTVAL for a new employee, or you will get a duplicate
-- primary key error.
CREATE SEQUENCE dept_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE emp_seq START WITH 1 INCREMENT BY 1;

-- Step 4: Insert sample departments
-- Location is left empty (NULL) here; add it later with UPDATE.
INSERT INTO Departments (department_id, department_name) VALUES (1, 'HR');
INSERT INTO Departments (department_id, department_name) VALUES (2, 'IT');
INSERT INTO Departments (department_id, department_name) VALUES (3, 'Sales');
INSERT INTO Departments (department_id, department_name) VALUES (4, 'Finance');

-- Step 4: Insert sample employees (explicit IDs 1-8)
INSERT INTO Employees (employee_id, first_name, last_name, email, department_id, salary, hire_date)
VALUES (1, 'Ali', 'Khan', 'ali.khan@company.com', 2, 85000, TO_DATE('15-MAR-2022', 'DD-MON-YYYY'));
INSERT INTO Employees (employee_id, first_name, last_name, email, department_id, salary, hire_date)
VALUES (2, 'Sara', 'Ahmed', 'sara.ahmed@company.com', 1, 72000, TO_DATE('01-JUN-2021', 'DD-MON-YYYY'));
INSERT INTO Employees (employee_id, first_name, last_name, email, department_id, salary, hire_date)
VALUES (3, 'Usman', 'Malik', 'usman.malik@company.com', 2, 92000, TO_DATE('20-NOV-2020', 'DD-MON-YYYY'));
INSERT INTO Employees (employee_id, first_name, last_name, email, department_id, salary, hire_date)
VALUES (4, 'Fatima', 'Noor', 'fatima.noor@company.com', 3, 68000, TO_DATE('10-JAN-2023', 'DD-MON-YYYY'));
INSERT INTO Employees (employee_id, first_name, last_name, email, department_id, salary, hire_date)
VALUES (5, 'Hassan', 'Raza', 'hassan.raza@company.com', 3, 71000, TO_DATE('05-AUG-2022', 'DD-MON-YYYY'));
INSERT INTO Employees (employee_id, first_name, last_name, email, department_id, salary, hire_date)
VALUES (6, 'Ayesha', 'Siddiqui', 'ayesha.siddiqui@company.com', 4, 88000, TO_DATE('12-APR-2019', 'DD-MON-YYYY'));
INSERT INTO Employees (employee_id, first_name, last_name, email, department_id, salary, hire_date)
VALUES (7, 'Bilal', 'Hussain', 'bilal.hussain@company.com', 2, 79000, TO_DATE('22-MAY-2023', 'DD-MON-YYYY'));
INSERT INTO Employees (employee_id, first_name, last_name, email, department_id, salary, hire_date)
VALUES (8, 'Maryam', 'Tariq', 'maryam.tariq@company.com', 1, 65000, TO_DATE('01-FEB-2024', 'DD-MON-YYYY'));

-- Save all the inserts above
COMMIT;

-- Step 5: Query 1 - All employees
SELECT employee_id, first_name, last_name, email, department_id, salary, hire_date
FROM Employees;

-- Step 5: Query 2 - Employees with their department names
SELECT e.first_name, e.last_name, d.department_name, e.salary
FROM Employees e
INNER JOIN Departments d ON e.department_id = d.department_id;

-- Step 5: Query 3 - Employees earning more than 75000
SELECT first_name, last_name, salary
FROM Employees
WHERE salary > 75000
ORDER BY salary DESC;

-- Step 5: Query 4 - Count employees per department
SELECT d.department_name, COUNT(e.employee_id) AS employee_count
FROM Departments d
LEFT JOIN Employees e ON d.department_id = e.department_id
GROUP BY d.department_name;

-- Step 5: Query 5 - Employees hired after 01-JAN-2022
SELECT first_name, last_name, hire_date
FROM Employees
WHERE hire_date > TO_DATE('01-JAN-2022', 'DD-MON-YYYY');
