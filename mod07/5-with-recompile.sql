USE AdventureWorks;
GO

-- 1. Index Scan. 
-- Это связано с тем, что SQL Server не может реализовать надлежащие оптимизации, поскольку не может знать значение локальной переменной до наступления времени выполнения.

SET STATISTICS IO, TIME ON;

DECLARE @SalesPersonID INT;
SELECT @SalesPersonID = 288;

SELECT SalesOrderId, OrderDate
FROM Sales.SalesOrderHeader
WHERE SalesPersonID = @SalesPersonID;
GO


-- 2. WITH RECOMPILE
-- Чтобы помочь оптимизатору запросов сделать правильный выбор, следует предоставить ему указание запроса.
-- logical reads 698 против 409
-- Параметр RECOMPILE предписывает компилятору запросов заменить переменную на ее значение.

SET STATISTICS IO, TIME ON;

DECLARE @SalesPersonID INT;
SELECT @SalesPersonID = 288;

SELECT SalesOrderId, OrderDate
FROM Sales.SalesOrderHeader
WHERE SalesPersonID= @SalesPersonID
OPTION (RECOMPILE);