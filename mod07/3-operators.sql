USE AdventureWorks;
GO

-- 1. Таблица TestTable без ключей и индексов
DROP TABLE IF EXISTS dbo.TestTable;
CREATE TABLE dbo.TestTable 
(ID INT, ProductName VARCHAR(50), 
Price DECIMAL(5,2) )
GO

DECLARE @x INT = 1;
WHILE(@x < 1000)
BEGIN
INSERT INTO dbo.TestTable (ID, ProductName, Price)
VALUES(@x, Concat('Product', @x), 500/@x);
SET @x +=1
END
GO 2


-- 2. Table Scan
-- Estimated Number of Rows to be Read - 1998
SELECT ID, ProductName FROM dbo.TestTable;

-- Estimated Number of Rows to be Read - 1998
SELECT ID, ProductName FROM dbo.TestTable
WHERE ID IN (56, 958, 15600, 9000);

-- Estimated Number of Rows to be Read - 1998
SELECT ID, ProductName FROM dbo.TestTable
WHERE ProductName = 'Product10';
GO


-- INSERT, UPDATE, DELETE кучи
-- Table Insert (1 of 1)
INSERT INTO dbo.TestTable (ID, ProductName, Price)
VALUES(2000, 'Product2000', 500);

-- Table Update
-- Table Scan!
-- Table Update
UPDATE dbo.TestTable 
SET ProductName = 'ProductXXX' WHERE Price = 500;


-- Table Delete
-- Table Scan!
-- Table Delete
DELETE FROM dbo.TestTable WHERE ID = 2000;


-- 3. Кластерный индекс на ID
CREATE CLUSTERED INDEX IX_TestTable_ID ON dbo.TestTable (ID)
GO

-- Clustered Index Scan
SELECT ID, ProductName FROM dbo.TestTable;

-- Clustered Index Seek
-- Estimated Number of Rows to be Read - 4
SELECT ID, ProductName FROM dbo.TestTable
WHERE ID IN (56, 958, 15600, 9000);


-- INSERT, UPDATE, DELETE 
-- Clustered Index Insert (1 of 1)
INSERT INTO dbo.TestTable (ID, ProductName, Price)
VALUES(2000, 'Product2000', 500);

-- Table Update
-- Clustered Index Scan
-- Clustered Index Update
UPDATE dbo.TestTable 
SET ProductName = 'ProductXXX' WHERE Price = 500;

-- Table Update
-- Clustered Index Seek
-- Clustered Index Update
UPDATE dbo.TestTable 
SET ProductName = 'ProductXXX' WHERE ID = 10;


-- Table Update
-- Clustered Index Update
UPDATE dbo.TestTable 
SET ID = 3000 WHERE ID = 2; -- редкая операция


-- Table Delete
-- Clustered Index Delete
DELETE FROM dbo.TestTable WHERE ID = 2000;




-- Clustered Index Scan
-- Estimated Number of Rows to be Read - 1998
-- Нет индекса по ProductName
-- Добавлена статистика для столбца ProductName
SELECT ID, ProductName FROM dbo.TestTable
WHERE ProductName = 'Product10';
GO


-- 4. Некластерный индекс на ProductName
CREATE NONCLUSTERED INDEX IX_TestTable_ProductName ON dbo.TestTable (ProductName);
GO

SELECT ID, ProductName FROM dbo.TestTable;

-- Clustered Index Seek
SELECT ID, ProductName FROM dbo.TestTable
WHERE ID IN (56, 958, 15600, 9000);

-- Index Seek (NonClustered)
-- Estimated Number of Rows to be Read - 2
SELECT ID, ProductName FROM dbo.TestTable
WHERE ProductName = 'Product10';
GO

-- Clustered Index Scan
-- Estimated Number of Rows to be Read - 1998
-- Добавлена статистика для столбца price
SELECT ID, ProductName, Price FROM dbo.TestTable
WHERE Price > 10;
GO

-- можно удалить статистику, которая была создана автоматически для ProductName (не рекомендуется)
DROP STATISTICS dbo.TestTable.[_WA_Sys_00000002_4DD47EBD];


-- INSERT, UPDATE, DELETE 
-- Clustered Index Insert (1 of 1)
INSERT INTO dbo.TestTable (ID, ProductName, Price)
VALUES(2000, 'Product2000', 500);

-- Table Update
-- Clustered Index Seek
-- Проверка необходимости обновления (выражение CASE в Compute Scalar)
-- Если значение ProductName действительно меняется, то обновляются оба индекса
-- Обновление некластеризованного индекса не показывается отдельной операцией в плане потому, что это внутренняя операция SQL Server (часть UPDATE)
-- в XML плана есть следующие элементы:
---- <Object Database="[AdventureWorks]" Schema="[dbo]" Table="[TestTable]" Index="[IX_TestTable_ID]" IndexKind="Clustered" Storage="RowStore" />
---- <Object Database="[AdventureWorks]" Schema="[dbo]" Table="[TestTable]" Index="[IX_TestTable_ProductName]" IndexKind="NonClustered" Storage="RowStore" />
-- Clustered Index Update
UPDATE dbo.TestTable 
SET ProductName = 'ProductXXX' WHERE ID = 10;



-- Table Delete
-- Clustered Index Delete
DELETE FROM dbo.TestTable WHERE ID = 2000;






-- 5. DROP TABLE
DROP TABLE IF EXISTS dbo.TestTable;
GO

---------------------------------------
---------------------------------------

-- 6. Clustered Index Scan
SELECT [SalesOrderID],[CarrierTrackingNumber],[OrderQty],[ProductID],
[UnitPrice],[ModifiedDate]
FROM [Sales].[SalesOrderDetail];
GO

-- Index Seek (Nonclustered) + Key Lookup (Clustered) - 99%
SELECT [SalesOrderID],[CarrierTrackingNumber],[OrderQty],[ProductID],
[UnitPrice],[ModifiedDate]
FROM [Sales].[SalesOrderDetail]
Where [ModifiedDate] > '20070101' and [ProductID] = 771;
GO


-- Nested Loops 
-- -> APPLY
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
GO

-- Clustered Index Scan [ProductSubcategory] - 37 записей
-- Clustered Index Seek ProductCategory - 37 раз (estimated number of executions)
SELECT c.ProductCategoryID, c.Name, s.Name
FROM Production.ProductCategory as c 
JOIN Production.ProductSubcategory as s 
ON c.ProductCategoryID = s.ProductCategoryID;


-- MERGE JOIN
-- Clustered Index Scan (SalesOrderHeader)
-- Clustered Index Scan (SalesOrderDetail)
SELECT D.CarrierTrackingNumber, H.DueDate, H.Freight
FROM Sales.SalesOrderDetail AS D
INNER JOIN Sales.SalesOrderHeader AS H
ON H.SalesOrderID = D.SalesOrderID;



-- Hash Match
-- FK ProductSubcategoryID - allows NULL
-- -- Index Scan (Nonclustered) ProductSubcategory - 37 строк
-- -- Clustered Index Scan Product - 504 строки
-- 295 строк
SELECT P.Name, P.Color, P.ListPrice, C.Name AS [SubCat]
FROM Production.Product as P
JOIN Production.ProductSubcategory as C
ON P.ProductSubcategoryID = C.ProductSubcategoryID;


-- Hash Match (Right Outer Join)
-- -- Index Scan (Nonclustered) ProductSubcategory - 37 строк
-- -- Clustered Index Scan Product - 504 строки
-- 504 строки
SELECT P.Name, P.Color, P.ListPrice, C.Name AS [SubCat]
FROM Production.Product as P
LEFT OUTER JOIN Production.ProductSubcategory as C
ON P.ProductSubcategoryID = C.ProductSubcategoryID;


DROP FUNCTION dbo.fn_GetTopOrders;
GO


---------------------------------------
---------------------------------------

-- Hash Match (Aggregate)
-- Запрос выполняется параллельно (Parallel="true")
-- Parallelism (Repartition Streams): Перераспределяет потоки данных для обеих таблиц. Использует хэш-разделение по SalesOrderID
-- Hash Match (Inner Join): Выполняет соединение таблиц по SalesOrderID
-- Parallelism (Repartition Streams): Еще одно перераспределение потоков, по CarrierTrackingNumber и DueDate
-- Hash Match (Aggregate): Вычисляет SUM(Freight), группирует по CarrierTrackingNumber и DueDate
-- Parallelism (Gather Streams): Собирает параллельные потоки в один результат

SELECT D.CarrierTrackingNumber, H.DueDate, SUM(H.Freight)
FROM Sales.SalesOrderDetail AS D
INNER JOIN Sales.SalesOrderHeader AS H
ON H.SalesOrderID = D.SalesOrderID
GROUP BY D.CarrierTrackingNumber, H.DueDate;


---------------------------------------
---------------------------------------

-- WARNINGS

-- SELECT: Type conversion in expression NationalIDNumber (int) may affect CardinalityEstimate и SeekPlan
-- Index Scan (Nonclustered) HumanResources.Employee - 290 строк
SELECT  e.BusinessEntityID,
        e.NationalIDNumber
  FROM  HumanResources.Employee AS e
  WHERE e.NationalIDNumber = 112457891;

-- исправление: столбец NationalIDNumber - строка
-- Index Seek (Nonclustered) HumanResources.Employee - 1 строка
SELECT  e.BusinessEntityID,
        e.NationalIDNumber
  FROM  HumanResources.Employee AS e
  WHERE e.NationalIDNumber = '112457891';


  
-- Nested Loops: NO JOIN PREDICATE
-- Table Spool: создает временную таблицу (в памяти или на диске), в которую записываются строки данных - 18648 строк
SELECT * FROM Production.Product, 
Production.ProductSubcategory;

SELECT p.Name, s.Name FROM Production.Product as p
CROSS JOIN
Production.ProductSubcategory as s;



-- Sort Warnings
-- Все заказы, где дата выполнения отправки больше, чем дата отправки
-- estimated plan не содержит предупреждений: Clustered Index Scan (31465 - 9440) -> Sort (9439.5 ?) -> Select
-- actual plan обрабатывает Clustered Index Scan (31465 of 9440)
-- actual plan содержит предупреждение на узле Sort (31465 of 9440) - operator used tempdb to spill data
SELECT SalesOrderID, DueDate, ShipDate
FROM Sales.SalesOrderHeader
WHERE DueDate > ShipDate
ORDER BY DueDate;

-- SQL Server содержит статистику для двух столбцов, но не содержит статистики на случай, когда эти столбцы сравниваются.
-- Исправить это можно, добавив вычисляемый столбец

ALTER TABLE Sales.SalesOrderHeader
ADD DueDateMinusShipDate AS DATEDIFF(day, ShipDate, DueDate);
GO

SELECT SalesOrderID, DueDate, ShipDate
FROM Sales.SalesOrderHeader
WHERE DueDateMinusShipDate > 0
ORDER BY DueDate;
GO

ALTER TABLE Sales.SalesOrderHeader
DROP COLUMN DueDateMinusShipDate;
GO


-- Проблема при использовании переменной
-- Clustered Index Scan (9440)
-- actual plan содержит предупреждение на узле Sort (27370 of 9440) - operator used tempdb to spill data
DECLARE @OrderDate DATETIME='20120901';
SELECT SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE OrderDate > @OrderDate
ORDER BY OrderDate;

-- Clustered Index Scan (27365)
-- actual plan: Sort (27370 of 27366)
SELECT SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE OrderDate > '20120901'
ORDER BY OrderDate;
GO

-- 
-- OPTION (RECOMPILE) указывает SQL Server перекомпилировать план выполнения запроса каждый раз, когда он выполняется
-- материализует значение параметра
DECLARE @OrderDate DATETIME='20120901';
SELECT SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE OrderDate > @OrderDate
ORDER BY OrderDate
OPTION (RECOMPILE);
