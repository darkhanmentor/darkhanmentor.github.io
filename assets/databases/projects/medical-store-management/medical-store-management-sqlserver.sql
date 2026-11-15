-- medical-store-management-sqlserver.sql
-- Medical Store Management System — SQL Server version.
-- Run this script in SQL Server Management Studio (SSMS) or in Visual
-- Studio's SQL Server Object Explorer. It creates the MedicalStoreDB
-- database, 5 tables (Medicines, Suppliers, Customers, Purchases, Sales),
-- inserts the sample data, and then runs 5 practical SELECT queries.
-- Needs: SQL Server Express, SQL Server Developer, or LocalDB.
-- The matching Oracle version of this script is
-- medical-store-management-oracle.sql.

CREATE DATABASE MedicalStoreDB;
GO

USE MedicalStoreDB;
GO

CREATE TABLE Medicines (
    MedicineId INT PRIMARY KEY IDENTITY(1,1),
    MedicineName NVARCHAR(100) NOT NULL,
    Category NVARCHAR(100) NOT NULL,
    Manufacturer NVARCHAR(100) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    StockQuantity INT NOT NULL,
    ExpiryDate DATE NOT NULL,
    ReorderLevel INT NOT NULL
);
GO

CREATE TABLE Suppliers (
    SupplierId INT PRIMARY KEY IDENTITY(1,1),
    SupplierName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    City NVARCHAR(100)
);
GO

CREATE TABLE Customers (
    CustomerId INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20)
);
GO

CREATE TABLE Purchases (
    PurchaseId INT PRIMARY KEY IDENTITY(1,1),
    SupplierId INT FOREIGN KEY REFERENCES Suppliers(SupplierId),
    MedicineId INT FOREIGN KEY REFERENCES Medicines(MedicineId),
    Quantity INT NOT NULL,
    PurchasePrice DECIMAL(10,2) NOT NULL,
    PurchaseDate DATE NOT NULL
);
GO

CREATE TABLE Sales (
    SaleId INT PRIMARY KEY IDENTITY(1,1),
    CustomerId INT FOREIGN KEY REFERENCES Customers(CustomerId),
    MedicineId INT FOREIGN KEY REFERENCES Medicines(MedicineId),
    Quantity INT NOT NULL,
    SalePrice DECIMAL(10,2) NOT NULL,
    SaleDate DATE NOT NULL
);
GO

INSERT INTO Medicines (MedicineName, Category, Manufacturer, UnitPrice, StockQuantity, ExpiryDate, ReorderLevel) VALUES
    ('Panadol', 'Tablets', 'GSK', 50, 100, '2027-06-30', 50),
    ('Amoxil', 'Capsules', 'Abbott', 350, 20, '2026-12-15', 30),
    ('Brufen', 'Tablets', 'Searle', 120, 200, '2027-03-31', 40),
    ('Risek', 'Capsules', 'Getz Pharma', 450, 15, '2026-11-30', 25),
    ('Strepsils', 'Lozenges', 'Reckitt', 80, 300, '2027-01-31', 60),
    ('Augmentin', 'Tablets', 'GSK', 800, 45, '2026-12-31', 20);
GO

INSERT INTO Suppliers (SupplierName, Phone, City) VALUES
    ('Pak Pharma Distributors', '0300-1111111', 'Lahore'),
    ('MediCare Supplies', '0301-2222222', 'Karachi'),
    ('HealthLine Traders', '0302-3333333', 'Islamabad');
GO

INSERT INTO Customers (FullName, Phone) VALUES
    ('Ahmed Raza', '0300-1234567'),
    ('Fatima Khan', '0301-2345678'),
    ('Bilal Ahmed', '0302-3456789'),
    ('Ayesha Malik', '0303-4567890');
GO

-- Purchases: Quantity x PurchasePrice is the cost of each purchase.
-- Purchase 1: 100 x 300 = 30000. Purchase 3: 50 x 400 = 20000.
INSERT INTO Purchases (SupplierId, MedicineId, Quantity, PurchasePrice, PurchaseDate) VALUES
    (1, 2, 100, 300, '2026-11-01'),
    (2, 1, 200, 40, '2026-11-05'),
    (1, 4, 50, 400, '2026-11-08'),
    (3, 3, 150, 100, '2026-11-10'),
    (2, 5, 100, 60, '2026-11-12');
GO

-- Sales: Quantity x SalePrice is the amount of each sale.
-- Sale 1: 10 x 50 = 500. Sale 2: 5 x 350 = 1750. Sale 4: 2 x 450 = 900.
INSERT INTO Sales (CustomerId, MedicineId, Quantity, SalePrice, SaleDate) VALUES
    (1, 1, 10, 50, '2026-11-15'),
    (2, 2, 5, 350, '2026-11-15'),
    (3, 3, 20, 120, '2026-11-14'),
    (4, 4, 2, 450, '2026-11-15'),
    (1, 5, 15, 80, '2026-11-13');
GO

-- Query 1: Low stock medicines — stock at or below the reorder level.
-- The store should order these medicines again.
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
GO

-- Query 2: Near-expiry medicines — expiring within 30 days of 2026-11-15,
-- that is, on or before 2026-12-15. The store should sell or return
-- these medicines first.
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
WHERE ExpiryDate <= DATEADD(day, 30, '2026-11-15')
ORDER BY ExpiryDate;
GO

-- Query 3: Daily sales report for 2026-11-15.
-- Expected result: 3 sales — Panadol 10 x 50 = 500,
-- Amoxil 5 x 350 = 1750, Risek 2 x 450 = 900. Total = 3150.
SELECT
    m.MedicineName,
    SUM(s.Quantity) AS TotalQuantity,
    SUM(s.Quantity * s.SalePrice) AS TotalAmount
FROM Sales s
INNER JOIN Medicines m ON s.MedicineId = m.MedicineId
WHERE s.SaleDate = '2026-11-15'
GROUP BY m.MedicineName
ORDER BY m.MedicineName;
GO

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
GO

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
GO
