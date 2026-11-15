-- medical-store-management-oracle.sql
-- Medical Store Management System — Oracle version.
-- Run this script in Oracle SQL Developer (open the file and press F5,
-- Run Script) or in SQL*Plus (@medical-store-management-oracle.sql).
-- Oracle has no CREATE DATABASE statement like SQL Server: the tables are
-- created in the schema (user) you are connected as. If you want a
-- separate user for this project, create one first in SQL Developer or
-- SQL*Plus, for example:
--   CREATE USER medicalstore_user IDENTIFIED BY your_password;
--   GRANT CONNECT, RESOURCE TO medicalstore_user;
-- and then connect as medicalstore_user and run this script.
-- Needs: Oracle Database XE (free) or any Oracle Database 19c or later.
-- The matching SQL Server version of this script is
-- medical-store-management-sqlserver.sql.

CREATE TABLE Medicines (
    MedicineId NUMBER(10) PRIMARY KEY,
    MedicineName VARCHAR2(100) NOT NULL,
    Category VARCHAR2(100) NOT NULL,
    Manufacturer VARCHAR2(100) NOT NULL,
    UnitPrice NUMBER(10,2) NOT NULL,
    StockQuantity NUMBER(10) NOT NULL,
    ExpiryDate DATE NOT NULL,
    ReorderLevel NUMBER(10) NOT NULL
);

CREATE TABLE Suppliers (
    SupplierId NUMBER(10) PRIMARY KEY,
    SupplierName VARCHAR2(100) NOT NULL,
    Phone VARCHAR2(20),
    City VARCHAR2(100)
);

CREATE TABLE Customers (
    CustomerId NUMBER(10) PRIMARY KEY,
    FullName VARCHAR2(100) NOT NULL,
    Phone VARCHAR2(20)
);

CREATE TABLE Purchases (
    PurchaseId NUMBER(10) PRIMARY KEY,
    SupplierId NUMBER(10) REFERENCES Suppliers(SupplierId),
    MedicineId NUMBER(10) REFERENCES Medicines(MedicineId),
    Quantity NUMBER(10) NOT NULL,
    PurchasePrice NUMBER(10,2) NOT NULL,
    PurchaseDate DATE NOT NULL
);

CREATE TABLE Sales (
    SaleId NUMBER(10) PRIMARY KEY,
    CustomerId NUMBER(10) REFERENCES Customers(CustomerId),
    MedicineId NUMBER(10) REFERENCES Medicines(MedicineId),
    Quantity NUMBER(10) NOT NULL,
    SalePrice NUMBER(10,2) NOT NULL,
    SaleDate DATE NOT NULL
);

-- Sequences for auto-increment IDs. Oracle has no IDENTITY like SQL Server,
-- so a sequence plus a trigger fills in the ID when a row is inserted
-- without one. Each sequence starts AFTER the highest sample ID below
-- (Medicines has 6 sample rows, so its sequence starts at 7;
-- Suppliers has 3 rows, so it starts at 4; Customers has 4 rows,
-- so it starts at 5; Purchases and Sales have 5 rows each,
-- so they start at 6).
CREATE SEQUENCE medicines_seq START WITH 7 INCREMENT BY 1;
CREATE SEQUENCE suppliers_seq START WITH 4 INCREMENT BY 1;
CREATE SEQUENCE customers_seq START WITH 5 INCREMENT BY 1;
CREATE SEQUENCE purchases_seq START WITH 6 INCREMENT BY 1;
CREATE SEQUENCE sales_seq START WITH 6 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_medicines_bi
BEFORE INSERT ON Medicines
FOR EACH ROW
BEGIN
    IF :NEW.MedicineId IS NULL THEN
        SELECT medicines_seq.NEXTVAL INTO :NEW.MedicineId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_suppliers_bi
BEFORE INSERT ON Suppliers
FOR EACH ROW
BEGIN
    IF :NEW.SupplierId IS NULL THEN
        SELECT suppliers_seq.NEXTVAL INTO :NEW.SupplierId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_customers_bi
BEFORE INSERT ON Customers
FOR EACH ROW
BEGIN
    IF :NEW.CustomerId IS NULL THEN
        SELECT customers_seq.NEXTVAL INTO :NEW.CustomerId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_purchases_bi
BEFORE INSERT ON Purchases
FOR EACH ROW
BEGIN
    IF :NEW.PurchaseId IS NULL THEN
        SELECT purchases_seq.NEXTVAL INTO :NEW.PurchaseId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_sales_bi
BEFORE INSERT ON Sales
FOR EACH ROW
BEGIN
    IF :NEW.SaleId IS NULL THEN
        SELECT sales_seq.NEXTVAL INTO :NEW.SaleId FROM dual;
    END IF;
END;
/

INSERT INTO Medicines (MedicineId, MedicineName, Category, Manufacturer, UnitPrice, StockQuantity, ExpiryDate, ReorderLevel) VALUES
    (1, 'Panadol', 'Tablets', 'GSK', 50, 100, TO_DATE('2027-06-30', 'YYYY-MM-DD'), 50);
INSERT INTO Medicines (MedicineId, MedicineName, Category, Manufacturer, UnitPrice, StockQuantity, ExpiryDate, ReorderLevel) VALUES
    (2, 'Amoxil', 'Capsules', 'Abbott', 350, 20, TO_DATE('2026-12-15', 'YYYY-MM-DD'), 30);
INSERT INTO Medicines (MedicineId, MedicineName, Category, Manufacturer, UnitPrice, StockQuantity, ExpiryDate, ReorderLevel) VALUES
    (3, 'Brufen', 'Tablets', 'Searle', 120, 200, TO_DATE('2027-03-31', 'YYYY-MM-DD'), 40);
INSERT INTO Medicines (MedicineId, MedicineName, Category, Manufacturer, UnitPrice, StockQuantity, ExpiryDate, ReorderLevel) VALUES
    (4, 'Risek', 'Capsules', 'Getz Pharma', 450, 15, TO_DATE('2026-11-30', 'YYYY-MM-DD'), 25);
INSERT INTO Medicines (MedicineId, MedicineName, Category, Manufacturer, UnitPrice, StockQuantity, ExpiryDate, ReorderLevel) VALUES
    (5, 'Strepsils', 'Lozenges', 'Reckitt', 80, 300, TO_DATE('2027-01-31', 'YYYY-MM-DD'), 60);
INSERT INTO Medicines (MedicineId, MedicineName, Category, Manufacturer, UnitPrice, StockQuantity, ExpiryDate, ReorderLevel) VALUES
    (6, 'Augmentin', 'Tablets', 'GSK', 800, 45, TO_DATE('2026-12-31', 'YYYY-MM-DD'), 20);

INSERT INTO Suppliers (SupplierId, SupplierName, Phone, City) VALUES
    (1, 'Pak Pharma Distributors', '0300-1111111', 'Lahore');
INSERT INTO Suppliers (SupplierId, SupplierName, Phone, City) VALUES
    (2, 'MediCare Supplies', '0301-2222222', 'Karachi');
INSERT INTO Suppliers (SupplierId, SupplierName, Phone, City) VALUES
    (3, 'HealthLine Traders', '0302-3333333', 'Islamabad');

INSERT INTO Customers (CustomerId, FullName, Phone) VALUES
    (1, 'Ahmed Raza', '0300-1234567');
INSERT INTO Customers (CustomerId, FullName, Phone) VALUES
    (2, 'Fatima Khan', '0301-2345678');
INSERT INTO Customers (CustomerId, FullName, Phone) VALUES
    (3, 'Bilal Ahmed', '0302-3456789');
INSERT INTO Customers (CustomerId, FullName, Phone) VALUES
    (4, 'Ayesha Malik', '0303-4567890');

-- Purchases: Quantity x PurchasePrice is the cost of each purchase.
-- Purchase 1: 100 x 300 = 30000. Purchase 3: 50 x 400 = 20000.
INSERT INTO Purchases (PurchaseId, SupplierId, MedicineId, Quantity, PurchasePrice, PurchaseDate) VALUES
    (1, 1, 2, 100, 300, TO_DATE('2026-11-01', 'YYYY-MM-DD'));
INSERT INTO Purchases (PurchaseId, SupplierId, MedicineId, Quantity, PurchasePrice, PurchaseDate) VALUES
    (2, 2, 1, 200, 40, TO_DATE('2026-11-05', 'YYYY-MM-DD'));
INSERT INTO Purchases (PurchaseId, SupplierId, MedicineId, Quantity, PurchasePrice, PurchaseDate) VALUES
    (3, 1, 4, 50, 400, TO_DATE('2026-11-08', 'YYYY-MM-DD'));
INSERT INTO Purchases (PurchaseId, SupplierId, MedicineId, Quantity, PurchasePrice, PurchaseDate) VALUES
    (4, 3, 3, 150, 100, TO_DATE('2026-11-10', 'YYYY-MM-DD'));
INSERT INTO Purchases (PurchaseId, SupplierId, MedicineId, Quantity, PurchasePrice, PurchaseDate) VALUES
    (5, 2, 5, 100, 60, TO_DATE('2026-11-12', 'YYYY-MM-DD'));

-- Sales: Quantity x SalePrice is the amount of each sale.
-- Sale 1: 10 x 50 = 500. Sale 2: 5 x 350 = 1750. Sale 4: 2 x 450 = 900.
INSERT INTO Sales (SaleId, CustomerId, MedicineId, Quantity, SalePrice, SaleDate) VALUES
    (1, 1, 1, 10, 50, TO_DATE('2026-11-15', 'YYYY-MM-DD'));
INSERT INTO Sales (SaleId, CustomerId, MedicineId, Quantity, SalePrice, SaleDate) VALUES
    (2, 2, 2, 5, 350, TO_DATE('2026-11-15', 'YYYY-MM-DD'));
INSERT INTO Sales (SaleId, CustomerId, MedicineId, Quantity, SalePrice, SaleDate) VALUES
    (3, 3, 3, 20, 120, TO_DATE('2026-11-14', 'YYYY-MM-DD'));
INSERT INTO Sales (SaleId, CustomerId, MedicineId, Quantity, SalePrice, SaleDate) VALUES
    (4, 4, 4, 2, 450, TO_DATE('2026-11-15', 'YYYY-MM-DD'));
INSERT INTO Sales (SaleId, CustomerId, MedicineId, Quantity, SalePrice, SaleDate) VALUES
    (5, 1, 5, 15, 80, TO_DATE('2026-11-13', 'YYYY-MM-DD'));

COMMIT;

-- Query 1: Low stock medicines — stock at or below the reorder level.
-- Expected result: 2 rows — Amoxil (stock 20, reorder level 30)
-- and Risek (stock 15, reorder level 25).
SELECT
    MedicineId,
    MedicineName,
    Category,
    StockQuantity,
    ReorderLevel
FROM Medicines
WHERE StockQuantity <= ReorderLevel
ORDER BY MedicineName;

-- Query 2: Near-expiry medicines — expiring within 30 days of 2026-11-15,
-- that is, on or before 2026-12-15. In Oracle, adding 30 to a date
-- adds 30 days, so TO_DATE('2026-11-15', 'YYYY-MM-DD') + 30 is 2026-12-15.
-- Expected result: 2 rows — Risek (expiry 2026-11-30) and Amoxil
-- (expiry 2026-12-15). Augmentin expires on 2026-12-31, which is
-- 46 days after 2026-11-15, so it is NOT included.
SELECT
    MedicineId,
    MedicineName,
    Category,
    StockQuantity,
    ExpiryDate
FROM Medicines
WHERE ExpiryDate <= TO_DATE('2026-11-15', 'YYYY-MM-DD') + 30
ORDER BY ExpiryDate;

-- Query 3: Daily sales report for 2026-11-15.
-- Expected result: 3 sales — Panadol 10 x 50 = 500,
-- Amoxil 5 x 350 = 1750, Risek 2 x 450 = 900. Total = 3150.
SELECT
    m.MedicineName,
    SUM(s.Quantity) AS TotalQuantity,
    SUM(s.Quantity * s.SalePrice) AS TotalAmount
FROM Sales s
INNER JOIN Medicines m ON s.MedicineId = m.MedicineId
WHERE s.SaleDate = TO_DATE('2026-11-15', 'YYYY-MM-DD')
GROUP BY m.MedicineName
ORDER BY m.MedicineName;

-- Query 4: Supplier-wise purchases — how much was bought from each supplier.
-- Expected result: Pak Pharma Distributors 50000
-- (purchase 1: 100 x 300 = 30000, purchase 3: 50 x 400 = 20000),
-- MediCare Supplies 14000 (200 x 40 = 8000 and 100 x 60 = 6000),
-- HealthLine Traders 15000 (150 x 100).
SELECT
    sp.SupplierName,
    COUNT(p.PurchaseId) AS TotalPurchases,
    SUM(p.Quantity * p.PurchasePrice) AS TotalPurchaseAmount
FROM Purchases p
INNER JOIN Suppliers sp ON p.SupplierId = sp.SupplierId
GROUP BY sp.SupplierName
ORDER BY TotalPurchaseAmount DESC;

-- Query 5: Profit per medicine — (sale price - latest purchase price)
-- x total quantity sold. The latest purchase price is the price of the
-- most recent purchase of that medicine. Medicines with no sales do not
-- appear (INNER JOIN).
-- Expected result: Panadol (50 - 40) x 10 = 100, Amoxil (350 - 300) x 5 = 250,
-- Brufen (120 - 100) x 20 = 400, Risek (450 - 400) x 2 = 100,
-- Strepsils (80 - 60) x 15 = 300. Augmentin has no sales, so it is excluded.
SELECT
    m.MedicineName,
    SUM(s.Quantity) AS TotalSold,
    SUM((s.SalePrice - p.PurchasePrice) * s.Quantity) AS TotalProfit
FROM Sales s
INNER JOIN Medicines m ON s.MedicineId = m.MedicineId
INNER JOIN Purchases p ON p.MedicineId = s.MedicineId
    AND p.PurchaseDate = (
        SELECT MAX(p2.PurchaseDate)
        FROM Purchases p2
        WHERE p2.MedicineId = s.MedicineId
    )
GROUP BY m.MedicineName
ORDER BY TotalProfit DESC;

COMMIT;
