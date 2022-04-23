-- load generation script 1
-- цикл на 60 минут,или пока не будет создана ##stopload 
DROP TABLE IF EXISTS ##stopload;

USE TSQL;
GO

DECLARE @start datetime2 = GETDATE();
IF @@SPID % 8 = 1
	BEGIN --update
		WHILE DATEDIFF(ss,@start,GETDATE()) < 3600 AND OBJECT_ID('tempdb..##stopload') IS NULL
		BEGIN
			IF (SELECT actual_state FROM sys.database_query_store_options) = 2
			BEGIN
				WAITFOR DELAY '00:03:00';
				EXEC sp_recompile 'Proseware.up_CampaignResponses'
			END
			WAITFOR DELAY '00:01:00';
		END
	END
ELSE
	BEGIN --select
		DECLARE @i int = 0, @i2 int
		WHILE DATEDIFF(ss,@start,GETDATE()) < 3600 AND OBJECT_ID('tempdb..##stopload') IS NULL
		BEGIN
			DECLARE @cname2 varchar(20) 
			IF @i > 0
				SET @cname2 = (SELECT TOP(1) CampaignName FROM Proseware.Campaign ORDER BY NEWID());
			ELSE
				SET @cname2 = '2001a'

			EXEC Proseware.up_CampaignResponses @CampaignName = @cname2
			WAITFOR DELAY '00:00:03';
			SET @i += 1


		END

	END
	