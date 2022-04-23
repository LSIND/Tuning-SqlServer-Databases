USE AdventureWorks;
GO

-- 1. Суммарная статистика производительности для кэшированных планов запросов
-- creation_time (datetime) - Время компиляции плана.
SELECT * FROM sys.dm_exec_query_stats;

-- 2. Extended Events; The sql_statement_recompile event tracks recompiles at statement level; an event is logged each time a statement is recompiled. The reason for recompilation is provided in the recompile_cause column.
SELECT * FROM sys.dm_xe_object_columns 
WHERE object_name='sql_statement_recompile';

-- PLAN CACHE BLOAT
-- 3. Количество и размер планов, которые были использованы 1 раз
SELECT objtype, cacheobjtype, COUNT(*) AS single_use_plans, SUM(size_in_bytes) / 1024.0 / 1024.0 AS size_in_mb
FROM sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE objtype IN ('Adhoc', 'Prepared')
AND usecounts = 1
GROUP BY objtype, cacheobjtype;


-- 4. Поиск планов для похожих запросов
WITH planCTE
AS
(
SELECT query_hash, MAX(plan_handle) AS plan_handle, COUNT(*) AS cnt
FROM sys.dm_exec_query_stats
GROUP BY query_hash
HAVING COUNT(*) > 0 -- Можно изменить значение
)
SELECT p.* , st.[text]
FROM planCTE AS p
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS st;

-- 5. Размер планов в кб

SELECT creation_time, last_grant_kb, st.[text]
FROM sys.dm_exec_query_stats AS p
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS st
ORDER BY last_grant_kb DESC;

-- 6. Top 10 Most Expensive Cached Plans by Average Execution Time
SELECT TOP(10) OBJECT_NAME(st.objectid, st.dbid) AS obj_name,
qs.creation_time,
qs.last_execution_time,
SUBSTRING (st.[text],
(qs.statement_start_offset/2)+1,
(( CASE statement_end_offset
WHEN -1 THEN DATALENGTH(st.[text])
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2)+1
) AS sub_statement_text,
[text],
query_plan,
total_worker_time,
qs.execution_count,
qs.total_elapsed_time / qs.execution_count AS avg_duration
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
ORDER BY avg_duration DESC;

-- 7. Top 10 Most Expensive Cached Plans by Average CPU Consumption
SELECT TOP(10) OBJECT_NAME(st.objectid, st.dbid) AS obj_name,
qs.creation_time,
qs.last_execution_time,
SUBSTRING (st.[text],
(qs.statement_start_offset/2)+1,
(( CASE statement_end_offset
WHEN -1 THEN DATALENGTH(st.[text])
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2)+1
) AS sub_statement_text,
[text],
query_plan,
total_worker_time,
qs.execution_count,
qs.total_worker_time / qs.execution_count AS avg_cpu_time,
qs.total_elapsed_time / qs.execution_count AS avg_elapsed_time
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
ORDER BY avg_cpu_time DESC;


-- 8. Top 10 Most Expensive Cached Plans by Average Logical Reads
SELECT TOP(10) OBJECT_NAME(st.objectid, st.dbid) AS obj_name,
qs.creation_time,
qs.last_execution_time,
SUBSTRING (st.[text],
(qs.statement_start_offset/2)+1,
(( CASE statement_end_offset
WHEN -1 THEN DATALENGTH(st.[text])
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2)+1
) AS sub_statement_text,
[text],
query_plan,
total_worker_time,
qs.execution_count,
qs.total_logical_reads / qs.execution_count AS avg_logical_reads,
qs.total_elapsed_time / qs.execution_count AS avg_duration
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
ORDER BY avg_logical_reads DESC;