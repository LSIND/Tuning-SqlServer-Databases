USE AdventureWorks;
GO

-- 1. Упрощение запроса
-- Создайте Estimated Execution Plan (Ctrl+L)
-- Отсутствует scan Sales.SalesOrderHeader
-- FK Sales.SalesOrderDetail -> Sales.SalesOrderHeader не используется

SELECT pp.Name
FROM Production.Product pp 
JOIN Sales.SalesOrderDetail AS ss
ON pp.ProductID=ss.ProductID
JOIN Sales.SalesOrderHeader AS oh
ON ss.SalesOrderID=oh.SalesOrderID;

-- 2. Упрощение запроса
-- Создайте Estimated Execution Plan (Ctrl+L)
-- В плане нет ссылки на таблицу HumanResources.Employee
-- В столбце SickLeaveHours содержится ограничение, что значение <= 120
-- По данному запросу нет результирующего набора - запрос упрощен.
SELECT * FROM HumanResources.Employee 
WHERE SickLeaveHours = 500;

-- Проверить CHECK CONSTRAINT:
SELECT CHECK_CLAUSE FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
WHERE CONSTRAINT_NAME = 'CK_Employee_SickLeaveHours'

-- 3. Тривиальный план
-- Создайте Estimated Execution Plan (Ctrl+L)
-- Включите Actual Execution Plan (Ctrl+M). Выполните запрос
-- Выберите оператор SELECT (cost 0%) -> свойства (F4)
-- Уровень оптимизации "Optimization Level" - "TRIVIAL"
SELECT * 
FROM HumanResources.Employee;

-- *Когда запрос, имеющий указание HINT ('QUERY_PLAN_PROFILE'), завершает выполнение, создается расширенное событие query_plan_profile, которое предоставляет фактический план выполнения.
SELECT * 
FROM HumanResources.Employee
OPTION(USE HINT ('QUERY_PLAN_PROFILE'));


-- 4. Правила трансформации
-- 4.1. Создайте временную таблицу # и поместите в нее значения из sys.dm_exec_query_transformation_stats

DROP TABLE IF EXISTS #transformation_stats_before_query_execution;
DROP TABLE IF EXISTS #transformation_stats_after_query_execution;
DROP TABLE IF EXISTS #result;

SELECT *
INTO #transformation_stats_before_query_execution
FROM sys.dm_exec_query_transformation_stats;

-- 4.2. Запрос с RECOMPILE
SELECT pp.ProductID, Count(*) ProductCount 
INTO #result
FROM Production.Product pp JOIN Sales.SalesOrderDetail ss
ON pp.ProductID=ss.ProductID
WHERE ss.OrderQty > 10
GROUP BY pp.ProductID
OPTION (RECOMPILE);

SELECT *
INTO #transformation_stats_after_query_execution
FROM sys.dm_exec_query_transformation_stats;

SELECT * FROM #transformation_stats_after_query_execution WHERE succeeded > 0
EXCEPT
SELECT * FROM #transformation_stats_before_query_execution ;

DROP TABLE IF EXISTS #result;
GO

-- WITH RECOMPILE, SP и Dynamic SQL

CREATE OR ALTER PROCEDURE GetSalesInfo (@SalesPersonID INT = NULL)
AS
DECLARE  @Recompile BIT = 0, @SQLString NVARCHAR(500)

SELECT @SQLString = N'SELECT SalesOrderId, OrderDate FROM Sales.SalesOrderHeader WHERE SalesPersonID = @SalesPersonID'

IF @SalesPersonID IS NULL
BEGIN
     SET @Recompile = 1
END

IF @Recompile = 1
BEGIN
    SET @SQLString = @SQLString + N' OPTION(RECOMPILE)'
END

EXEC sp_executesql @SQLString
    ,N'@SalesPersonID INT'
    ,@SalesPersonID = @SalesPersonID
GO
-------------

EXEC GetSalesInfo 282

DROP PROC IF EXISTS GetSalesInfo;
GO