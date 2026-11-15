-- factory-inventory-sqlserver.sql
-- Factory Inventory Management System — SQL Server version.
-- Run this script in SQL Server Management Studio (SSMS) or in Visual
-- Studio's SQL Server Object Explorer. It creates the FactoryDB database,
-- 6 tables (Suppliers, Products, RawMaterials, Stock, Orders, OrderDetails),
-- inserts the sample data, and then runs 5 practical SELECT queries.
-- Needs: SQL Server Express, SQL Server Developer, or LocalDB.
-- The matching Oracle version of this script is factory-inventory-oracle.sql.

CREATE DATABASE FactoryDB;
GO

USE FactoryDB;
GO

CREATE TABLE Suppliers (
    SupplierId INT PRIMARY KEY IDENTITY(1,1),
    SupplierName NVARCHAR(100) NOT NULL,
    ContactPerson NVARCHAR(100),
    Phone NVARCHAR(20),
    City NVARCHAR(100)
);
GO

CREATE TABLE Products (
    ProductId INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    Category NVARCHAR(100),
    UnitPrice DECIMAL(10,2) NOT NULL,
    ReorderLevel INT NOT NULL
);
GO

CREATE TABLE RawMaterials (
    MaterialId INT PRIMARY KEY IDENTITY(1,1),
    MaterialName NVARCHAR(100) NOT NULL,
    Unit NVARCHAR(20),
    UnitCost DECIMAL(10,2) NOT NULL,
    StockQuantity INT NOT NULL
);
GO

CREATE TABLE Stock (
    StockId INT PRIMARY KEY IDENTITY(1,1),
    ProductId INT FOREIGN KEY REFERENCES Products(ProductId),
    QuantityInStock INT NOT NULL,
    LastUpdated DATE NOT NULL
);
GO

CREATE TABLE Orders (
    OrderId INT PRIMARY KEY IDENTITY(1,1),
    SupplierId INT FOREIGN KEY REFERENCES Suppliers(SupplierId),
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Pending'
);
GO

CREATE TABLE OrderDetails (
    OrderDetailId INT PRIMARY KEY IDENTITY(1,1),
    OrderId INT FOREIGN KEY REFERENCES Orders(OrderId),
    ProductId INT FOREIGN KEY REFERENCES Products(ProductId),
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL
);
GO

-- Sample data. IDs are filled in automatically by IDENTITY in the order
-- below, so the first supplier is 1 (Ali Traders), the first product is
-- 1 (Cotton Fabric), and so on.
INSERT INTO Suppliers (SupplierName, ContactPerson, Phone, City) VALUES
    ('Ali Traders', 'Ahmed Ali', '0300-1111111', 'Lahore'),
    ('Bilal Supplies', 'Bilal Khan', '0301-2222222', 'Karachi'),
    ('Chenab Industries', 'Usman Chenab', '0302-3333333', 'Faisalabad'),
    ('Ravi Enterprises', 'Hassan Ravi', '0303-4444444', 'Lahore');
GO

INSERT INTO Products (ProductName, Category, UnitPrice, ReorderLevel) VALUES
    ('Cotton Fabric', 'Textiles', 1200, 50),
    ('Steel Rods', 'Metals', 4500, 30),
    ('Plastic Bottles', 'Packaging', 25, 500),
    ('Wheat Flour', 'Food', 180, 100),
    ('Office Chairs', 'Furniture', 8500, 10),
    ('Soap Bars', 'FMCG', 95, 200);
GO

INSERT INTO RawMaterials (MaterialName, Unit, UnitCost, StockQuantity) VALUES
    ('Cotton', 'kg', 800, 500),
    ('Steel', 'kg', 320, 1000),
    ('Plastic Granules', 'kg', 150, 800),
    ('Wheat', 'kg', 120, 2000),
    ('Wood', 'cubic ft', 2500, 100);
GO

-- Stock: every row was last updated on 2026-11-15.
-- Note that three products are at or below their reorder level:
-- Cotton Fabric 40 < 50, Plastic Bottles 450 < 500, Office Chairs 8 < 10.
INSERT INTO Stock (ProductId, QuantityInStock, LastUpdated) VALUES
    (1, 40, '2026-11-15'),
    (2, 120, '2026-11-15'),
    (3, 450, '2026-11-15'),
    (4, 300, '2026-11-15'),
    (5, 8, '2026-11-15'),
    (6, 500, '2026-11-15');
GO

-- TotalAmount = sum of (Quantity x UnitPrice) of the order's details.
-- Order 1: 100 x 1200 = 120000. Order 2: 50 x 4500 = 225000.
-- Order 3: 200 x 180 + 100 x 95 = 36000 + 9500 = 45500.
-- Order 4: 1000 x 25 = 25000.
INSERT INTO Orders (SupplierId, OrderDate, TotalAmount, Status) VALUES
    (1, '2026-11-10', 120000, 'Completed'),
    (2, '2026-11-12', 225000, 'Pending'),
    (1, '2026-11-14', 45500, 'Completed'),
    (3, '2026-11-15', 25000, 'Pending');
GO

INSERT INTO OrderDetails (OrderId, ProductId, Quantity, UnitPrice) VALUES
    (1, 1, 100, 1200),
    (2, 2, 50, 4500),
    (3, 4, 200, 180),
    (3, 6, 100, 95),
    (4, 3, 1000, 25);
GO

-- Query 1: Low stock alert — products whose stock is at or below the
-- reorder level. Expected result: 3 products — Cotton Fabric (40 < 50),
-- Plastic Bottles (450 < 500), Office Chairs (8 < 10).
SELECT
    p.ProductId,
    p.ProductName,
    p.Category,
    p.UnitPrice,
    p.ReorderLevel,
    s.QuantityInStock
FROM Products p
INNER JOIN Stock s ON s.ProductId = p.ProductId
WHERE s.QuantityInStock <= p.ReorderLevel
ORDER BY p.ProductName;
GO

-- Query 2: Supplier-wise orders — how many orders and how much money
-- each supplier has. Expected result: Ali Traders has Orders 1 and 3,
-- total 120000 + 45500 = 165500. Bilal Supplies 1 order, 225000.
-- Chenab Industries 1 order, 25000. Ravi Enterprises 0 orders, 0.
SELECT
    s.SupplierName,
    COUNT(o.OrderId) AS TotalOrders,
    ISNULL(SUM(o.TotalAmount), 0) AS TotalAmount
FROM Suppliers s
LEFT JOIN Orders o ON o.SupplierId = s.SupplierId
GROUP BY s.SupplierName
ORDER BY TotalAmount DESC;
GO

-- Query 3: Stock value per product (QuantityInStock x UnitPrice).
-- Expected result: Cotton Fabric 40 x 1200 = 48000, Steel Rods
-- 120 x 4500 = 540000, Plastic Bottles 450 x 25 = 11250,
-- Wheat Flour 300 x 180 = 54000, Office Chairs 8 x 8500 = 68000,
-- Soap Bars 500 x 95 = 47500. Grand total = 768750.
SELECT
    p.ProductName,
    s.QuantityInStock,
    p.UnitPrice,
    s.QuantityInStock * p.UnitPrice AS StockValue
FROM Products p
INNER JOIN Stock s ON s.ProductId = p.ProductId
ORDER BY StockValue DESC;
GO

-- Query 4: Orders in November 2026.
-- Expected result: 4 orders (OrderIds 1, 2, 3, 4).
SELECT
    o.OrderId,
    s.SupplierName,
    o.OrderDate,
    o.TotalAmount,
    o.Status
FROM Orders o
INNER JOIN Suppliers s ON o.SupplierId = s.SupplierId
WHERE o.OrderDate >= '2026-11-01' AND o.OrderDate < '2026-12-01'
ORDER BY o.OrderDate;
GO

-- Query 5: Products by category.
-- Expected result for 'Textiles': 1 row — Cotton Fabric, price 1200,
-- reorder level 50.
SELECT
    ProductId,
    ProductName,
    Category,
    UnitPrice,
    ReorderLevel
FROM Products
WHERE Category = 'Textiles'
ORDER BY ProductName;
GO
