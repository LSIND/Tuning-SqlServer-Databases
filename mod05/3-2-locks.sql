-- Запрос 1 
-- exclusive lock на 1 строку Sales.SalesTerritory внутри транзакции
-- XLOCK монопольные блокировки применяются и удерживаются до завершения транзакции: можно добавить уровень ROWLOCK, PAGLOCK или TABLOCK
-- The XLOCK table hint can be considered unreliable. This is because the SQL engine can ignore the hint if the data being accessed hasn’t changed since the oldest open transaction!
USE AdventureWorks;
GO

BEGIN TRANSACTION 
	UPDATE Sales.SalesTerritory 
	WITH (XLOCK) --TABLOCKX
	SET [Name] = 'Test'
	WHERE TerritoryID = 3 

-- Запрос 2
ROLLBACK