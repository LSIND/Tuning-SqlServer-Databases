USE AdventureWorks;
GO

-----------------------------------------------
-- 1. ��������� � �������� ��������� Proseware.up_CampaignResponse_Add ��������� ���������:
--	@CampaignName = 1010000
--	@ResponseDate = '2016-03-01'
--	@ConvertedToSale = 1
--	@ConvertedSaleValueUSD = 100.00
-- ��������� ������ (actual execution plan) � ��������� ���� � ..\Tuning-SqlServer-Databases\mod07\lab\plan2.sqlplan
-- � ����� ������� �������� ��������, ��� ������ ������ (SELECT) �������� 77% �� ����� ������ (batch)
-- warning �� SELECT � ������ ������� -> Proseware.Campaign index scan.
-- �������: �������� ������������ ������ �� ������� Proseware.Campaign.CampaignName � �������� �������� @CampaignName �������� ���������
-----------------------------------------------



-----------------------------------------------
-- 2. �������� ���������� ������������ ������ �� ������� CampaignName ������� Proseware.Campaign
-- ��������� ������ �.1 (actual execution plan) � ��������� ���� � ..\Tuning-SqlServer-Databases\mod07\lab\plan3.sqlplan
-- ������������ Index Scan
-----------------------------------------------



-----------------------------------------------
-- 3. �������� �������� ��������� Proseware.up_CampaignResponse_Add ���, ����� �������� @CampaignName ��� ��������� varchar(20), � �� int
-----------------------------------------------



-----------------------------------------------
-- ��������� ������ �.1 (actual execution plan) � ��������� ���� � ..\Tuning-SqlServer-Databases\mod07\lab\plan4.sqlplan
-- Warning �����������
-----------------------------------------------