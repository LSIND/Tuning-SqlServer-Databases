USE AdventureWorks;
GO

-- Удаление объектов, созданных в ЛР7
IF OBJECT_ID(N'[FK_Campaign_SalesTerritory]') IS NOT NULL
BEGIN
ALTER TABLE Proseware.Campaign
DROP CONSTRAINT IF EXISTS [FK_Campaign_SalesTerritory];
END
GO


DROP TABLE IF EXISTS Proseware.CampaignResponse;
GO

DROP TABLE IF EXISTS Proseware.Campaign;
GO

 DROP PROC IF EXISTS Proseware.up_CampaignResponse_Add
 GO

DROP SCHEMA IF EXISTS Proseware;
GO