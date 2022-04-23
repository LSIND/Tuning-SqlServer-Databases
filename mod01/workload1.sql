-- пример рабочей нагрузки 1
DECLARE @start datetime2 = GETDATE();

WHILE DATEDIFF(second, @start, GETDATE()) < 300 -- 5 минут
BEGIN
	SELECT TOP 5 a.name
	FROM master.dbo.spt_values AS a
	CROSS JOIN master.dbo.spt_values AS b
	ORDER BY NEWID()
	OPTION  (MAXDOP 1);
END