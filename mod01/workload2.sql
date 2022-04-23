-- пример рабочей нагрузки 2
USE AdventureWorks;
GO

DECLARE @start datetime2 = GETDATE();

WHILE DATEDIFF(ss,@start,GETDATE()) < 300
BEGIN
	INSERT INTO dbo.insertTargetEx (date1)
	VALUES (GETDATE())
END
GO