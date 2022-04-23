---------------------------------------------------------------------
-- LAB 06
-- WORKLOAD
-- Запустить перед началом работы с 2-indexing.sql
---------------------------------------------------------------------

USE AdventureWorks;
GO

DECLARE @id int = 1500
DECLARE @datefrom datetime2 = '2015-06-01' 
DECLARE @dateto datetime2 = '2016-01-01' 

SELECT c.CampaignID, wr.browser_name,
	SUM(wr.page_visit_time_seconds) total_visit_time_seconds
FROM Proseware.Campaign AS c
JOIN Proseware.CampaignAdvert AS ca
ON ca.CampaignId = c.CampaignID
JOIN Proseware.WebResponse AS wr
ON wr.CampaignAdvertId = ca.CampaignAdvertID
WHERE wr.log_date >= @datefrom 
AND wr.log_date < @dateto
AND ca.CampaignAdvertId > @id
GROUP BY c.CampaignID, wr.browser_name
ORDER BY c.CampaignID, wr.browser_name
OPTION (RECOMPILE)
GO
