-- load generation script 1
-- цикл на 60 минут, либо при создании таблицы ##stopload
DROP TABLE IF EXISTS ##stopload;

USE AdventureWorks;
GO

DECLARE @start datetime2 = GETDATE();
IF @@SPID % 5 = 0
	BEGIN --update
		WHILE DATEDIFF(ss,@start,GETDATE()) < 3600 AND OBJECT_ID('tempdb..##stopload') IS NULL
		BEGIN
			DECLARE @cname varchar(20) = (SELECT TOP(1) CampaignName FROM Proseware.Campaign ORDER BY NEWID());
			DECLARE @response date = DATEADD(d, CAST(RAND() * -100 AS INT), GETDATE());
			
			EXEC Proseware.up_CampaignResponse_Add 
					@CampaignName = @cname,
					@ResponseDate = @response,
					@ConvertedToSale = 0,
					@ConvertedSaleValueUSD = NULL
				
			WAITFOR DELAY '00:00:45';
		END
	END
ELSE
IF @@SPID % 5 = 1
	BEGIN --update
		WHILE DATEDIFF(ss,@start,GETDATE()) < 3600 AND OBJECT_ID('tempdb..##stopload') IS NULL
		BEGIN
			DECLARE @cname1 varchar(20) = (SELECT TOP(1) CampaignName FROM Proseware.Campaign ORDER BY NEWID());
			DECLARE @response1 date = DATEADD(d, CAST(RAND() * -100 AS INT), GETDATE());
			
			EXEC Proseware.up_CampaignResponse_Add 
					@CampaignName = @cname1,
					@ResponseDate = @response1,
					@ConvertedToSale = 1,
					@ConvertedSaleValueUSD = 100.00
				
			WAITFOR DELAY '00:00:10';
		END
	END
ELSE
	BEGIN --select
		DECLARE @i int = 0
		WHILE DATEDIFF(ss,@start,GETDATE()) < 3600 AND OBJECT_ID('tempdb..##stopload') IS NULL
		BEGIN
			DECLARE @cname2 varchar(20) 
			IF @i > 0
				SET @cname2 = (SELECT TOP(1) CampaignName FROM Proseware.Campaign ORDER BY NEWID());
			ELSE
				SET @cname2 = '2001a'

			EXEC Proseware.up_CampaignReport @CampaignName = @cname2
			WAITFOR DELAY '00:00:01';
			SET @i += 1
		END

	END
	