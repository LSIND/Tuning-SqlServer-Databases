USE AdventureWorks;
GO

-- Предварительное удаление объектов
IF OBJECT_ID(N'[FK_Campaign_SalesTerritory]') IS NOT NULL
BEGIN
ALTER TABLE Proseware.Campaign
DROP CONSTRAINT IF EXISTS [FK_Campaign_SalesTerritory];
END
GO

DROP TABLE IF EXISTS Proseware.CampaignAdvert;
GO

DROP TABLE IF EXISTS Proseware.Campaign;
GO


 DROP TABLE IF EXISTS Proseware.WebResponse;
 GO

  DROP TABLE IF EXISTS Proseware.CampaignResponse;
 GO
  DROP PROC IF EXISTS Proseware.up_CampaignResponse_Add
 GO
 DROP PROC IF EXISTS Proseware.up_CampaignReport
 GO

DROP SCHEMA IF EXISTS Proseware;
GO

-------

-- Создание объектов для ЛР8

CREATE SCHEMA Proseware;
GO

CREATE TABLE Proseware.Campaign
(CampaignID int PRIMARY KEY,
CampaignName varchar(20) NOT NULL,
CampaignTerritoryID int NOT NULL,
CampaignStartDate date NOT NULL,
CampaignEndDate date NOT NULL
)
GO
ALTER TABLE Proseware.Campaign WITH CHECK ADD  CONSTRAINT FK_Campaign_SalesTerritory FOREIGN KEY (CampaignTerritoryID)
REFERENCES Sales.SalesTerritory(TerritoryID)
GO
ALTER TABLE Proseware.Campaign CHECK CONSTRAINT FK_Campaign_SalesTerritory
GO

INSERT Proseware.Campaign
(CampaignID, CampaignName, CampaignTerritoryID, CampaignStartDate, CampaignEndDate)
SELECT TOP (10000)
ROW_NUMBER() OVER (ORDER BY a.name, b.name),
CAST(1000000 +ROW_NUMBER() OVER (ORDER BY a.name, b.name) AS nvarchar(20)),
(ROW_NUMBER() OVER (ORDER BY a.name, b.name) % 10) + 1,
DATEADD(dd, ROW_NUMBER() OVER (ORDER BY a.name, b.name) % 3650, '2006-01-01'),
DATEADD(dd, (ROW_NUMBER() OVER (ORDER BY a.name, b.name) % 3650) + 30, '2006-01-01')
FROM master.dbo.spt_values AS a
CROSS JOIN master.dbo.spt_values AS b
GO

INSERT Proseware.Campaign
(CampaignID, CampaignName, CampaignTerritoryID, CampaignStartDate, CampaignEndDate)
VALUES
(99999,'2001a',1,'2016-02-01','2016-03-01')
GO

--CREATE INDEX ix_CampaignResponse_CampaignName ON Proseware.Campaign(CampaignName);
--DROP INDEX Proseware.Campaign.ix_CampaignResponse_CampaignName;

--truncate table Proseware.Campaign
--select * from Proseware.Campaign order by CampaignEndDate desc
-- GO


CREATE TABLE Proseware.CampaignResponse
(CampaignResponseID int IDENTITY(1,1) PRIMARY KEY,
CampaignID int NOT NULL,
ResponseDate date NOT NULL,
ConvertedToSale bit NOT NULL,
ConvertedSaleValueUSD decimal(20,2) NULL
)

GO
ALTER TABLE Proseware.CampaignResponse WITH CHECK ADD  CONSTRAINT FK_CampaignResponse_Campaign FOREIGN KEY (CampaignID)
REFERENCES Proseware.Campaign(CampaignID)
GO
ALTER TABLE Proseware.CampaignResponse CHECK CONSTRAINT FK_CampaignResponse_Campaign
GO


WITH myCTE
AS
(
	SELECT c.*,
	ROW_NUMBER() OVER (PARTITION BY c.CampaignID ORDER BY b.name ) as rn1,
	CASE WHEN RIGHT(CONVERT(varchar(40),NEWID()),1) BETWEEN 'A' AND 'F' THEN 1 ELSE 0 END AS rnd1
	FROM Proseware.Campaign AS c
	CROSS JOIN master.dbo.spt_values AS b
)
INSERT Proseware.CampaignResponse
(CampaignID, ResponseDate, ConvertedToSale, ConvertedSaleValueUSD)
SELECT c.CampaignID,
DATEADD(dd, rn1 % 40, c.CampaignStartDate),
c.rnd1,
CASE WHEN rnd1 = 1 THEN rn1 * 1.99 ELSE NULL END
FROM myCTE AS c
WHERE c.rn1 <= c.CampaignID % 1000
GO

DBCC DROPCLEANBUFFERS
GO

CREATE PROCEDURE Proseware.up_CampaignResponse_Add
(
	@CampaignName varchar(20),
	@ResponseDate date,
	@ConvertedToSale bit,
	@ConvertedSaleValueUSD decimal(20,2)
)
AS
	SET NOCOUNT ON	
	DECLARE @CampaignId int;

	-- lookup CampaignId
	SELECT @CampaignId = CampaignID
	FROM Proseware.Campaign
	WHERE CampaignName = @CampaignName;

	--insert values
	INSERT Proseware.CampaignResponse
	(CampaignID, ResponseDate, ConvertedToSale, ConvertedSaleValueUSD)
	VALUES
	(@CampaignId,@ResponseDate, @ConvertedToSale, @ConvertedSaleValueUSD);
GO


CREATE PROCEDURE Proseware.up_CampaignReport
(@CampaignName varchar(20))
AS
	DECLARE @sql nvarchar(MAX);
	SET @sql = 
	'SELECT	cn.CampaignID,
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
	WHERE CampaignName = ''' + @CampaignName + '''';

	EXEC(@sql);
GO
-------------------------------------------------------------


USE TSQL;
GO

CREATE SCHEMA Proseware;
GO
CREATE TABLE Proseware.Campaign
(CampaignID int PRIMARY KEY,
CampaignName varchar(20) NOT NULL,
CampaignTerritoryID int NOT NULL,
CampaignStartDate date NOT NULL,
CampaignEndDate date NOT NULL
)
GO

INSERT Proseware.Campaign
(CampaignID, CampaignName, CampaignTerritoryID, CampaignStartDate, CampaignEndDate)
SELECT TOP (10000)
ROW_NUMBER() OVER (ORDER BY a.name, b.name),
CAST(1000000 +ROW_NUMBER() OVER (ORDER BY a.name, b.name) AS nvarchar(20)),
(ROW_NUMBER() OVER (ORDER BY a.name, b.name) % 10) + 1,
DATEADD(dd, ROW_NUMBER() OVER (ORDER BY a.name, b.name) % 3650, '2006-01-01'),
DATEADD(dd, (ROW_NUMBER() OVER (ORDER BY a.name, b.name) % 3650) + 30, '2006-01-01')
FROM master.dbo.spt_values AS a
CROSS JOIN master.dbo.spt_values AS b
GO

INSERT Proseware.Campaign
(CampaignID, CampaignName, CampaignTerritoryID, CampaignStartDate, CampaignEndDate)
VALUES
(99999,'2001a',1,'2016-02-01','2016-03-01')
GO
--CREATE INDEX ix_CampaignResponse_CampaignName ON Proseware.Campaign(CampaignName);
--DROP INDEX Proseware.Campaign.ix_CampaignResponse_CampaignName;

--truncate table Proseware.Campaign
--select * from Proseware.Campaign order by CampaignEndDate desc
GO
CREATE TABLE Proseware.CampaignResponse
(CampaignResponseID int IDENTITY(1,1) PRIMARY KEY,
CampaignID int NOT NULL,
ResponseDate date NOT NULL,
ConvertedToSale bit NOT NULL,
ConvertedSaleValueUSD decimal(20,2) NULL
)

GO
ALTER TABLE Proseware.CampaignResponse WITH CHECK ADD  CONSTRAINT FK_CampaignResponse_Campaign FOREIGN KEY (CampaignID)
REFERENCES Proseware.Campaign(CampaignID)
GO
ALTER TABLE Proseware.CampaignResponse CHECK CONSTRAINT FK_CampaignResponse_Campaign
GO

WITH myCTE
AS
(
	SELECT TOP (1000000) c.*,
	ROW_NUMBER() OVER (PARTITION BY c.CampaignID ORDER BY b.name ) as rn1,
	CASE WHEN RIGHT(CONVERT(varchar(40),NEWID()),1) BETWEEN 'A' AND 'F' THEN 1 ELSE 0 END AS rnd1
	FROM Proseware.Campaign AS c
	CROSS JOIN master.dbo.spt_values AS b
)
INSERT Proseware.CampaignResponse
(CampaignID, ResponseDate, ConvertedToSale, ConvertedSaleValueUSD)
SELECT c.CampaignID,
DATEADD(dd, rn1 % 40, c.CampaignStartDate),
c.rnd1,
CASE WHEN rnd1 = 1 THEN rn1 * 1.99 ELSE NULL END
FROM myCTE AS c
WHERE c.rn1 <= c.CampaignID % 1000
GO
DBCC DROPCLEANBUFFERS
GO

CREATE PROCEDURE Proseware.up_CampaignResponses
(@CampaignName varchar(20))
AS

	SELECT	cn.CampaignID,
			cn.CampaignName,
			cr.ResponseDate,
			cr.ConvertedToSale,
			cr.ConvertedSaleValueUSD
	FROM Proseware.Campaign AS cn
	JOIN Proseware.CampaignResponse AS cr
	ON cr.CampaignID = cn.CampaignID
	WHERE CampaignName = @CampaignName;
GO
