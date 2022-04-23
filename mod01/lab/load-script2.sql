-- EX3 - load script 2
-- Цикл до 60 минут или пока не будет создана таблица ##stopload2
DROP TABLE IF EXISTS tempdb..##stopload2;
GO
USE AdventureWorks;
GO

DECLARE @start datetime2 = GETDATE();
IF @@SPID % 5 = 0
	BEGIN --update
		WHILE DATEDIFF(ss,@start,GETDATE()) < 3600 AND OBJECT_ID('tempdb..##stopload2') IS NULL
		BEGIN
			BEGIN TRANSACTION
				UPDATE TOP(1) Sales.Customer
				SET ModifiedDate = GETDATE()
				
				WAITFOR DELAY '00:00:10'

			ROLLBACK
		END
	END
ELSE
	BEGIN --select
		WHILE DATEDIFF(ss,@start,GETDATE()) < 3600 AND OBJECT_ID('tempdb..##stopload2') IS NULL
		BEGIN
				SELECT TOP (5) c.CustomerID, p.PersonType
				FROM Sales.Customer as c
				JOIN Person.Person as p
				ON p.BusinessEntityID = c.PersonID
				ORDER BY NEWID()
				OPTION (RECOMPILE);

				WAITFOR DELAY '00:00:03'
		END

	END