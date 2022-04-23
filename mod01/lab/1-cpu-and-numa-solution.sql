USE master;
GO

---------------------------------------------------------------------
-- 1. �������� ������, ������������ ���������� � ��� � hyperthreading ���������� SQL Server  
-- ������������� DMV sys.dm_os_sys_info
---------------------------------------------------------------------

SELECT cpu_count, hyperthread_ratio FROM sys.dm_os_sys_info;

---------------------------------------------------------------------
-- 2. ��������� ������ ����������� ������������: max degree of parallelism, max worker threads, priority boost
---------------------------------------------------------------------

SELECT * FROM sys.configurations 
WHERE name IN
	('affinity mask',
	'affinity64 mask',
	'cost threshold for parallelism',
	'lightweight pooling',
	'max degree of parallelism',
	'max worker threads',
	'priority boost');

---------------------------------------------------------------------
-- 3. �������� ������, ������������ ���������� � ������������ NUMA 
-- ������������� DMV sys.dm_os_nodes
---------------------------------------------------------------------

SELECT * FROM sys.dm_os_nodes;

---------------------------------------------------------------------
-- 4. ��������� ������, ����������� sys.dm_os_nodes �� �������� node_state_desc
---------------------------------------------------------------------
SELECT OSS.scheduler_id, OSS.status, OSS.parent_node_id
FROM sys.dm_os_schedulers AS OSS;

SELECT OSS.scheduler_id, OSS.status, OSS.parent_node_id, OSN.node_state_desc
FROM sys.dm_os_schedulers AS OSS
JOIN sys.dm_os_nodes AS OSN 
ON OSS.parent_node_id = OSN.node_id;