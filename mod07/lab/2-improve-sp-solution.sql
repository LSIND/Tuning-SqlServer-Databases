USE AdventureWorks;
GO


-- 1. ��������� � �������� ��������� Proseware.up_CampaignResponse_Add ��������� ���������:
--	@CampaignName = 1010000
--	@ResponseDate = '2016-03-01'
--	@ConvertedToSale = 1
--	@ConvertedSaleValueUSD = 100.00
-- ��������� ������ (actual execution plan) � ��������� ���� � ..\Tuning-SqlServer-Databases\mod07\lab\plan2.sqlplan
-- � ����� ������� �������� ��������, ��� ������ ������ (SELECT) �������� 77% �� ����� ������ (batch)
-- warning �� SELECT � ������ ������� -> Proseware.Campaign index scan.
-- �������: �������� ������������ ������ �� ������� Proseware.Campaign.CampaignName � �������� �������� @CampaignName �������� ���������


EXEC Proseware.up_CampaignResponse_Add 
 @CampaignName = 1010000,
 @ResponseDate = '2016-03-01',
 @ConvertedToSale = 1,
 @ConvertedSaleValueUSD = 100.00;
 GO

-- 2. �������� ���������� ������������ ������ �� ������� CampaignName ������� Proseware.Campaign
-- ��������� ������ �.1 (actual execution plan) � ��������� ���� � ..\Tuning-SqlServer-Databases\mod07\lab\plan3.sqlplan
-- ������������ Index Scan

CREATE UNIQUE NONCLUSTERED INDEX ix_Campaign_CampaignName 
ON Proseware.Campaign (CampaignName);
GO

-- 3. �������� �������� ��������� Proseware.up_CampaignResponse_Add ���, ����� �������� @CampaignName ��� ��������� varchar(20), � �� int

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

-- ��������� ������ �.1 (actual execution plan) � ��������� ���� � ..\Tuning-SqlServer-Databases\mod07\lab\plan4.sqlplan
-- Warning �����������