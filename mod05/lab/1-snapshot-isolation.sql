
-- 1. ��������� ������ setup.sql
-- ��������� ��������� ����������


---------------------------------------------------------------------
-- 2. �������� ���������� �������� 
---------------------------------------------------------------------



---------------------------------------------------------------------
-- 3. ������ ������� ��������
-- �������� Powershell �� ����� ��������������, ��������� � ����� ..Tuning-SqlServer-Databases\mod05\lab
-- ��������� ������ .\start-load-ex.ps1 workload1.sql
-- ������ ps �������� 10 ������� ����� (job), ����������� ���� � ��� �� ������ workload1.sql
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 4. �������� ���������� LOCK WAIT �� ��������� ������� #task3
-- wait_type LIKE 'LCK%'
---------------------------------------------------------------------
DROP TABLE IF EXISTS #task3;
 
SELECT wait_type, waiting_tasks_count, wait_time_ms, 
max_wait_time_ms, signal_wait_time_ms
INTO #task3
FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'LCK%' 
AND wait_time_ms > 0
ORDER BY wait_time_ms DESC;

---------------------------------------------------------------------
-- 5. �������� ������� �������� ���������� - SNAPSHOT 
-- [AdventureWorks] -> Properties -> Miscellaneous -> Allow Snapshot Isolation = True
---------------------------------------------------------------------


---------------------------------------------------------------------
-- 6. �������� �������� ��������� Proseware.up_Campaign_Report � �������������� ������ �������� ���������� SNAPSHOT
---------------------------------------------------------------------
USE AdventureWorks;
GO



---------------------------------------------------------------------
-- 7. ����� �������� ���������� �������� 
---------------------------------------------------------------------



---------------------------------------------------------------------
-- 8. �������� ��������� ������ .\start-load-ex.ps1 workload1.sql � ..Tuning-SqlServer-Databases\mod05\lab
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 9. �������� ���������� LOCK WAIT �� ��������� ������� #task8 (�� �������� � #task3)
-- wait_type LIKE 'LCK%'
---------------------------------------------------------------------
DROP TABLE IF EXISTS #task8;
 


---------------------------------------------------------------------
-- 10. �������� ����� �������� Lock Wait Time
---------------------------------------------------------------------
SELECT SUM(t3.wait_time_ms) AS baseline_wait_time_ms,
SUM(t8.wait_time_ms) AS SNAPSHOT_wait_time_ms
FROM #task3 AS t3
FULL OUTER JOIN #task8 AS t8
ON t8.wait_type = t3.wait_type;