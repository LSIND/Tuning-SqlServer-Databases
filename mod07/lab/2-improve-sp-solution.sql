USE AdventureWorks;
GO


-- 1. Передайте в хранимую процедуру Proseware.up_CampaignResponse_Add следующие параметры:
--	@CampaignName = 1010000
--	@ResponseDate = '2016-03-01'
--	@ConvertedToSale = 1
--	@ConvertedSaleValueUSD = 100.00
-- Выполните запрос (actual execution plan) и сохраните план в ..\Tuning-SqlServer-Databases\mod07\lab\plan2.sqlplan
-- В плане запроса обратите внимание, что первый запрос (SELECT) занимает 77% от всего пакета (batch)
-- warning на SELECT в первом запросе -> Proseware.Campaign index scan.
-- Решение: добавить некластерный индекс на стоблец Proseware.Campaign.CampaignName и изменить параметр @CampaignName хранимой процедуры


EXEC Proseware.up_CampaignResponse_Add 
 @CampaignName = 1010000,
 @ResponseDate = '2016-03-01',
 @ConvertedToSale = 1,
 @ConvertedSaleValueUSD = 100.00;
 GO

-- 2. Создайте уникальный некластерный индекс на столбец CampaignName таблицы Proseware.Campaign
-- Выполните запрос п.1 (actual execution plan) и сохраните план в ..\Tuning-SqlServer-Databases\mod07\lab\plan3.sqlplan
-- Используется Index Scan

CREATE UNIQUE NONCLUSTERED INDEX ix_Campaign_CampaignName 
ON Proseware.Campaign (CampaignName);
GO

-- 3. Измените хранимую процедуру Proseware.up_CampaignResponse_Add так, чтобы параметр @CampaignName был значением varchar(20), а не int

ALTER PROCEDURE Proseware.up_CampaignResponse_Add  
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
  
 INSERT Proseware.CampaignResponse  
 (CampaignID, ResponseDate, ConvertedToSale, ConvertedSaleValueUSD)  
 VALUES  
 (@CampaignId,@ResponseDate, @ConvertedToSale, @ConvertedSaleValueUSD);  
GO

-- Выполните запрос п.1 (actual execution plan) и сохраните план в ..\Tuning-SqlServer-Databases\mod07\lab\plan4.sqlplan
-- Warning отсутствует