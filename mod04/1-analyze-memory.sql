USE master;
GO


-- locked_page_allocations_kb 
-- arge_page_allocations_kb
SELECT *
FROM sys.dm_os_process_memory;

-- memory clerks
SELECT *
FROM sys.dm_os_memory_clerks;

SELECT [type], SUM(pages_kb) as PageKb
FROM sys.dm_os_memory_clerks
GROUP BY [type]
ORDER BY PageKb DESC;

-- memory pools
-- для наблюдения за использованием кэша и для выявления случаев ненадлежащего кэширования
SELECT *
FROM sys.dm_os_memory_pools;


-- Сравнить значения physical_memory_in_use_kb и virual_address_space_committed_kb
-- со значениями в столбцах Working Set(KB) and Commit(KB) для процесса sqlservr.exe в Resource Monitor
select
physical_memory_in_use_kb AS [Working Set(KB)],
locked_page_allocations_kb / 1024,
total_virtual_address_space_kb / 1024/1024 AS TotalVirtual_GB,
virtual_address_space_committed_kb AS [Commit(KB)],
process_physical_memory_low,
process_virtual_memory_low
from sys.dm_os_process_memory;
GO