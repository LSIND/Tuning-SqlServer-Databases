-- EX2 - load script 1
-- ÷икл до 60 минут или пока не будет удалена таблица  ##stopload1

DROP TABLE IF EXISTS tempdb..##stopload1;
GO

DECLARE @start datetime2 = GETDATE();
WHILE DATEDIFF(ss,@start,GETDATE()) < 3600 AND OBJECT_ID('tempdb..##stopload1') IS NULL
BEGIN
	SELECT TOP 10 a.name
	FROM master.dbo.spt_values AS a
	CROSS JOIN master.dbo.spt_values AS b
	ORDER BY NEWID()
	OPTION (RECOMPILE);
	WAITFOR DELAY '00:00:00.500'
END