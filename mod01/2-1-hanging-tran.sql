-- Откройте транзакцию и выполните инструкции в 2-2-blocked-tran.sql
USE AdventureWorks;
GO

SELECT @@SPID as update_session_id;

BEGIN TRAN

	UPDATE [Production].[Product]
	SET  [Name]= N'New Product Demo Update'
	WHERE ProductID = 1;

-- Выполните  команду после п.9 скрипта 2-thread-lifecycle.sql
--ROLLBACK
