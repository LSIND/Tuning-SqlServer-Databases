USE AdventureWorks;
GO

-- 1. ����� ����������� ��7, ��������� ��� _setup.sql, �������������� ������ ����������


-- 2. ��������� actual execution plan ��� ������� � ..\Tuning-SqlServer-Databases\mod07\lab\plan1.sqlplan
-- ������� ����: Clustered Index Scan (Clustered) -> � ����������� ���� ������� ����� Estimated Number of Rows (~ 3.74) � Actual Number of Rows (> 1.8 million).
-- ��������� ����� ���������� �������

SELECT c.CampaignName, c.CampaignStartDate, c.CampaignEndDate,
st.Name, SUM(cr.ConvertedSaleValueUSD) AS SalesValue
FROM Proseware.Campaign AS c
JOIN Proseware.CampaignResponse AS cr
ON cr.CampaignID = c.CampaignID
JOIN Sales.SalesTerritory AS st
ON st.TerritoryID = c.CampaignTerritoryID
WHERE cr.ConvertedToSale = 1
GROUP BY c.CampaignName, c.CampaignStartDate, c.CampaignEndDate, st.Name
OPTION (RECOMPILE); --RECOMPILE -> ���� �� �� ����



-- 3. ����������� ���������� ��� ������ Proseware.Campaign � Proseware.CampaignResponse 
ALTER TABLE Proseware.Campaign REBUILD
GO
ALTER TABLE Proseware.CampaignResponse REBUILD;
GO

-- 4. ��������� ������ �.2
-- �������� ���� � ������ ..\Tuning-SqlServer-Databases\mod07\lab\plan1.sqlplan
-- estimated � actual row counts ������ ���������