--I. Auto-commit

PRINT @@TRANCOUNT;
SELECT * FROM [Production].[Product];
PRINT @@TRANCOUNT;


-- II. Явные транзакции

DROP TABLE IF EXISTS dbo.TestTable;

CREATE TABLE dbo.TestTable
(
   Id INT PRIMARY KEY NOT NULL,
   [Value] INT NOT NULL
)
GO

-- TRUNCATE TABLE dbo.TestTable
 
BEGIN TRANSACTION  
   -- 1. Вставка одной строки данных
   INSERT INTO dbo.TestTable( Id, [Value] )
   VALUES  ( 1, '10')

   -- 2. Точка сохранения First
   SAVE TRANSACTION [First]

   -- 3. Вставка еще одной строки данных
   INSERT INTO dbo.TestTable( Id, [Value] )
   VALUES  ( 2, '20')
 
   -- 4. Откат до точки восстановления [First]
   ROLLBACK TRANSACTION [First]

   -- 5. Одна строка в таблице
   SELECT * FROM dbo.TestTable

-- 6. Фиксация транзакции с одной строкой данных
COMMIT

DROP TABLE IF EXISTS dbo.TestTable;

-- III. Неявные транзакции
-- SET IMPLICIT_TRANSACTIONS - Устанавливает неявный режим BEGIN TRANSACTION для сессии

SET IMPLICIT_TRANSACTIONS ON;
GO

PRINT @@TRANCOUNT;
SELECT * FROM [Production].[Product];
GO

PRINT @@TRANCOUNT;
COMMIT TRANSACTION;
PRINT @@TRANCOUNT;