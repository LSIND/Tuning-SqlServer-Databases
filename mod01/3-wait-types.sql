-- 1. �������� ������ 2-1-hanging-tran.sql � ��������� ����������. �������� update_session_id
-- 2. �������� ������ 2-2-blocked-tran.sql � ��������� ����������. �������� select_session_id

-- 3. �������� �� ������� �����, ��������� ������������ �������. 
-- ������ � select_session_id ����� ��� �������� LCK_M_S
SELECT * FROM sys.dm_os_waiting_tasks 
WHERE session_id > 50;

-- 4. �������� ��� ���� ���������, ������� ����������� ��� ������ ������
-- ���������� select_session_id � ������� WHERE 
-- ������ select_session_id ����� ��� �������� MEMORY_ALLOCATION_EXT
SELECT * FROM sys.dm_exec_session_wait_stats 
WHERE session_id = <select_session_id>;

-- 5. � ������� 2-1-hanging-tran.sql ��������� ������� ROLLBACK; 

-- 6. ���������� select_session_id � ������� WHERE 
-- ������ select_session_id ����� ��� �������� LCK_M_S
SELECT * FROM sys.dm_exec_session_wait_stats 
WHERE session_id = <select_session_id>;

-- ==============================================

-- 7. �������� PAGELATCH � WRITELOG
-- ������� ������� insertTargetEx

USE AdventureWorks;
GO

IF (Object_Id('dbo.insertTargetEx') IS NOT NULL)
	TRUNCATE TABLE dbo.insertTargetEx;
ELSE
CREATE TABLE dbo.insertTargetEx
(
TableId int PRIMARY KEY IDENTITY(1,1),
date1 datetime2
)
GO

-- �������� ���������� �������� �������� DBCC
DBCC SQLPERF('sys.dm_os_wait_stats',clear);

-- 8. ���������� �������� �������� PAGELATCH � WRITELOG
SELECT * FROM sys.dm_os_wait_stats 
WHERE wait_type = 'WRITELOG'
UNION ALL
SELECT * FROM sys.dm_os_wait_stats 
WHERE wait_type like 'PAGELATCH%';

-- 9. �������� "Resource Monitor" -> ������� Disk -> ��������� Disk Queue Length ~ 0

-- 10. �������� Powershell �� ����� ��������������, ��������� � ����� ..Tuning-SqlServer-Databases\mod01
-- ��������� ������ .\start-load.ps1 workload2.sql
-- ������ ps �������� 10 ������� ����� (job), ����������� ���� � ��� �� ������ workload2.sql
-- ����������� ��������� ��������� Disk Queue

-- 11. �������� �������� PAGELATCH � WRITELOG ������ �������

SELECT * FROM sys.dm_os_wait_stats WHERE wait_type = 'WRITELOG'
UNION ALL
SELECT * FROM sys.dm_os_wait_stats WHERE wait_type like 'PAGELATCH%';

-- 12. ������� ������� dbo.insertTargetEx;
DROP TABLE IF EXISTS dbo.insertTargetEx;