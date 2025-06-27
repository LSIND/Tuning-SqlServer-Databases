USE AdventureWorks;
GO

-- 1. Информация о plan cache stores

SELECT *
FROM sys.dm_os_memory_cache_counters
WHERE name in ('Object Plans','SQL Plans','Bound Trees','Extended Stored Procedures');

-- 2. Plan Cache Store Buckets
SELECT cc.name, buckets_count
FROM sys.dm_os_memory_cache_hash_tables AS ht
JOIN sys.dm_os_memory_cache_counters AS cc
ON ht.cache_address = cc.cache_address
WHERE cc.name IN ('Object Plans','SQL Plans','Bound Trees','Extended Stored Procedure');


--3. Список атрибутов для plan cache key:
-- https://docs.microsoft.com/ru-ru/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-plan-attributes-transact-sql?view=sql-server-ver15

SELECT pa.*
FROM (SELECT TOP(1) plan_handle FROM sys.dm_exec_cached_plans) AS cp
CROSS APPLY sys.dm_exec_plan_attributes(cp.plan_handle) AS pa
WHERE is_cache_key = 1;

-- 4. Проверка количества доступной целевой памяти
SELECT visible_target_kb FROM sys.dm_os_sys_info;

-- 5. cost information about query plans in the SQL Plans and Object Plans plan cache stores.
SELECT e.[type] AS cache_type, st.[text], p.objtype, p.usecounts,
p.size_in_bytes,e.disk_ios_count, e.context_switches_count,
e.pages_kb AS memory_kB, e.original_cost, e.current_cost
FROM sys.dm_exec_cached_plans AS p
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st
JOIN sys.dm_os_memory_cache_entries AS e
ON p.memory_object_address = e.memory_object_address
WHERE p.cacheobjtype = 'Compiled Plan'
AND e.type IN ('CACHESTORE_SQLCP','CACHESTORE_OBJCP')
ORDER BY e.[type], p.objtype, e.current_cost DESC


-- 6. Очистка кэша с помощью DBCC FREEPROCCACHE
SELECT COUNT(*) AS plan_count 
FROM sys.dm_exec_cached_plans;

-- Удаляет все элементы / записи из кэша планов
DBCC FREEPROCCACHE;

-- Удаляет все неиспользуемые элементы из всех кэшей.
DBCC FREESYSTEMCACHE ('ALL');  -- Ключевое слово ALL указывает все поддерживаемые кэши.

-- Освобождение записей из кэшей после прекращения их использования
DBCC FREESYSTEMCACHE ('ALL') WITH MARK_IN_USE_FOR_REMOVAL;  

SELECT COUNT(*) AS plan_count 
FROM sys.dm_exec_cached_plans;



-- 7. Adhoc кэш

SELECT objtype, cacheobjtype, 
  AVG(usecounts) AS Avg_UseCount, 
  SUM(refcounts) AS AllRefObjects, 
  SUM(CAST(size_in_bytes AS bigint))/1024 AS Size_KB
FROM sys.dm_exec_cached_plans
WHERE objtype = 'Adhoc' AND usecounts = 1
GROUP BY objtype, cacheobjtype;

-- FORCE PARAMETERIZATION - не рекомендуется

SELECT name, is_parameterization_forced FROM sys.databases;

-- Одинаковые планы при разном результирующем наборе
-- Автоматический подбор параметров (auto-parameterization)
SELECT * FROM Sales.CreditCard WHERE CreditCardID = 11;
SELECT * FROM Sales.CreditCard WHERE CreditCardID = 207;

SELECT ProductID, [Name], SellEndDate
FROM Production.Product
WHERE ISNULL(SellEndDate, '19900101') > '20130504';

/*
use master;
GO
 --Forced
ALTER DATABASE AdventureWorks SET PARAMETERIZATION FORCED

--Simple
ALTER DATABASE AdventureWorks SET PARAMETERIZATION SIMPLE */

-------------------------------------------------------


-- 8. Рекомпиляция хранимой процедуры
-- 8.1. Выполнить ХП  -> пустой результирующий набор
EXECUTE dbo.uspGetOrderTrackingBySalesOrderID @SalesOrderId = 100;

-- 8.2. Закэшированный план для uspGetOrderTrackingBySalesOrderID
-- Значение XML -> графический план запроса .sqlplan
SELECT p.objtype, p.bucketid, p.plan_handle, qp.query_plan, pa.value AS set_options, st.[text]
FROM sys.dm_exec_cached_plans AS p
CROSS APPLY sys.dm_exec_query_plan(p.plan_handle) AS qp
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS st 
CROSS APPLY sys.dm_exec_plan_attributes(p.plan_handle) AS pa
WHERE st.objectid = object_id('uspGetOrderTrackingBySalesOrderID')
AND pa.attribute = 'set_options';

-- 8.3 Изменение свойств сессии. ARITHABORT = 1 - Завершает запрос, если во время выполнения возникает ошибка переполнения или деления на ноль.
SELECT SESSIONPROPERTY('ARITHABORT'); -- should return 1
SET ARITHABORT OFF;
SELECT SESSIONPROPERTY('ARITHABORT'); -- should return 0

-- 8.4. Снова выполнить ХП  -> пустой результирующий набор
EXECUTE dbo.uspGetOrderTrackingBySalesOrderID @SalesOrderId = 100;

-- 8.5 Два закэшированных плана для uspGetOrderTrackingBySalesOrderID
-- различные plan_handle и set_options, но одинаковый bucketid

SELECT p.objtype, p.bucketid, p.plan_handle, qp.query_plan, pa.value AS set_options, st.[text]
FROM sys.dm_exec_cached_plans AS p
CROSS APPLY sys.dm_exec_query_plan(p.plan_handle) AS qp
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS st 
CROSS APPLY sys.dm_exec_plan_attributes(p.plan_handle) AS pa
WHERE st.objectid = object_id('uspGetOrderTrackingBySalesOrderID')
AND pa.attribute = 'set_options';


-- 8.6. sp_recompile
EXECUTE sp_recompile 'dbo.uspGetOrderTrackingBySalesOrderID';

-- 8.7. При выполнении кода в 8.5 планов кэширования не будет. 


-- 9. Автоматический подбор параметров (auto-parameterization)
-- 9.1. ad-hoc T-SQL statement which will be auto-parameterized.
SELECT SalesOrderID, OrderDate FROM Sales.SalesOrderHeader 
WHERE SalesOrderID = 43683;

-- 9.2. Закэшированный план 
-- Содержит только SELECT operator.
-- Просмотреть SELECT как XML - Show Execution Plan XML.
-- "ParameterizedText" - план запроса с параметром.
-- "ParameterizedPlanHandle" ссылается на другой дескриптор плана
SELECT p.objtype, p.bucketid, p.plan_handle, qp.query_plan, st.[text]
FROM sys.dm_exec_cached_plans AS p
CROSS APPLY sys.dm_exec_query_plan(p.plan_handle) AS qp
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS st 
WHERE st.[text] LIKE 'SELECT SalesOrderID, OrderDate FROM Sales.SalesOrderHeader%';

-- 9.3. "ParameterizedPlanHandle" - подставить значение
-- Изучить основной план запроса
SELECT query_plan FROM sys.dm_exec_query_plan(0x06000700DAF5B008C0F0EA844501000001000000000000000000000000000000000000000000000000000000);


-- 10. sys.dm_exec_cached_plans: Возвращает строку для каждого плана запроса, кэшируемого SQL Server
-- refcounts > 1 - Число объектов кэша, ссылающихся на данный объект кэша. 
SELECT plan_handle, refcounts, usecounts, size_in_bytes, cacheobjtype, objtype   
FROM sys.dm_exec_cached_plans;  
GO  


-- 11. sys.dm_exec_text_query_plan: Возвращает инструкцию Showplan в текстовом формате 
-- аналог sys.dm_exec_query_plan
SELECT * FROM sys.dm_exec_requests  
WHERE session_id = 55; 

SELECT query_plan   
FROM sys.dm_exec_text_query_plan (0x06000700EA222729D0E2EA844501000001000000000000000000000000000000000000000000000000000000,0,-1);  


-- Поиск предупреждений в кэшированных планах
SELECT 
    qs.query_hash,
    qs.query_plan_hash,
    qp.query_plan,
    qs.execution_count,
    qs.total_worker_time
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE CAST(qp.query_plan AS NVARCHAR(MAX)) LIKE '%<Warnings>%';