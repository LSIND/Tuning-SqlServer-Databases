USE AdventureWorks;
GO

-- 1. ������ � ������������� � ����������������
-- Estimated Execution Plan: No JOIN predicate
SELECT *
FROM master.dbo.spt_values AS a
CROSS JOIN master.dbo.spt_values AS b;

-- 2. ��������� ������
-- Compare Showplan � demo2.sqlplan


-- 3. ���������� ���� ��� ������ ��������
-- 3.1. estimated execution plan 
-- 3.2 actual execution plan 
-- warning -> Clustered Index Seek ������� Orders (����������� ����������)
-- ������� ����� actual � estimated ����������� ����� ��� Clustered Index Seek ������� Orders
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


-- 4. ������� �������� �.3
-- ������������� ���������� -- Warning ������
CREATE STATISTICS Orders_OrderId
    ON TSQL.Sales.Orders (orderid)
    WITH FULLSCAN

-- 5. ���������� �������
-- ��������� ������: Estimated Subtree Cost ��� SELECT: > 1.28
-- ����������� ������

SELECT 
	pp.Name,
	pp.ProductLine,
	ss.UnitPrice
FROM Production.Product AS pp 
JOIN Sales.SalesOrderDetail AS ss
ON pp.ProductID=ss.ProductID
WHERE ss.OrderQty > 10


-- 6. �������� ������������ INCLUDE �������

CREATE NONCLUSTERED INDEX ix_SalesOrderDetail_OrderQty
ON Sales.SalesOrderDetail (OrderQty)
INCLUDE (ProductID,UnitPrice)


-- 7. ����� ��������� ������, subtree cost of the actual execution plan < 0.1
SELECT 
	pp.Name,
	pp.ProductLine,
	ss.UnitPrice
FROM Production.Product AS pp 
JOIN Sales.SalesOrderDetail AS ss
ON pp.ProductID=ss.ProductID
WHERE ss.OrderQty > 10;


-- 8. ������� ������
DROP INDEX Sales.SalesOrderDetail.ix_SalesOrderDetail_OrderQty;