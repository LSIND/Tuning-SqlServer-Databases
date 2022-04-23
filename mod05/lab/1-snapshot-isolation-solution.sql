
-- 1. ��������� ������ setup.sql
-- ��������� ��������� ����������


---------------------------------------------------------------------
-- 2. �������� ���������� �������� 
---------------------------------------------------------------------
DBCC SQLPERF('sys.dm_os_wait_stats',CLEAR);



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

USE [master]
GO

GO
ALTER DATABASE [AdventureWorks] SET ALLOW_SNAPSHOT_ISOLATION ON
GO

---------------------------------------------------------------------
-- 6. �������� �������� ��������� Proseware.up_Campaign_Report � �������������� ������ �������� ���������� SNAPSHOT
---------------------------------------------------------------------
USE AdventureWorks;
GO

ALTER PROC Proseware.up_Campaign_Report
AS
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SELECT TOP 10 * FROM Sales.SalesTerritory AS T
	JOIN (
		SELECT CampaignTerritoryID, 
		DATEPART(MONTH, CampaignStartDate) as start_month_number,
		DATEPART(MONTH, CampaignEndDate) as end_month_number, 
		COUNT(*) AS campaign_count
		FROM Proseware.Campaign 
		GROUP BY CampaignTerritoryID, DATEPART(MONTH, CampaignStartDate),DATEPART(MONTH, CampaignEndDate)
	) AS x
	ON x.CampaignTerritoryID = T.TerritoryID
	ORDER BY campaign_count;
GO


---------------------------------------------------------------------
-- 7. ����� �������� ���������� �������� 
---------------------------------------------------------------------
DBCC SQLPERF('sys.dm_os_wait_stats',CLEAR);


---------------------------------------------------------------------
-- 8. �������� ��������� ������ .\start-load-ex.ps1 workload1.sql � ..Tuning-SqlServer-Databases\mod05\lab
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 9. �������� ���������� LOCK WAIT �� ��������� ������� #task8
-- wait_type LIKE 'LCK%'
---------------------------------------------------------------------
DROP TABLE IF EXISTS #task8;
 
SELECT wait_type, waiting_tasks_count, wait_time_ms, 
max_wait_time_ms, signal_wait_time_ms
INTO #task8
FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'LCK%' 
AND wait_time_ms > 0
ORDER BY wait_time_ms DESC;

---------------------------------------------------------------------
-- 10. �������� ����� �������� Lock Wait Time
---------------------------------------------------------------------
SELECT SUM(t3.wait_time_ms) AS baseline_wait_time_ms,
SUM(t8.wait_time_ms) AS SNAPSHOT_wait_time_ms
FROM #task3 AS t3
FULL OUTER JOIN #task8 AS t8
ON t8.wait_type = t3.wait_type;