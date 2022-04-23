USE AdventureWorks;
GO

-- 1. Запрос с параллелизмом и предупреждениями
-- Estimated Execution Plan: No JOIN predicate
SELECT *
FROM master.dbo.spt_values AS a
CROSS JOIN master.dbo.spt_values AS b;

-- 2. Сравнение планов
-- Compare Showplan с demo2.sqlplan


-- 3. Одинаковый план для разных запросов
-- 3.1. estimated execution plan 
-- 3.2 actual execution plan 
-- warning -> Clustered Index Seek таблицы Orders (отсутствует статистика)
-- Отличия между actual и estimated количеством строк для Clustered Index Seek таблицы Orders
-- Nested Loops join

SELECT o.orderid, o.orderdate,
od.productid, od.unitprice, od.qty 
FROM TSQL.Sales.Orders AS o 
INNER JOIN TSQL.Sales.OrderDetails AS od 
ON o.orderid = od.orderid ; 

SELECT o.orderid, o.orderdate,
od.productid, od.unitprice, od.qty 
FROM TSQL.Sales.Orders AS o
CROSS APPLY (	SELECT productid, unitprice, qty 
				FROM TSQL.Sales.OrderDetails AS so 
				WHERE so.orderid = o.orderid
			) AS od;


-- 4. Решение проблемы п.3
-- Сгенерировать статистику -- Warning удален
CREATE STATISTICS Orders_OrderId
    ON TSQL.Sales.Orders (orderid)
    WITH FULLSCAN

-- 5. Добавление индекса
-- Выполнить запрос: Estimated Subtree Cost для SELECT: > 1.28
-- Пропущенный индекс

SELECT 
	pp.Name,
	pp.ProductLine,
	ss.UnitPrice
FROM Production.Product AS pp 
JOIN Sales.SalesOrderDetail AS ss
ON pp.ProductID=ss.ProductID
WHERE ss.OrderQty > 10


-- 6. Создание покрывающего INCLUDE индекса

CREATE NONCLUSTERED INDEX ix_SalesOrderDetail_OrderQty
ON Sales.SalesOrderDetail (OrderQty)
INCLUDE (ProductID,UnitPrice)


-- 7. Снова выполнить запрос, subtree cost of the actual execution plan < 0.1
SELECT 
	pp.Name,
	pp.ProductLine,
	ss.UnitPrice
FROM Production.Product AS pp 
JOIN Sales.SalesOrderDetail AS ss
ON pp.ProductID=ss.ProductID
WHERE ss.OrderQty > 10;


-- 8. Удалить индекс
DROP INDEX Sales.SalesOrderDetail.ix_SalesOrderDetail_OrderQty;