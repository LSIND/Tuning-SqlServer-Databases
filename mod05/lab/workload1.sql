-- цикл на 1 минут или до создания таблицы ##stopload (симуляция нагрузки)

DROP TABLE IF EXISTS ##stopload;
SET NOCOUNT ON;
USE AdventureWorks;
GO

DECLARE @start datetime2 = GETDATE(), @rnd int, @rc int;
WHILE DATEDIFF(ss,@start,GETDATE()) < 60 AND OBJECT_ID('tempdb..##stopload') IS NULL
BEGIN
	IF @@SPID % 10 = 9
	BEGIN
		SET @rnd = RAND()*10;
		EXEC Proseware.up_Campaign_Replace @rnd = @rnd;

	END
	ELSE
	BEGIN
		WAITFOR DELAY '00:00:01';
		EXEC Proseware.up_Campaign_Report
		WAITFOR DELAY '00:00:00.050';
	END


END