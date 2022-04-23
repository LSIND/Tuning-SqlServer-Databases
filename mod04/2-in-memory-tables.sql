USE adventureworks
GO

-- 1. Таблица в памяти с DURABILITY=SCHEMA_AND_DATA
-- В БД adventureworks существует MEMORY_OPTIMIZED_DATA AdventureWorks_Mod

SELECT * FROM sys.filegroups
--WHERE type = 'FX';

SELECT * FROM sys.database_files
--WHERE type = 2;

-- Если не существует MEMORY_OPTIMIZED_DATA_FILEGROUP, ее нужно создать:
/* ALTER DATABASE adventureworks
ADD FILEGROUP mem_data CONTAINS MEMORY_OPTIMIZED_DATA;
GO
ALTER DATABASE MyDB
ADD FILE (NAME = 'MemData', FILENAME = 'D:\Data\MyDB_MemData.ndf')
TO FILEGROUP mem_data; */

CREATE TABLE dbo.durable ( 
    Id INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
    AltId INT NOT NULL , 
    CreatedDate DATETIME2 NOT NULL, 
    theValue MONEY
) 
WITH (MEMORY_OPTIMIZED=ON) 
 GO

-- 2. Таблица в памяти с DURABILITY=SCHEMA_ONLY
 CREATE TABLE dbo.nondurable ( 
    Id INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
    AltId INT NOT NULL , 
    CreatedDate DATETIME2 NOT NULL, 
    theValue MONEY
 ) 
 WITH (MEMORY_OPTIMIZED=ON, DURABILITY=SCHEMA_ONLY) 
 GO

-- 3. Вставить данные в обе таблицы
INSERT dbo.durable VALUES (314, SYSDATETIME(), 2) 
INSERT dbo.durable VALUES (171, SYSDATETIME(), NULL) 
INSERT dbo.durable VALUES (258, SYSDATETIME(), 1) 
INSERT dbo.durable VALUES (911, SYSDATETIME(), NULL) 

INSERT dbo.nondurable VALUES (314, SYSDATETIME(), 2) 
INSERT dbo.nondurable VALUES (171, SYSDATETIME(), NULL)
INSERT dbo.nondurable VALUES (258, SYSDATETIME(), 1)  
INSERT dbo.nondurable VALUES (911, SYSDATETIME(), NULL) 
GO

-- 4. Выбрать данные из таблиц

select * from dbo.durable;
select * from dbo.nondurable;

-- 5. Перезагрузить SQL Server и снова выбрать данные (п.4)

-- 6. Удалить таблицы
 DROP TABLE IF EXISTS dbo.durable;
 DROP TABLE IF EXISTS dbo.nondurable;
 GO

-- 6. Сравнение In-Memoty Table и таблице на диске

-- 6.1 Таблица в памяти
CREATE TABLE dbo.MemoryTable
(id INTEGER NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 1000000),
 date_value DATETIME NULL)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);

-- 6.1 Таблица на диске
CREATE TABLE dbo.DiskTable
(id INTEGER NOT NULL PRIMARY KEY NONCLUSTERED,
 date_value DATETIME NULL);


-- 6.2 Вставить 500 000 строк в таблицу на диске
-- 8 Gb RAM, Intel Core i5-8400, SSD, SQL Server 2017  ~ 5 sec 

BEGIN TRAN
	DECLARE @Diskid int = 1
	WHILE @Diskid <= 500000
	BEGIN
		INSERT INTO dbo.DiskTable VALUES (@Diskid, GETDATE())
		SET @Diskid += 1
	END
COMMIT;

SELECT COUNT(*) FROM dbo.DiskTable;
GO

-- 6.3 Вставить 500 000 строк в таблицу в памяти
-- 8 Gb RAM, Intel Core i5-8400, SSD, SQL Server 2017  ~ 1 sec 
BEGIN TRAN
	DECLARE @Memid int = 1
	WHILE @Memid <= 500000
	BEGIN
		INSERT INTO dbo.MemoryTable VALUES (@Memid, GETDATE())
		SET @Memid += 1
	END
COMMIT;

SELECT COUNT(*) FROM dbo.MemoryTable;
GO

-- 6.4 Удалить все данные из таблицы на диске ~ 1 sec 
DELETE FROM DiskTable;

-- 6.5 Удалить все данные из таблицы в памяти ~ 0 sec 
DELETE FROM MemoryTable;
GO

-- 7.  Информация о таблицах в памяти
SELECT o.Name, m.*
FROM
sys.dm_db_xtp_table_memory_stats AS m
JOIN sys.sysobjects AS o
ON m.object_id = o.id;
GO


-- 8. Создать native stored proc
-- EXEC sp_changedbowner 'sa'

CREATE PROCEDURE dbo.InsertData
	WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = 'us_english')
	DECLARE @Memid int = 1
	WHILE @Memid <= 500000
	BEGIN
		INSERT INTO dbo.MemoryTable VALUES (@Memid, GETDATE())
		SET @Memid += 1
	END
END;
GO

-- 9. Вставить данные с помощью nsp ~ 0 sec
EXEC dbo.InsertData;

SELECT COUNT(*) FROM dbo.MemoryTable;

-- 10. Удалить таблицы и ХП
 DROP PROC IF EXISTS dbo.InsertData;
 DROP TABLE IF EXISTS dbo.DiskTable;
 DROP TABLE IF EXISTS dbo.MemoryTable;

 GO
