-- QueryStore_Demo

-- Регрессии из-за удаленного индекса

--------------------------------------------------------------------------------
-- covering index на таблицу Production.Product
--------------------------------------------------------------------------------

IF EXISTS(SELECT * FROM sys.indexes WHERE name = N'ix_TempProduct' AND object_id = OBJECT_ID(N'Production.Product', N'U'))
BEGIN
	DROP INDEX ix_TempProduct
		ON Production.Product;
END

CREATE NONCLUSTERED INDEX ix_TempProduct
	ON Production.Product ([ProductSubcategoryID])
	INCLUDE (Name, ProductNumber);


--------------------------------------------------------------------------------
-- очистка Query Store
--------------------------------------------------------------------------------

ALTER DATABASE AdventureWorks
	SET QUERY_STORE CLEAR;


--------------------------------------------------------------------------------
-- Work load 1
-- Запустить 6 раз
--------------------------------------------------------------------------------

SELECT C.ProductCategoryID, C.Name AS 'Category', P.Name AS 'ProductName', P.ProductNumber, SUM(D.OrderQty) AS 'OrderQty', SUM(D.LineTotal) AS 'OrderValue'
	FROM [Production].[ProductCategory] AS C
		INNER JOIN Production.Product AS P
			ON P.[ProductSubcategoryID] = C.ProductCategoryID
		LEFT OUTER JOIN Sales.SalesOrderDetail AS D
			ON D.ProductID = P.ProductID
	GROUP BY C.ProductCategoryID, C.Name, P.Name, P.ProductNumber;


--------------------------------------------------------------------------------
-- Work load 2
-- Запустить 4 раза
--------------------------------------------------------------------------------

SELECT C.AccountNumber, C.AccountNumber AS Name, P.Name as 'ProductName', P.ProductNumber, SUM(H.TotalDue) AS 'TotalDue'
	FROM Sales.Customer AS C
		INNER JOIN Sales.SalesOrderHeader AS H
			ON H.CustomerID = C.CustomerID
		INNER JOIN Sales.SalesOrderDetail AS D
			ON D.SalesOrderID = H.SalesOrderID
		INNER JOIN Production.Product AS P
			ON P.ProductID = D.ProductID
	WHERE P.ProductSubcategoryID <= 15
	GROUP BY C.AccountNumber, P.Name, P.ProductNumber;


--------------------------------------------------------------------------------
-- Регрессия work load 1
--------------------------------------------------------------------------------

DROP INDEX ix_TempProduct
	ON Production.Product;

-- Запустить work load 1 -- еще 6 раз