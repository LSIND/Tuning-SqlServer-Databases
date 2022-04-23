USE AdventureWorks;
GO

-- 1. Перед выполнением ЛР7, выполнить код _setup.sql, предварительно изучив инструкции


-- 2. Сохранить actual execution plan для запроса в ..\Tuning-SqlServer-Databases\mod07\lab\plan1.sqlplan
-- Изучить план: Clustered Index Scan (Clustered) -> в всплывающем окне отличие между Estimated Number of Rows (~ 3.74) и Actual Number of Rows (> 1.8 million).
-- Запомнить время выполнения запроса

SELECT c.CampaignName, c.CampaignStartDate, c.CampaignEndDate,
st.Name, SUM(cr.ConvertedSaleValueUSD) AS SalesValue
FROM Proseware.Campaign AS c
JOIN Proseware.CampaignResponse AS cr
ON cr.CampaignID = c.CampaignID
JOIN Sales.SalesTerritory AS st
ON st.TerritoryID = c.CampaignTerritoryID
WHERE cr.ConvertedToSale = 1
GROUP BY c.CampaignName, c.CampaignStartDate, c.CampaignEndDate, st.Name
OPTION (RECOMPILE); --RECOMPILE -> план не из кэша



-- 3. Перестроить статистику для таблиц Proseware.Campaign и Proseware.CampaignResponse 
ALTER TABLE Proseware.Campaign REBUILD
GO
ALTER TABLE Proseware.CampaignResponse REBUILD;
GO

-- 4. Запустить запрос п.2
-- Сравнить план с планом ..\Tuning-SqlServer-Databases\mod07\lab\plan1.sqlplan
-- estimated и actual row counts теперь одинаковы