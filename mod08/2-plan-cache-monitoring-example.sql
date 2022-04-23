-- 1. Очистить кэш плана 

USE AdventureWorks;
GO
DBCC FREEPROCCACHE
GO

-- 2. Выполнить три запроса
-- Во втором запросе есть лишний пробел после WHERE soh.SalesOrderID =

SELECT * FROM Sales.SalesOrderHeader AS soh 
JOIN Sales.SalesOrderDetail AS sod
ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.SalesOrderID = 43667
AND sod.UnitPrice > 10.00
GO
SELECT * FROM Sales.SalesOrderHeader AS soh 
JOIN Sales.SalesOrderDetail AS sod
ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.SalesOrderID =  43667
AND sod.UnitPrice > 10.00
GO
SELECT * FROM Sales.SalesOrderHeader AS soh 
JOIN Sales.SalesOrderDetail AS sod
ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.SalesOrderID = 43668
AND sod.UnitPrice > 12.00
GO 

-- 3. Кэши планов. Значение query_hash одинаково для трех планов
SELECT p.objtype, qs.query_hash, p.plan_handle, qp.query_plan, st.[text], p.usecounts
FROM sys.dm_exec_cached_plans AS p
JOIN sys.dm_exec_query_stats AS qs
ON qs.plan_handle = p.plan_handle
CROSS APPLY sys.dm_exec_query_plan(p.plan_handle) AS qp
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS st 
WHERE st.[text] LIKE 'SELECT * FROM ' + 'Sales.SalesOrderHeader%';

-- 4. Значение 'optimize for ad-hoc workloads' (run_value = 0)
EXEC sp_configure 'show advanced options',1
RECONFIGURE
GO
EXEC sp_configure 'optimize for ad hoc workload'

-- 5. Изменить значение 'optimize for ad-hoc workloads' = 1
EXEC sp_configure 'optimize for ad hoc workload', 1
RECONFIGURE
GO
EXEC sp_configure 'optimize for ad hoc workload'

-- 6. Выполнить три запроса п.2

-- 7. Кэши планов. query_plan = NULL; 
SELECT p.objtype, qs.query_hash, p.plan_handle, qp.query_plan, st.[text], p.usecounts
FROM sys.dm_exec_cached_plans AS p
JOIN sys.dm_exec_query_stats AS qs
ON qs.plan_handle = p.plan_handle
CROSS APPLY sys.dm_exec_query_plan(p.plan_handle) AS qp
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS st 
WHERE st.[text] LIKE 'SELECT * FROM ' + 'Sales.SalesOrderHeader%';

-- 8. Первый запрос из п.2 (тот же текст)
SELECT * FROM Sales.SalesOrderHeader AS soh 
JOIN Sales.SalesOrderDetail AS sod
ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.SalesOrderID = 43667
AND sod.UnitPrice > 10.00
GO

-- 9. Кэши планов. query_plan != NULL только у первого запроса; 
SELECT p.objtype, qs.query_hash, p.plan_handle, qp.query_plan, st.[text], p.usecounts
FROM sys.dm_exec_cached_plans AS p
JOIN sys.dm_exec_query_stats AS qs
ON qs.plan_handle = p.plan_handle
CROSS APPLY sys.dm_exec_query_plan(p.plan_handle) AS qp
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS st 
WHERE st.[text] LIKE 'SELECT * FROM ' + 'Sales.SalesOrderHeader%';

-- 10. Изменить свойство optimize for ad-hoc workloads = 0
EXEC sp_configure 'optimize for ad hoc workload', 0
RECONFIGURE
GO
