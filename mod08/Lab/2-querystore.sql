---------------------------------------------------------------------
-- 1. �������� Powershell �� ����� ��������������, ��������� � ����� ..Tuning-SqlServer-Databases\mod08\lab
-- ��������� ������ .\start-load-ex.ps1 workload2.sql
-- ������ �������� 10 ������� ����� (job), ����������� ���� � ��� �� ������ workload2.sql
---------------------------------------------------------------------

-- 2. �������� �������� �� TSQL
-- Query Store -> Operation Mode (Requested) = Read Write
-- Query Store -> Statistics Collection Interval = 1 minute

-- 3. � Object Explorer ��������� TSQL-> Query Store -> Top Resource Consuming Queries
-- ���������� query id � ����������� �����


---------------------------------------------------------------------
-- 4. �������� ����������� ������
---------------------------------------------------------------------
USE TSQL
GO
CREATE NONCLUSTERED INDEX ix_CampaignResponse_CampaignID
ON Proseware.CampaignResponse (CampaignID)
INCLUDE (ResponseDate,ConvertedToSale,ConvertedSaleValueUSD)
GO


-- 5. � Object Explorer ��������� TSQL-> Query Store -> Tracked Queries.
-- � ������ ������� query id �� �.3
-- �������� ���� -> ������� Force Plan
-- ����������� ����� Top Resource Consuming Queries


---------------------------------------------------------------------
-- 6. ���������� ��������
---------------------------------------------------------------------
CREATE TABLE ##stopload(id int);