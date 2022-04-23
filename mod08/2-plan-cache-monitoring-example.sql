-- 1. �������� ��� ����� 

USE AdventureWorks;
GO
DBCC FREEPROCCACHE
GO

-- 2. ��������� ��� �������
-- �� ������ ������� ���� ������ ������ ����� WHERE soh.SalesOrderID =

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

-- 3. ���� ������. �������� query_hash ��������� ��� ���� ������
SELECT p.objtype, qs.query_hash, p.plan_handle, qp.query_plan, st.[text], p.usecounts
FROM sys.dm_exec_cached_plans AS p
JOIN sys.dm_exec_query_stats AS qs
ON qs.plan_handle = p.plan_handle
CROSS APPLY sys.dm_exec_query_plan(p.plan_handle) AS qp
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS st 
WHERE st.[text] LIKE 'SELECT * FROM ' + 'Sales.SalesOrderHeader%';

-- 4. �������� 'optimize for ad-hoc workloads' (run_value = 0)
EXEC sp_configure 'show advanced options',1
RECONFIGURE
GO
EXEC sp_configure 'optimize for ad hoc workload'

-- 5. �������� �������� 'optimize for ad-hoc workloads' = 1
EXEC sp_configure 'optimize for ad hoc workload', 1
RECONFIGURE
GO
EXEC sp_configure 'optimize for ad hoc workload'

-- 6. ��������� ��� ������� �.2

-- 7. ���� ������. query_plan = NULL; 
SELECT p.objtype, qs.query_hash, p.plan_handle, qp.query_plan, st.[text], p.usecounts
FROM sys.dm_exec_cached_plans AS p
JOIN sys.dm_exec_query_stats AS qs
ON qs.plan_handle = p.plan_handle
CROSS APPLY sys.dm_exec_query_plan(p.plan_handle) AS qp
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS st 
WHERE st.[text] LIKE 'SELECT * FROM ' + 'Sales.SalesOrderHeader%';

-- 8. ������ ������ �� �.2 (��� �� �����)
SELECT * FROM Sales.SalesOrderHeader AS soh 
JOIN Sales.SalesOrderDetail AS sod
ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.SalesOrderID = 43667
AND sod.UnitPrice > 10.00
GO

-- 9. ���� ������. query_plan != NULL ������ � ������� �������; 
SELECT p.objtype, qs.query_hash, p.plan_handle, qp.query_plan, st.[text], p.usecounts
FROM sys.dm_exec_cached_plans AS p
JOIN sys.dm_exec_query_stats AS qs
ON qs.plan_handle = p.plan_handle
CROSS APPLY sys.dm_exec_query_plan(p.plan_handle) AS qp
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS st 
WHERE st.[text] LIKE 'SELECT * FROM ' + 'Sales.SalesOrderHeader%';

-- 10. �������� �������� optimize for ad-hoc workloads = 0
EXEC sp_configure 'optimize for ad hoc workload', 0
RECONFIGURE
GO
