-- general-store-management-sqlserver.sql
-- General Store Management System — SQL Server version.
-- Run this script in SQL Server Management Studio (SSMS) or in Visual
-- Studio's SQL Server Object Explorer. It creates the GeneralStoreDB
-- database, 6 tables (Categories, Suppliers, Customers, Products,
-- Purchases, Sales), inserts the sample data, and then runs 5 practical
-- SELECT queries.
-- Needs: SQL Server Express, SQL Server Developer, or LocalDB.
-- The matching Oracle version of this script is
-- general-store-management-oracle.sql.

CREATE DATABASE GeneralStoreDB;
GO

USE GeneralStoreDB;
GO

CREATE TABLE Categories (
    CategoryId INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL
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

CREATE TABLE Products (
    ProductId INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    CategoryId INT FOREIGN KEY REFERENCES Categories(CategoryId),
    UnitPrice DECIMAL(10,2) NOT NULL,
    StockQuantity INT NOT NULL,
    ReorderLevel INT NOT NULL
);
GO

CREATE TABLE Purchases (
    PurchaseId INT PRIMARY KEY IDENTITY(1,1),
    SupplierId INT FOREIGN KEY REFERENCES Suppliers(SupplierId),
    ProductId INT FOREIGN KEY REFERENCES Products(ProductId),
    Quantity INT NOT NULL,
    PurchasePrice DECIMAL(10,2) NOT NULL,
    PurchaseDate DATE NOT NULL
);
GO

CREATE TABLE Sales (
    SaleId INT PRIMARY KEY IDENTITY(1,1),
    CustomerId INT FOREIGN KEY REFERENCES Customers(CustomerId),
    ProductId INT FOREIGN KEY REFERENCES Products(ProductId),
    Quantity INT NOT NULL,
    SalePrice DECIMAL(10,2) NOT NULL,
    SaleDate DATE NOT NULL
);
GO

INSERT INTO Categories (CategoryName) VALUES
    ('Grocery'),
    ('Dairy'),
    ('Beverages'),
    ('Household');
GO

INSERT INTO Suppliers (SupplierName, Phone, City) VALUES
    ('Al-Noor Traders', '0300-1111111', 'Lahore'),
    ('Kashmir Wholesale', '0301-2222222', 'Rawalpindi'),
    ('City Cash and Carry', '0302-3333333', 'Karachi');
GO

INSERT INTO Customers (FullName, Phone) VALUES
    ('Ahmed Raza', '0300-1234567'),
    ('Fatima Khan', '0301-2345678'),
    ('Bilal Ahmed', '0302-3456789'),
    ('Ayesha Malik', '0303-4567890');
GO

-- Products: Rice has stock 40 but reorder level 50, so it is low stock.
-- Milk has stock 30 but reorder level 40, so it is low stock.
-- Detergent has stock 15 but reorder level 25, so it is low stock.
INSERT INTO Products (ProductName, CategoryId, UnitPrice, StockQuantity, ReorderLevel) VALUES
    ('Rice', 1, 320, 40, 50),
    ('Sugar', 1, 180, 200, 50),
    ('Milk', 2, 220, 30, 40),
    ('Tea', 3, 950, 25, 20),
    ('Cooking Oil', 1, 650, 60, 30),
    ('Detergent', 4, 480, 15, 25);
GO

INSERT INTO Purchases (SupplierId, ProductId, Quantity, PurchasePrice, PurchaseDate) VALUES
    (1, 1, 100, 290, '2026-11-02'),
    (2, 3, 50, 200, '2026-11-05'),
    (1, 4, 30, 850, '2026-11-08'),
    (3, 6, 40, 430, '2026-11-10');
GO

-- Sale amounts: Rice 5 x 320 = 1600, Sugar 10 x 180 = 1800,
-- Milk 8 x 220 = 1760, Tea 2 x 950 = 1900,
-- Cooking Oil 3 x 650 = 1950, Detergent 4 x 480 = 1920.
INSERT INTO Sales (CustomerId, ProductId, Quantity, SalePrice, SaleDate) VALUES
    (1, 1, 5, 320, '2026-11-15'),
    (2, 2, 10, 180, '2026-11-15'),
    (3, 3, 8, 220, '2026-11-14'),
    (4, 4, 2, 950, '2026-11-15'),
    (1, 5, 3, 650, '2026-11-13'),
    (2, 6, 4, 480, '2026-11-15');
GO

-- Query 1: Low stock products — products where the stock on hand is at
-- or below the reorder level, so the shop should order more.
-- Expected result: 3 rows — Rice (40 <= 50), Milk (30 <= 40),
-- Detergent (15 <= 25).
SELECT
    p.ProductId,
    p.ProductName,
    c.CategoryName,
    p.StockQuantity,
    p.ReorderLevel
FROM Products p
INNER JOIN Categories c ON p.CategoryId = c.CategoryId
WHERE p.StockQuantity <= p.ReorderLevel
ORDER BY p.ProductName;
GO

-- Query 2: Daily sales for 2026-11-15.
-- Expected result: 4 sales — Rice 5 x 320 = 1600, Sugar 10 x 180 = 1800,
-- Tea 2 x 950 = 1900, Detergent 4 x 480 = 1920. Total = 7220.
SELECT
    s.SaleId,
    c.FullName AS Customer,
    p.ProductName,
    s.Quantity,
    s.SalePrice,
    s.Quantity * s.SalePrice AS Amount
FROM Sales s
INNER JOIN Customers c ON s.CustomerId = c.CustomerId
INNER JOIN Products p ON s.ProductId = p.ProductId
WHERE s.SaleDate = '2026-11-15'
ORDER BY s.SaleId;
GO

-- Query 3: Monthly sales for November 2026.
-- Expected result: all 6 sales.
-- Total = 1600 + 1800 + 1760 + 1900 + 1950 + 1920 = 10930.
SELECT
    COUNT(s.SaleId) AS TotalSales,
    SUM(s.Quantity * s.SalePrice) AS MonthlyTotal
FROM Sales s
WHERE YEAR(s.SaleDate) = 2026 AND MONTH(s.SaleDate) = 11;
GO

-- Query 4: Profit per product — (sale price - purchase price) multiplied
-- by the total quantity sold, joining Sales to Purchases per product.
-- Expected result: Rice (320 - 290) x 5 = 150, Milk (220 - 200) x 8 = 160,
-- Tea (950 - 850) x 2 = 200, Detergent (480 - 430) x 4 = 200.
-- Sugar and Cooking Oil have no purchases, so the INNER JOIN leaves
-- them out of this result.
SELECT
    p.ProductName,
    pu.PurchasePrice,
    s.SalePrice,
    SUM(s.Quantity) AS TotalSold,
    (s.SalePrice - pu.PurchasePrice) * SUM(s.Quantity) AS Profit
FROM Sales s
INNER JOIN Products p ON s.ProductId = p.ProductId
INNER JOIN Purchases pu ON pu.ProductId = p.ProductId
GROUP BY p.ProductName, pu.PurchasePrice, s.SalePrice
ORDER BY Profit DESC;
GO

-- Query 5: Supplier-wise purchases — total amount bought from each supplier.
-- Expected result: Al-Noor Traders = 100 x 290 + 30 x 850
-- = 29000 + 25500 = 54500.
SELECT
    sp.SupplierName,
    COUNT(pu.PurchaseId) AS TotalPurchases,
    SUM(pu.Quantity * pu.PurchasePrice) AS TotalAmount
FROM Purchases pu
INNER JOIN Suppliers sp ON pu.SupplierId = sp.SupplierId
GROUP BY sp.SupplierName
ORDER BY TotalAmount DESC;
GO
