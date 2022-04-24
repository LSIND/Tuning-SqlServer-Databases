---------------------------------------------------------------------
-- 1. Выполните скрипт _setup.sql, изучите инструкции
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 2. Откройте Powershell от имени администратора, перейдите в папку ..Tuning-SqlServer-Databases\mod08\lab
-- Выполните скрипт .\start-load-ex.ps1 workload1.sql
-- Скрипт запустит 10 фоновых работ (job), выполняющих один и тот же скрипт workload1.sql
---------------------------------------------------------------------


---------------------------------------------------------------------
-- 3. Выполните запрос к sys.dm_exec_query_stats, чтобы найти самый популярный query_hash на экземпляре сервера
---------------------------------------------------------------------
USE AdventureWorks;
GO

SELECT TOP(1) query_hash, COUNT(1) AS cnt 
FROM sys.dm_exec_query_stats 
GROUP BY query_hash 
ORDER BY cnt DESC


---------------------------------------------------------------------
-- 4. Определите запрос, вызывающий рост кэша плана
-- Добавьте в условие WHERE значение столбца query_hash из п.3
---------------------------------------------------------------------
SELECT TOP(1) [text]
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) AS st
WHERE query_hash = 0x19F397846F2DCE71

---------------------------------------------------------------------
-- 5. Определите хранимую процедуру, вызывающую рост кэша
-- Выполните запрос к INFORMATION_SCHEMA.ROUTINES
---------------------------------------------------------------------
SELECT * 
FROM INFORMATION_SCHEMA.ROUTINES AS r
WHERE r.ROUTINE_DEFINITION LIKE '%cn.CampaignID%';
GO

---------------------------------------------------------------------
-- 6. Измените хранимую процедуру Proseware.up_CampaignReport
-- Уберите использование динамического SQL - для каждого запроса отдельный план
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
-- 7. Убедитесь, что ХП Proseware.up_CampaignReport использует Single Query Plan
-- Выполните запрос к sys.dm_exec_procedure_stats для отображения плана для Proseware.up_CampaignReport.
-- Один план
---------------------------------------------------------------------
SELECT *
FROM sys.dm_exec_procedure_stats
WHERE object_id = object_id('Proseware.up_CampaignReport');

---------------------------------------------------------------------
-- 8. Остановите нагрузку
---------------------------------------------------------------------
CREATE TABLE ##stopload(id int);