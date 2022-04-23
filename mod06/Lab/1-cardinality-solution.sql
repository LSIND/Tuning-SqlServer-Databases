-- 1. ��������� ������� ��������
-- �������� Powershell �� ����� ��������������, ��������� � ����� ..Tuning-SqlServer-Databases\mod06\Lab\
-- ��������� ������ .\1-start-load.ps1
-- * ���� PS ������ ������ �� ���������� �������� �������, � ������� �������� Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
-- ������ ps �������� 10 workers, ����������� ���� � ��� �� ������ 1-start-load-sql.sql
-- ��������� ������������ ���������� (��������, Finished after  00:00:19.4165261)
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 2. ����������� ���������� �� sys.stats ��� ������ Proseware.WebResponse, 
-- Proseware.Campaign, Proseware.CampaignAdvert.
-- ��������� �� ���������� ����������?
---------------------------------------------------------------------
USE AdventureWorks;
GO

SELECT OBJECT_NAME(object_id), STATS_DATE(object_id, stats_id) stats_date, * 
FROM sys.stats 
WHERE OBJECT_NAME(object_id) IN ('Campaign','CampaignAdvert','WebResponse')
ORDER BY object_id, stats_id;

---------------------------------------------------------------------
-- 3. ������� ���������� IX_WebResponse_CampaignAdvertID � ������� DBCC SHOW_STATISTICS 
-- ������� ����� �������� ������� Proseware.WebResponse?
---------------------------------------------------------------------
DBCC SHOW_STATISTICS ('Proseware.WebResponse','IX_WebResponse_CampaignAdvertID');


-- ���������� �������� ���������� ����� ������� Proseware.WebResponse
SELECT rows FROM sys.partitions 
WHERE object_id = OBJECT_ID('Proseware.WebResponse');

---------------------------------------------------------------------
-- 4. �������� ���������� ��� ���� ����� (WITH FULLSCAN ��� SAMPLE 100 PERCENT)
---------------------------------------------------------------------
UPDATE STATISTICS Proseware.WebResponse WITH FULLSCAN;


-- ����� ������� ���������� IX_WebResponse_CampaignAdvertID � ������� DBCC SHOW_STATISTICS 
-- ������� ����� �������� ������� Proseware.WebResponse?
DBCC SHOW_STATISTICS ('Proseware.WebResponse','IX_WebResponse_CampaignAdvertID');

-- �������� ��� ���������� ��� ������� Proseware.CampaignAdvert
-- � �������������� 50% ����� �������.
UPDATE STATISTICS Proseware.CampaignAdvert WITH SAMPLE 50 PERCENT;

---------------------------------------------------------------------
-- 5. ����� ��������� ������ .\1-start-load.ps1
-- ��������� ������������ ���������� 
-- �������� ���������� � �.1