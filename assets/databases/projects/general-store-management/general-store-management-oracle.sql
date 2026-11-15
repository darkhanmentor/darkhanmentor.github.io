-- general-store-management-oracle.sql
-- General Store Management System — Oracle version.
-- Run this script in Oracle SQL Developer (open the file and press F5,
-- Run Script) or in SQL*Plus (@general-store-management-oracle.sql).
-- Oracle has no CREATE DATABASE statement like SQL Server: the tables are
-- created in the schema (user) you are connected as. If you want a
-- separate user for this project, create one first in SQL Developer or
-- SQL*Plus, for example:
--   CREATE USER generalstore_user IDENTIFIED BY your_password;
--   GRANT CONNECT, RESOURCE TO generalstore_user;
-- and then connect as generalstore_user and run this script.
-- Needs: Oracle Database XE (free) or any Oracle Database 19c or later.
-- The matching SQL Server version of this script is
-- general-store-management-sqlserver.sql.

CREATE TABLE Categories (
    CategoryId NUMBER(10) PRIMARY KEY,
    CategoryName VARCHAR2(100) NOT NULL
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

CREATE TABLE Products (
    ProductId NUMBER(10) PRIMARY KEY,
    ProductName VARCHAR2(100) NOT NULL,
    CategoryId NUMBER(10) REFERENCES Categories(CategoryId),
    UnitPrice NUMBER(10,2) NOT NULL,
    StockQuantity NUMBER(10) NOT NULL,
    ReorderLevel NUMBER(10) NOT NULL
);

CREATE TABLE Purchases (
    PurchaseId NUMBER(10) PRIMARY KEY,
    SupplierId NUMBER(10) REFERENCES Suppliers(SupplierId),
    ProductId NUMBER(10) REFERENCES Products(ProductId),
    Quantity NUMBER(10) NOT NULL,
    PurchasePrice NUMBER(10,2) NOT NULL,
    PurchaseDate DATE NOT NULL
);

CREATE TABLE Sales (
    SaleId NUMBER(10) PRIMARY KEY,
    CustomerId NUMBER(10) REFERENCES Customers(CustomerId),
    ProductId NUMBER(10) REFERENCES Products(ProductId),
    Quantity NUMBER(10) NOT NULL,
    SalePrice NUMBER(10,2) NOT NULL,
    SaleDate DATE NOT NULL
);

-- Sequences for auto-increment IDs. Oracle has no IDENTITY like SQL Server,
-- so a sequence plus a trigger fills in the ID when a row is inserted
-- without one. Each sequence starts AFTER the highest sample ID below
-- (Categories has 4 sample rows, so its sequence starts at 5;
-- Products has 6 rows, so its sequence starts at 7;
-- Suppliers and Customers have 3 and 4 rows, so they start at 4 and 5;
-- Purchases has 4 rows, so it starts at 5;
-- Sales has 6 rows, so it starts at 7).
CREATE SEQUENCE categories_seq START WITH 5 INCREMENT BY 1;
CREATE SEQUENCE suppliers_seq START WITH 4 INCREMENT BY 1;
CREATE SEQUENCE customers_seq START WITH 5 INCREMENT BY 1;
CREATE SEQUENCE products_seq START WITH 7 INCREMENT BY 1;
CREATE SEQUENCE purchases_seq START WITH 5 INCREMENT BY 1;
CREATE SEQUENCE sales_seq START WITH 7 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_categories_bi
BEFORE INSERT ON Categories
FOR EACH ROW
BEGIN
    IF :NEW.CategoryId IS NULL THEN
        SELECT categories_seq.NEXTVAL INTO :NEW.CategoryId FROM dual;
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

CREATE OR REPLACE TRIGGER trg_products_bi
BEFORE INSERT ON Products
FOR EACH ROW
BEGIN
    IF :NEW.ProductId IS NULL THEN
        SELECT products_seq.NEXTVAL INTO :NEW.ProductId FROM dual;
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

INSERT INTO Categories (CategoryId, CategoryName) VALUES
    (1, 'Grocery');
INSERT INTO Categories (CategoryId, CategoryName) VALUES
    (2, 'Dairy');
INSERT INTO Categories (CategoryId, CategoryName) VALUES
    (3, 'Beverages');
INSERT INTO Categories (CategoryId, CategoryName) VALUES
    (4, 'Household');

INSERT INTO Suppliers (SupplierId, SupplierName, Phone, City) VALUES
    (1, 'Al-Noor Traders', '0300-1111111', 'Lahore');
INSERT INTO Suppliers (SupplierId, SupplierName, Phone, City) VALUES
    (2, 'Kashmir Wholesale', '0301-2222222', 'Rawalpindi');
INSERT INTO Suppliers (SupplierId, SupplierName, Phone, City) VALUES
    (3, 'City Cash and Carry', '0302-3333333', 'Karachi');

INSERT INTO Customers (CustomerId, FullName, Phone) VALUES
    (1, 'Ahmed Raza', '0300-1234567');
INSERT INTO Customers (CustomerId, FullName, Phone) VALUES
    (2, 'Fatima Khan', '0301-2345678');
INSERT INTO Customers (CustomerId, FullName, Phone) VALUES
    (3, 'Bilal Ahmed', '0302-3456789');
INSERT INTO Customers (CustomerId, FullName, Phone) VALUES
    (4, 'Ayesha Malik', '0303-4567890');

-- Products: Rice has stock 40 but reorder level 50, so it is low stock.
-- Milk has stock 30 but reorder level 40, so it is low stock.
-- Detergent has stock 15 but reorder level 25, so it is low stock.
INSERT INTO Products (ProductId, ProductName, CategoryId, UnitPrice, StockQuantity, ReorderLevel) VALUES
    (1, 'Rice', 1, 320, 40, 50);
INSERT INTO Products (ProductId, ProductName, CategoryId, UnitPrice, StockQuantity, ReorderLevel) VALUES
    (2, 'Sugar', 1, 180, 200, 50);
INSERT INTO Products (ProductId, ProductName, CategoryId, UnitPrice, StockQuantity, ReorderLevel) VALUES
    (3, 'Milk', 2, 220, 30, 40);
INSERT INTO Products (ProductId, ProductName, CategoryId, UnitPrice, StockQuantity, ReorderLevel) VALUES
    (4, 'Tea', 3, 950, 25, 20);
INSERT INTO Products (ProductId, ProductName, CategoryId, UnitPrice, StockQuantity, ReorderLevel) VALUES
    (5, 'Cooking Oil', 1, 650, 60, 30);
INSERT INTO Products (ProductId, ProductName, CategoryId, UnitPrice, StockQuantity, ReorderLevel) VALUES
    (6, 'Detergent', 4, 480, 15, 25);

INSERT INTO Purchases (PurchaseId, SupplierId, ProductId, Quantity, PurchasePrice, PurchaseDate) VALUES
    (1, 1, 1, 100, 290, TO_DATE('2026-11-02', 'YYYY-MM-DD'));
INSERT INTO Purchases (PurchaseId, SupplierId, ProductId, Quantity, PurchasePrice, PurchaseDate) VALUES
    (2, 2, 3, 50, 200, TO_DATE('2026-11-05', 'YYYY-MM-DD'));
INSERT INTO Purchases (PurchaseId, SupplierId, ProductId, Quantity, PurchasePrice, PurchaseDate) VALUES
    (3, 1, 4, 30, 850, TO_DATE('2026-11-08', 'YYYY-MM-DD'));
INSERT INTO Purchases (PurchaseId, SupplierId, ProductId, Quantity, PurchasePrice, PurchaseDate) VALUES
    (4, 3, 6, 40, 430, TO_DATE('2026-11-10', 'YYYY-MM-DD'));

-- Sale amounts: Rice 5 x 320 = 1600, Sugar 10 x 180 = 1800,
-- Milk 8 x 220 = 1760, Tea 2 x 950 = 1900,
-- Cooking Oil 3 x 650 = 1950, Detergent 4 x 480 = 1920.
INSERT INTO Sales (SaleId, CustomerId, ProductId, Quantity, SalePrice, SaleDate) VALUES
    (1, 1, 1, 5, 320, TO_DATE('2026-11-15', 'YYYY-MM-DD'));
INSERT INTO Sales (SaleId, CustomerId, ProductId, Quantity, SalePrice, SaleDate) VALUES
    (2, 2, 2, 10, 180, TO_DATE('2026-11-15', 'YYYY-MM-DD'));
INSERT INTO Sales (SaleId, CustomerId, ProductId, Quantity, SalePrice, SaleDate) VALUES
    (3, 3, 3, 8, 220, TO_DATE('2026-11-14', 'YYYY-MM-DD'));
INSERT INTO Sales (SaleId, CustomerId, ProductId, Quantity, SalePrice, SaleDate) VALUES
    (4, 4, 4, 2, 950, TO_DATE('2026-11-15', 'YYYY-MM-DD'));
INSERT INTO Sales (SaleId, CustomerId, ProductId, Quantity, SalePrice, SaleDate) VALUES
    (5, 1, 5, 3, 650, TO_DATE('2026-11-13', 'YYYY-MM-DD'));
INSERT INTO Sales (SaleId, CustomerId, ProductId, Quantity, SalePrice, SaleDate) VALUES
    (6, 2, 6, 4, 480, TO_DATE('2026-11-15', 'YYYY-MM-DD'));

COMMIT;

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
WHERE s.SaleDate = TO_DATE('2026-11-15', 'YYYY-MM-DD')
ORDER BY s.SaleId;

-- Query 3: Monthly sales for November 2026.
-- Expected result: all 6 sales.
-- Total = 1600 + 1800 + 1760 + 1900 + 1950 + 1920 = 10930.
-- (Oracle uses EXTRACT instead of YEAR and MONTH.)
SELECT
    COUNT(s.SaleId) AS TotalSales,
    NVL(SUM(s.Quantity * s.SalePrice), 0) AS MonthlyTotal
FROM Sales s
WHERE EXTRACT(YEAR FROM s.SaleDate) = 2026 AND EXTRACT(MONTH FROM s.SaleDate) = 11;

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

COMMIT;
