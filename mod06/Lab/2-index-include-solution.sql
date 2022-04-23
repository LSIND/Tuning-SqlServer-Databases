---------------------------------------------------------------------
-- 1. ��������� ������� ��������, �������� ������ Workload.sql.
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 2. �������� ������, ��������� ��� ������� ������� Proseware.WebResponse table
---------------------------------------------------------------------

SELECT i.name, i.type_desc, i.is_unique, c.*
FROM sys.indexes AS i
JOIN sys.index_columns AS ic
ON ic.index_id = i.index_id
AND ic.object_id = i.object_id
JOIN sys.columns AS c
ON c.column_id = ic.column_id
AND c.object_id = i.object_id
WHERE i.object_id = OBJECT_ID('Proseware.WebResponse');

EXEC sp_help 'Proseware.WebResponse';

---------------------------------------------------------------------
-- 3. Tools -> Database Engine Tuning Advisor
-- ��������� ������ ������������������ ��� ���� ������ AdventureWorks, ��� ���� �������� - 2-workload.sql.
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 4. ������� ������������ � ����������� �������� �� Database Engine Tuning Advisor
-- �������� estimated execution plan ��� 2-workload.sql
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 5. ������� ������������ ������ IX_WebResponse_log_date_CampaignAdvertID
---------------------------------------------------------------------

DROP INDEX IF EXISTS Proseware.WebResponse.IX_WebResponse_log_date_CampaignAdvertID;
GO

---------------------------------------------------------------------
-- 5. �������� ����������� ������ � INCLUDE ������ IX_WebResponse_log_date_CampaignAdvertID_browser_name
-- �� ������� log_date, CampaignAdvertID, browser_name 
-- INCLUDE �� ������� page_visit_time_seconds
---------------------------------------------------------------------

CREATE INDEX IX_WebResponse_log_date_CampaignAdvertID_browser_name 
ON Proseware.WebResponse (log_date, CampaignAdvertID,browser_name)
INCLUDE (page_visit_time_seconds);

---------------------------------------------------------------------
-- 6. ����� ��������� 2-workload.sql
-- ���������, ��� ������������� ����� ������ IX_WebResponse_log_date_CampaignAdvertID_browser_name (���� �������)
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 7. ��������� ������ � sys.dm_db_index_usage_stats ��� ��������� ���������� � ���, ��� ������ ��� �����������
---------------------------------------------------------------------
SELECT i.name, iu.user_seeks, iu.user_scans
FROM sys.dm_db_index_usage_stats AS iu
JOIN sys.indexes AS i
ON i.index_id = iu.index_id
AND i.object_id = iu.object_id
WHERE iu.object_id = OBJECT_ID('Proseware.WebResponse');