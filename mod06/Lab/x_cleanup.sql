USE AdventureWorks;
GO

-- Удаление объектов, созданных в LAB06
IF OBJECT_ID(N'[FK_Campaign_SalesTerritory]') IS NOT NULL
BEGIN
ALTER TABLE Proseware.Campaign
DROP CONSTRAINT IF EXISTS [FK_Campaign_SalesTerritory];
END
GO

IF OBJECT_ID(N'[FK_CampaignAdvert_Campaign]') IS NOT NULL
BEGIN
ALTER TABLE Proseware.CampaignAdvert
DROP CONSTRAINT IF EXISTS [FK_CampaignAdvert_Campaign];
END
GO

DROP TABLE IF EXISTS Proseware.CampaignAdvert;
GO

DROP TABLE IF EXISTS Proseware.Campaign;
GO

 DROP TABLE IF EXISTS Proseware.WebResponse;
 GO

DROP SCHEMA IF EXISTS Proseware;
GO