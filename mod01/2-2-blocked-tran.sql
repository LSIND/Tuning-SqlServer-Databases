-- Выполните инструкции
USE AdventureWorks;
GO

SELECT @@SPID as select_session_id;
GO

SELECT [Name] FROM [Production].[Product];