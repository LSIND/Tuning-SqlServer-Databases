-- 1. ��������� ������� ��������
-- �������� Powershell �� ����� ��������������, ��������� � ����� ..Tuning-SqlServer-Databases\mod06\Lab\
-- ��������� ������ .\1-start-load.ps1
-- * ���� PS ������ ������ �� ���������� �������� �������, � ������� �������� Set-ExecutionPolicy -ExecutionPolicy Unrestricted
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



---------------------------------------------------------------------
-- 3. ������� ���������� IX_WebResponse_CampaignAdvertID � ������� DBCC SHOW_STATISTICS 
-- ������� ����� �������� ������� Proseware.WebResponse?
---------------------------------------------------------------------



-- ���������� �������� ���������� ����� ������� Proseware.WebResponse
SELECT rows FROM sys.partitions 
WHERE object_id = OBJECT_ID('Proseware.WebResponse');

---------------------------------------------------------------------
-- 4. �������� ���������� ��� ���� ����� (WITH FULLSCAN ��� SAMPLE 100 PERCENT)
---------------------------------------------------------------------



-- ����� ������� ���������� IX_WebResponse_CampaignAdvertID � ������� DBCC SHOW_STATISTICS 
-- ������� ����� �������� ������� Proseware.WebResponse?




-- �������� ��� ���������� ��� ������� Proseware.CampaignAdvert
-- � �������������� 50% ����� �������.




---------------------------------------------------------------------
-- 5. ����� ��������� ������ .\1-start-load.ps1
-- ��������� ������������ ���������� 
-- �������� ���������� � �.1