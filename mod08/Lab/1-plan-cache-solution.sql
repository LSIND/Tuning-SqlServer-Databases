---------------------------------------------------------------------
-- 1. ��������� ������ _setup.sql, ������� ����������
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 2. �������� Powershell �� ����� ��������������, ��������� � ����� ..Tuning-SqlServer-Databases\mod08\lab
-- ��������� ������ .\start-load-ex.ps1 workload1.sql
-- ������ �������� 10 ������� ����� (job), ����������� ���� � ��� �� ������ workload1.sql
---------------------------------------------------------------------


---------------------------------------------------------------------
-- 3. ��������� ������ � sys.dm_exec_query_stats, ����� ����� ����� ���������� query_hash �� ���������� �������
---------------------------------------------------------------------
USE AdventureWorks;
GO

SELECT TOP(1) query_hash, COUNT(1) AS cnt 
FROM sys.dm_exec_query_stats 
GROUP BY query_hash 
ORDER BY cnt DESC


---------------------------------------------------------------------
-- 4. ���������� ������, ���������� ���� ���� �����
-- �������� � ������� WHERE �������� ������� query_hash �� �.3
---------------------------------------------------------------------
SELECT TOP(1) [text]
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) AS st
WHERE query_hash = 0x19F397846F2DCE71

---------------------------------------------------------------------
-- 5. ���������� �������� ���������, ���������� ���� ����
-- ��������� ������ � INFORMATION_SCHEMA.ROUTINES
---------------------------------------------------------------------
SELECT * 
FROM INFORMATION_SCHEMA.ROUTINES AS r
WHERE r.ROUTINE_DEFINITION LIKE '%cn.CampaignID%';
GO

---------------------------------------------------------------------
-- 6. �������� �������� ��������� Proseware.up_CampaignReport
-- ������� ������������� ������������� SQL - ��� ������� ������� ��������� ����
---------------------------------------------------------------------

ALTER PROCEDURE Proseware.up_CampaignReport
(@CampaignName varchar(20))
AS

	SELECT	cn.CampaignID,
			cn.CampaignName,
			cn.CampaignStartDate,
			cn.CampaignEndDate,
			st.Name,
			cr.ResponseDate,
			cr.ConvertedToSale,
			cr.ConvertedSaleValueUSD
	FROM Proseware.Campaign AS cn
	JOIN Sales.SalesTerritory AS st
	ON st.TerritoryID = cn.CampaignTerritoryID
	JOIN Proseware.CampaignResponse AS cr
	ON cr.CampaignID = cn.CampaignID
	WHERE CampaignName = @CampaignName;
GO



---------------------------------------------------------------------
-- 7. ���������, ��� �� Proseware.up_CampaignReport ���������� Single Query Plan
-- ��������� ������ � sys.dm_exec_procedure_stats ��� ����������� ����� ��� Proseware.up_CampaignReport.
-- ���� ����
---------------------------------------------------------------------
SELECT *
FROM sys.dm_exec_procedure_stats
WHERE object_id = object_id('Proseware.up_CampaignReport');

---------------------------------------------------------------------
-- 8. ���������� ��������
---------------------------------------------------------------------
CREATE TABLE ##stopload(id int);