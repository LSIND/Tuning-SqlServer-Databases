-- Нагрузочный скрипт на tempdb
-- ~ время выполнения скрипта 15 сек

USE AdventureWorks;
GO


BEGIN TRANSACTION
SELECT distinct TOP(1000) sod1.SalesOrderID, replicate(sod2.carrierTrackingNumber,5000) as ctn
into #temptable
FROM adventureworks.sales.salesOrderDetail sod1
INNER HASH JOIN adventureworks.sales.salesOrderDetail sod2 on sod1.SalesOrderID = sod2.SalesOrderID OPTION (MAXDOP 1);
COMMIT

DECLARE @i int = 0;
WHILE @i < 100
	BEGIN
		begin transaction
		insert into #temptable select top(100) sod1.SalesOrderID, replicate(sod2.carrierTrackingNumber,5000)
		FROM adventureworks.sales.salesOrderDetail sod1
		INNER HASH JOIN adventureworks.sales.salesOrderDetail sod2 on sod1.SalesOrderID = sod2.SalesOrderID OPTION (MAXDOP 1);
		
		commit

		WAITFOR DELAY '00:00:01'
		SET @i = @i +1;
	END