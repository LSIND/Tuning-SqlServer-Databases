USE AdventureWorks;
GO

-- 1. Таблица TestTable без ключей и индексов
DROP TABLE IF EXISTS TestTable;
CREATE TABLE TestTable (ID INT, ProductName VARCHAR(50), Price DECIMAL(5,2) )
GO

DECLARE @x INT = 1;
WHILE(@x < 1000)
BEGIN
INSERT INTO TestTable (ID, ProductName, Price)
VALUES(@x, Concat('Product', @x), 500/@x);
SET @x +=1
END
GO 2


-- 2. Table Scan
-- Estimated Number of Rows to be Read
SELECT ID, ProductName FROM TestTable;

SELECT ID, ProductName FROM TestTable
WHERE ID IN (56, 958, 15600, 9000);

SELECT ID, ProductName FROM TestTable
WHERE ProductName = 'Product10';
GO

-- 3. Кластерный индекс на ID
CREATE CLUSTERED INDEX IX_TestTable_ID ON TestTable (ID)
GO

-- Index Scan
SELECT ID, ProductName FROM TestTable;

-- Estimated Number of Rows to be Read
SELECT ID, ProductName FROM TestTable
WHERE ID IN (56, 958, 15600, 9000);

SELECT ID, ProductName FROM TestTable
WHERE ProductName = 'Product10';
GO


-- 4. Некластерный индекс на ProductName
CREATE NONCLUSTERED INDEX IXTestTable_FirstName ON TestTable (ProductName)
GO

SELECT ID, ProductName FROM TestTable;

SELECT ID, ProductName FROM TestTable
WHERE ID IN (56, 958, 15600, 9000);

-- Estimated Number of Rows to be Read
SELECT ID, ProductName FROM TestTable
WHERE ProductName = 'Product10';
GO

SELECT ID, ProductName, Price FROM TestTable
WHERE Price > 10;
GO

-- 5. DROP TABLE
DROP TABLE IF EXISTS TestTable;


-- 6. Scan
SELECT [SalesOrderID],[CarrierTrackingNumber],[OrderQty],[ProductID],
[UnitPrice],[ModifiedDate]
FROM [Sales].[SalesOrderDetail];

-- Key Lookup - 99%
SELECT [SalesOrderID],[CarrierTrackingNumber],[OrderQty],[ProductID],
[UnitPrice],[ModifiedDate]
FROM [Sales].[SalesOrderDetail]
Where [ModifiedDate] > '20070101' and [ProductID] = 771;
GO


-- Nested Loop -> APPLY
CREATE FUNCTION dbo.fn_GetTopOrders(@custid AS int, @n AS INT)
  RETURNS TABLE
AS
RETURN
  SELECT TOP(@n) SalesOrderID, CustomerID, [Status], TotalDue
  FROM Sales.SalesOrderHeader
  WHERE CustomerID = @custid
  ORDER BY TotalDue DESC
GO

SELECT  C.CustomerID, O.SalesOrderID, O.TotalDue
FROM AdventureWorks.Sales.Customer AS C
CROSS APPLY dbo.fn_GetTopOrders(C.CustomerID, 3) AS O
ORDER BY  CustomerID ASC, TotalDue DESC;


-- MERGE JOIN

SELECT D.CarrierTrackingNumber, H.DueDate, H.Freight
FROM Sales.SalesOrderDetail AS D
INNER JOIN Sales.SalesOrderHeader AS H
ON H.SalesOrderID = D.SalesOrderID;



--- Hash Match Product <-> ProductSubcategory
-- FK ProductSubcategoryID - allows NULL
SELECT P.Name, P.Color, P.ListPrice, C.Name AS [SubCat]
FROM Production.Product as P
JOIN Production.ProductSubcategory as C
ON P.ProductSubcategoryID = C.ProductSubcategoryID;


SELECT P.Name, P.Color, P.ListPrice, C.Name AS [SubCat]
FROM Production.Product as P
FULL OUTER JOIN Production.ProductSubcategory as C
ON P.ProductSubcategoryID = C.ProductSubcategoryID;


SELECT D.CarrierTrackingNumber, H.DueDate, SUM(H.Freight)
FROM Sales.SalesOrderDetail AS D
INNER JOIN Sales.SalesOrderHeader AS H
ON H.SalesOrderID = D.SalesOrderID
GROUP BY D.CarrierTrackingNumber, H.DueDate;

-- WARNINGS

--PlanAffectingConvert warning
SELECT  e.BusinessEntityID,
        e.NationalIDNumber
  FROM  HumanResources.Employee AS e
  WHERE e.NationalIDNumber = 112457891;

  
-- NO JOIN PREDICDATE
SELECT * FROM Production.Product, 
Production.ProductSubcategory;


-- Sort Warnings
-- Все заказы, где дата выполнения отправки больше, чем дата отправки
-- Wrong cardinality estimation – comparison operators between different columns of the same table
SELECT *
FROM Sales.SalesOrderHeader
WHERE DueDate > ShipDate
ORDER BY OrderDate;

-- SQL Server содержит статистику для двух столбцов, но не содержит статистики на случай, когда эти столбцы сравниваются.
-- Исправить это можно, добавив вычисляемый столбец

ALTER TABLE Sales.SalesOrderHeader
ADD DueDateMinusShipDate AS DATEDIFF(day, ShipDate, DueDate);
GO

SELECT * FROM Sales.SalesOrderHeader
WHERE DATEDIFF(day, ShipDate, DueDate)>0
ORDER BY OrderDate;



-- Аналогичная проблема при использовании переменной
DECLARE @OrderDate DATETIME='20110101';
SELECT *
FROM Sales.SalesOrderHeader
WHERE OrderDate > @OrderDate
ORDER BY DueDate;

-- Auto Create Statistics OFF

alter database 
adventureworks set auto_Create_statistics ON
GO