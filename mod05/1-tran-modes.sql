--I. Auto-commit

PRINT @@TRANCOUNT;
SELECT * FROM [Production].[Product];
PRINT @@TRANCOUNT;


-- II. ����� ����������

DROP TABLE IF EXISTS dbo.TestTable;

CREATE TABLE dbo.TestTable
(
   Id INT PRIMARY KEY NOT NULL,
   [Value] INT NOT NULL
)
GO

-- TRUNCATE TABLE dbo.TestTable
 
BEGIN TRANSACTION  
   -- 1. ������� ����� ������ ������
   INSERT INTO dbo.TestTable( Id, [Value] )
   VALUES  ( 1, '10')

   -- 2. ����� ���������� First
   SAVE TRANSACTION [First]

   -- 3. ������� ��� ����� ������ ������
   INSERT INTO dbo.TestTable( Id, [Value] )
   VALUES  ( 2, '20')
 
   -- 4. ����� �� ����� �������������� [First]
   ROLLBACK TRANSACTION [First]

   -- 5. ���� ������ � �������
   SELECT * FROM dbo.TestTable

-- 6. �������� ���������� � ����� ������� ������
COMMIT

DROP TABLE IF EXISTS dbo.TestTable;

-- III. ������� ����������
-- SET IMPLICIT_TRANSACTIONS - ������������� ������� ����� BEGIN TRANSACTION ��� ������

SET IMPLICIT_TRANSACTIONS ON;
GO

PRINT @@TRANCOUNT;
SELECT * FROM [Production].[Product];
GO

PRINT @@TRANCOUNT;
COMMIT TRANSACTION;
PRINT @@TRANCOUNT;