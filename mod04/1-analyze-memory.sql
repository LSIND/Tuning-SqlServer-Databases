USE master;
GO


SELECT *
FROM sys.dm_os_process_memory;



-- �������� �������� physical_memory_in_use_kb � virual_address_space_committed_kb
-- �� ���������� � �������� Working Set(KB) and Commit(KB) ��� �������� sqlservr.exe � Resource Monitor
select
physical_memory_in_use_kb AS [Working Set(KB)],
locked_page_allocations_kb / 1024,
total_virtual_address_space_kb / 1024/1024 AS TotalVirtual_GB,
virtual_address_space_committed_kb AS [Commit(KB)],
process_physical_memory_low,
process_virtual_memory_low
from sys.dm_os_process_memory;
GO