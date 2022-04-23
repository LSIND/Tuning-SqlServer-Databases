-- load generation script 1
-- loops for 100 executions, or until the ##stopload shared temp table is created
DROP TABLE IF EXISTS ##stopload;
DROP TABLE IF EXISTS #t;
SET NOCOUNT ON;
USE AdventureWorks;
GO

DECLARE @i int = 0 ;
WHILE @i < 50 AND OBJECT_ID('tempdb..##stopload') IS NULL
BEGIN
	SELECT w.log_date, w.page_visit_time_seconds, w.page_url,
	ad.StartDate, ad.EndDate,
	c.CampaignName,
	t.Name 
	INTO #t
	FROM Proseware.WebResponse AS w
	JOIN Proseware.CampaignAdvert AS ad
	ON ad.CampaignAdvertID = w.CampaignAdvertId
	JOIN Proseware.Campaign AS c
	ON c.CampaignID = ad.CampaignId
	JOIN Sales.SalesTerritory AS t
	ON t.TerritoryID = c.CampaignTerritoryID
	WHERE ad.AdvertMedia = 'Web'
	AND w.CampaignAdvertId > 1500 + @i
	OPTION (RECOMPILE);

	DROP TABLE #t

	SET @i += 1;
END


