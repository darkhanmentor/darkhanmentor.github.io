-- factory-inventory-oracle.sql
-- Factory Inventory Management System — Oracle version.
-- Run this script in Oracle SQL Developer (open the file and press F5,
-- Run Script) or in SQL*Plus (@factory-inventory-oracle.sql).
-- Oracle has no CREATE DATABASE statement like SQL Server: the tables are
-- created in the schema (user) you are connected as. If you want a
-- separate user for this project, create one first in SQL Developer or
-- SQL*Plus, for example:
--   CREATE USER factory_user IDENTIFIED BY your_password;
--   GRANT CONNECT, RESOURCE TO factory_user;
-- and then connect as factory_user and run this script.
-- Needs: Oracle Database XE (free) or any Oracle Database 19c or later.
-- The matching SQL Server version of this script is
-- factory-inventory-sqlserver.sql.

CREATE TABLE Suppliers (
    SupplierId NUMBER(10) PRIMARY KEY,
    SupplierName VARCHAR2(100) NOT NULL,
    ContactPerson VARCHAR2(100),
    Phone VARCHAR2(20),
    City VARCHAR2(100)
);

CREATE TABLE Products (
    ProductId NUMBER(10) PRIMARY KEY,
    ProductName VARCHAR2(100) NOT NULL,
    Category VARCHAR2(100),
    UnitPrice NUMBER(10,2) NOT NULL,
    ReorderLevel NUMBER(10) NOT NULL
);

CREATE TABLE RawMaterials (
    MaterialId NUMBER(10) PRIMARY KEY,
    MaterialName VARCHAR2(100) NOT NULL,
    Unit VARCHAR2(20),
    UnitCost NUMBER(10,2) NOT NULL,
    StockQuantity NUMBER(10) NOT NULL
);

CREATE TABLE Stock (
    StockId NUMBER(10) PRIMARY KEY,
    ProductId NUMBER(10) REFERENCES Products(ProductId),
    QuantityInStock NUMBER(10) NOT NULL,
    LastUpdated DATE NOT NULL
);

CREATE TABLE Orders (
    OrderId NUMBER(10) PRIMARY KEY,
    SupplierId NUMBER(10) REFERENCES Suppliers(SupplierId),
    OrderDate DATE NOT NULL,
    TotalAmount NUMBER(10,2) NOT NULL,
    Status VARCHAR2(20) DEFAULT 'Pending' NOT NULL
);

CREATE TABLE OrderDetails (
    OrderDetailId NUMBER(10) PRIMARY KEY,
    OrderId NUMBER(10) REFERENCES Orders(OrderId),
    ProductId NUMBER(10) REFERENCES Products(ProductId),
    Quantity NUMBER(10) NOT NULL,
    UnitPrice NUMBER(10,2) NOT NULL
);

-- Sequences for auto-increment IDs. Oracle has no IDENTITY like SQL Server,
-- so a sequence plus a trigger fills in the ID when a row is inserted
-- without one. Each sequence starts AFTER the highest sample ID below
-- (Suppliers has 4 sample rows, so its sequence starts at 5; Products has
-- 6 rows, so it starts at 7; RawMaterials has 5 rows, so it starts at 6;
-- Stock has 6 rows, so it starts at 7; Orders has 4 rows, so it starts
-- at 5; OrderDetails has 5 rows, so it starts at 6).
CREATE SEQUENCE suppliers_seq START WITH 5 INCREMENT BY 1;
CREATE SEQUENCE products_seq START WITH 7 INCREMENT BY 1;
CREATE SEQUENCE rawmaterials_seq START WITH 6 INCREMENT BY 1;
CREATE SEQUENCE stock_seq START WITH 7 INCREMENT BY 1;
CREATE SEQUENCE orders_seq START WITH 5 INCREMENT BY 1;
CREATE SEQUENCE orderdetails_seq START WITH 6 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_suppliers_bi
BEFORE INSERT ON Suppliers
FOR EACH ROW
BEGIN
    IF :NEW.SupplierId IS NULL THEN
        SELECT suppliers_seq.NEXTVAL INTO :NEW.SupplierId FROM dual;
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

CREATE OR REPLACE TRIGGER trg_rawmaterials_bi
BEFORE INSERT ON RawMaterials
FOR EACH ROW
BEGIN
    IF :NEW.MaterialId IS NULL THEN
        SELECT rawmaterials_seq.NEXTVAL INTO :NEW.MaterialId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_stock_bi
BEFORE INSERT ON Stock
FOR EACH ROW
BEGIN
    IF :NEW.StockId IS NULL THEN
        SELECT stock_seq.NEXTVAL INTO :NEW.StockId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_orders_bi
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    IF :NEW.OrderId IS NULL THEN
        SELECT orders_seq.NEXTVAL INTO :NEW.OrderId FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_orderdetails_bi
BEFORE INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    IF :NEW.OrderDetailId IS NULL THEN
        SELECT orderdetails_seq.NEXTVAL INTO :NEW.OrderDetailId FROM dual;
    END IF;
END;
/

INSERT INTO Suppliers (SupplierId, SupplierName, ContactPerson, Phone, City) VALUES
    (1, 'Ali Traders', 'Ahmed Ali', '0300-1111111', 'Lahore');
INSERT INTO Suppliers (SupplierId, SupplierName, ContactPerson, Phone, City) VALUES
    (2, 'Bilal Supplies', 'Bilal Khan', '0301-2222222', 'Karachi');
INSERT INTO Suppliers (SupplierId, SupplierName, ContactPerson, Phone, City) VALUES
    (3, 'Chenab Industries', 'Usman Chenab', '0302-3333333', 'Faisalabad');
INSERT INTO Suppliers (SupplierId, SupplierName, ContactPerson, Phone, City) VALUES
    (4, 'Ravi Enterprises', 'Hassan Ravi', '0303-4444444', 'Lahore');

INSERT INTO Products (ProductId, ProductName, Category, UnitPrice, ReorderLevel) VALUES
    (1, 'Cotton Fabric', 'Textiles', 1200, 50);
INSERT INTO Products (ProductId, ProductName, Category, UnitPrice, ReorderLevel) VALUES
    (2, 'Steel Rods', 'Metals', 4500, 30);
INSERT INTO Products (ProductId, ProductName, Category, UnitPrice, ReorderLevel) VALUES
    (3, 'Plastic Bottles', 'Packaging', 25, 500);
INSERT INTO Products (ProductId, ProductName, Category, UnitPrice, ReorderLevel) VALUES
    (4, 'Wheat Flour', 'Food', 180, 100);
INSERT INTO Products (ProductId, ProductName, Category, UnitPrice, ReorderLevel) VALUES
    (5, 'Office Chairs', 'Furniture', 8500, 10);
INSERT INTO Products (ProductId, ProductName, Category, UnitPrice, ReorderLevel) VALUES
    (6, 'Soap Bars', 'FMCG', 95, 200);

INSERT INTO RawMaterials (MaterialId, MaterialName, Unit, UnitCost, StockQuantity) VALUES
    (1, 'Cotton', 'kg', 800, 500);
INSERT INTO RawMaterials (MaterialId, MaterialName, Unit, UnitCost, StockQuantity) VALUES
    (2, 'Steel', 'kg', 320, 1000);
INSERT INTO RawMaterials (MaterialId, MaterialName, Unit, UnitCost, StockQuantity) VALUES
    (3, 'Plastic Granules', 'kg', 150, 800);
INSERT INTO RawMaterials (MaterialId, MaterialName, Unit, UnitCost, StockQuantity) VALUES
    (4, 'Wheat', 'kg', 120, 2000);
INSERT INTO RawMaterials (MaterialId, MaterialName, Unit, UnitCost, StockQuantity) VALUES
    (5, 'Wood', 'cubic ft', 2500, 100);

-- Stock: every row was last updated on 2026-11-15.
-- Note that three products are at or below their reorder level:
-- Cotton Fabric 40 < 50, Plastic Bottles 450 < 500, Office Chairs 8 < 10.
INSERT INTO Stock (StockId, ProductId, QuantityInStock, LastUpdated) VALUES
    (1, 1, 40, TO_DATE('2026-11-15', 'YYYY-MM-DD'));
INSERT INTO Stock (StockId, ProductId, QuantityInStock, LastUpdated) VALUES
    (2, 2, 120, TO_DATE('2026-11-15', 'YYYY-MM-DD'));
INSERT INTO Stock (StockId, ProductId, QuantityInStock, LastUpdated) VALUES
    (3, 3, 450, TO_DATE('2026-11-15', 'YYYY-MM-DD'));
INSERT INTO Stock (StockId, ProductId, QuantityInStock, LastUpdated) VALUES
    (4, 4, 300, TO_DATE('2026-11-15', 'YYYY-MM-DD'));
INSERT INTO Stock (StockId, ProductId, QuantityInStock, LastUpdated) VALUES
    (5, 5, 8, TO_DATE('2026-11-15', 'YYYY-MM-DD'));
INSERT INTO Stock (StockId, ProductId, QuantityInStock, LastUpdated) VALUES
    (6, 6, 500, TO_DATE('2026-11-15', 'YYYY-MM-DD'));

-- TotalAmount = sum of (Quantity x UnitPrice) of the order's details.
-- Order 1: 100 x 1200 = 120000. Order 2: 50 x 4500 = 225000.
-- Order 3: 200 x 180 + 100 x 95 = 36000 + 9500 = 45500.
-- Order 4: 1000 x 25 = 25000.
INSERT INTO Orders (OrderId, SupplierId, OrderDate, TotalAmount, Status) VALUES
    (1, 1, TO_DATE('2026-11-10', 'YYYY-MM-DD'), 120000, 'Completed');
INSERT INTO Orders (OrderId, SupplierId, OrderDate, TotalAmount, Status) VALUES
    (2, 2, TO_DATE('2026-11-12', 'YYYY-MM-DD'), 225000, 'Pending');
INSERT INTO Orders (OrderId, SupplierId, OrderDate, TotalAmount, Status) VALUES
    (3, 1, TO_DATE('2026-11-14', 'YYYY-MM-DD'), 45500, 'Completed');
INSERT INTO Orders (OrderId, SupplierId, OrderDate, TotalAmount, Status) VALUES
    (4, 3, TO_DATE('2026-11-15', 'YYYY-MM-DD'), 25000, 'Pending');

INSERT INTO OrderDetails (OrderDetailId, OrderId, ProductId, Quantity, UnitPrice) VALUES
    (1, 1, 1, 100, 1200);
INSERT INTO OrderDetails (OrderDetailId, OrderId, ProductId, Quantity, UnitPrice) VALUES
    (2, 2, 2, 50, 4500);
INSERT INTO OrderDetails (OrderDetailId, OrderId, ProductId, Quantity, UnitPrice) VALUES
    (3, 3, 4, 200, 180);
INSERT INTO OrderDetails (OrderDetailId, OrderId, ProductId, Quantity, UnitPrice) VALUES
    (4, 3, 6, 100, 95);
INSERT INTO OrderDetails (OrderDetailId, OrderId, ProductId, Quantity, UnitPrice) VALUES
    (5, 4, 3, 1000, 25);

COMMIT;

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

-- Query 2: Supplier-wise orders — how many orders and how much money
-- each supplier has. Expected result: Ali Traders has Orders 1 and 3,
-- total 120000 + 45500 = 165500. Bilal Supplies 1 order, 225000.
-- Chenab Industries 1 order, 25000. Ravi Enterprises 0 orders, 0.
-- (Oracle uses NVL where SQL Server uses ISNULL.)
SELECT
    s.SupplierName,
    COUNT(o.OrderId) AS TotalOrders,
    NVL(SUM(o.TotalAmount), 0) AS TotalAmount
FROM Suppliers s
LEFT JOIN Orders o ON o.SupplierId = s.SupplierId
GROUP BY s.SupplierName
ORDER BY TotalAmount DESC;

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
WHERE o.OrderDate >= TO_DATE('2026-11-01', 'YYYY-MM-DD')
    AND o.OrderDate < TO_DATE('2026-12-01', 'YYYY-MM-DD')
ORDER BY o.OrderDate;

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

COMMIT;
