-- 1. >= sql server 2016
-- 1 = Первый Экстент - Mixed, остальные с Uniform. 
-- 0 = Все страницы из Uniform extent.
-- >= SQL Server 2016 - TempDB и пользовательские БД получают пространство из uniform extent.

-----------------------------------------------------------
USE master;
GO

SELECT  [name], [is_mixed_page_allocation_on]
FROM sys.databases;
GO

--1. Создадим БД с одной таблицей
-- > SQl Server 2016 - is_mixed_page_allocation - OFF
-- первым выдается UniformExtent
CREATE DATABASE DemoAlloc 
GO
USE DemoAlloc
GO

CREATE TABLE DemoTable
(
    DemoColumn CHAR(8000)
)
GO
-- Использование пространства таблицей DemoTable - 0
SP_SPACEUSED DemoTable

-- Вставка данных 9 раз (CHAR)
INSERT INTO DemoTable VALUES ('B')

EXECUTE SP_SPACEUSED DemoTable
GO 9 
-- 1 строка -72 Кб зарезервировано = 64Кб Uniform Extent + 8 Кб Mixed Extent IAM
-- не использовано 56 Кб = 64 - 8
-- строки 2-8: unused - умеьшается на 8 Кб
-- 9 строка - + еще один экстент: 72 + 64 = 136 Кб

-- 10 страниц (1 IAM Page из mixed extent + 9 Data pages из 2х Uniform extents).
DBCC IND ('DemoAlloc','DemoTable', -1)

-- 2. Включение опции БД MIXED_PAGE_ALLOCATION ON
USE master;
GO

ALTER DATABASE DemoAlloc 
SET MIXED_PAGE_ALLOCATION ON
GO

DROP TABLE IF EXISTS DemoTable

CREATE TABLE DemoTable
(
    DemoColumn CHAR(8000)
)
GO
-- Использование пространства таблицей DemoTable - 0
SP_SPACEUSED DemoTable

-- Вставка данных 9 раз (CHAR)
INSERT INTO DemoTable VALUES ('B')

EXECUTE SP_SPACEUSED DemoTable
GO 9 
-- 1 строка -16 Кб зарезервировано = 1Кб Page из Mixed Extent + 8 Кб Mixed Extent IAM
-- не использовано 0 Кб = 64 - 8
-- строки 2-8: unused - не изменяеся; reserved - увеличивается на 8 Кб
-- 9 строка - + добавлен Uniform Extent: 72 + 64 = 136 Кб


-- 10 страниц (1 IAM Page из mixed extent + 9 Data pages (8 из Mixed и 1 из Uniform).
DBCC IND ('DemoAlloc','DemoTable', -1)

DROP DATABASE DemoAlloc;
-----------------------------------------------------------

--2. SP_SPACEUSED Выводит количество строк, зарезервированное место на диске и место на диске, которое используется таблицей, 
--индексированным представлением или очередью компонента Компонент Service Broker в текущей БД, 
--либо выводит место на диске, зарезервированное и используемое всей базой данных.

USE AdventureWorks;
GO

EXECUTE SP_SPACEUSED 'Sales.SalesOrderHeader'
GO

--Имя текущей базы данных.
--Размер текущей базы данных в мегабайтах. database_size включает файлы данных и журналов.
--Место в базе данных, не зарезервированное для объектов базы данных.

-- reserved = Общий объем пространства, выделенный объектам в базе данных.
-- data = Общий объем пространства, используемый данными.
-- index_size = Общий объем пространства, используемый индексами.
-- unuised = Общий объем пространства, зарезервированный для объектов в базе данных, но пока не используемый

 -- если база данных содержит MEMORY_OPTIMIZED_DATA файловую группу по крайней мере с одним контейнером
 --xtp_precreated = Общий размер файлов контрольных точек с созданным состоянием в КБ. Подсчитывает количество нераспределенного пространства в базе данных в целом. [Например, если имеется 600 000 КБ созданных файлов контрольных точек, этот столбец содержит "600000 КБ"]
-- xtp_used	= Общий размер файлов контрольных точек с состояниями в разделе Создание, активный и целевой объект слияния, в КБ. Это место на диске, активно используемое для данных в оптимизированных для памяти таблицах.
-- xtp_pending_truncation = Общий размер файлов контрольных точек с WAITING_FOR_LOG_TRUNCATION состояния, в КБ. Это место на диске, используемое для файлов контрольных точек, ожидающих очистки, после усечения журнала.

EXECUTE SP_SPACEUSED 
GO


-- 3. Сведения о распределении страниц для базы данных, таблицы, индекса и секции
SELECT allocated_page_page_id AS page_id, index_id, page_type_desc 
FROM sys.dm_db_database_page_allocations
(
  DB_ID(),  OBJECT_ID(N'Sales.SalesOrderHeader'),  NULL,  NULL,  N'DETAILED'
)
WHERE is_allocated = 1
ORDER BY page_type_desc;	


SELECT *
FROM sys.dm_db_database_page_allocations
(
  DB_ID(),  OBJECT_ID(N'Sales.SalesOrderHeader'),  NULL,  NULL,  N'DETAILED'
)
WHERE page_type = 1 -- data page
ORDER BY page_type_desc;	

--4. Новая функция sys.dm_db_page_info. Сравнить Exec Plan

DECLARE 
  @dbid   int = DB_ID(),  
  @fileid int = 1, 
  @pageid int = 9379, 
  @objid  int = OBJECT_ID(N'Sales.SalesOrderHeader');

SELECT *
  FROM sys.dm_db_database_page_allocations(@dbid, NULL, NULL, NULL, N'LIMITED')
  WHERE allocated_page_page_id = @pageid;

  -- sql server 2019 NEW DMF Возвращает сведения о странице в базе данных (header).
SELECT *
  FROM sys.dm_db_page_info(@dbid, 1, @pageid, N'LIMITED');	


-- 5. Тестирование новой таблицы
-- 5.1 Создать таблицу и заполнить данными

use AdventureWorks;
GO

IF object_id('viewPage') is not null
DROP TABLE viewPage; 
GO

CREATE TABLE viewPage
(
	ID int identity(1,1) not null,
	rowData varchar(8000)
)

DECLARE @i int = 1;
WHILE @i <=3 
BEGIN
INSERT INTO	viewPage (rowData) 
VALUES (REPLICATE(cast(@i as char(1)), 2000))
SET @i = @i + 1
END
GO

SElECT  * FROM viewPage; 
-- page = 8192 b, data ~ 6010 b

EXECUTE SP_SPACEUSED 'viewPage'

-- 5.2 Просмотр информации о странице
-- Найти номер страницы
select db_name(database_id) as DatabaseName, OBJECT_NAME(object_id) TableName, allocation_unit_type, allocation_unit_type_desc, allocated_page_file_id, allocated_page_page_id 
from sys.dm_db_database_page_allocations(db_id('AdventureWorks'),object_id('viewPage'),NULL,NULL,'DETAILED')
where page_type = 1;
GO

-- Enable trace flag
DBCC TRACEON(3604);
GO

-- Просмотр информации о распределении
DBCC PAGE('AdventureWorks',1,[INSERT PAGE N],3);
GO

-- 5.3 Обновление данных и просмотр информации о странице
UPDATE viewPage 
SET [rowData] = REPLICATE('5',5000) where id = 1;
GO

SElECT  * FROM viewPage; 
-- page = 8192 b, data ~ 15100 b -> 2 pages

EXECUTE SP_SPACEUSED 'viewPage'

select db_name(database_id), OBJECT_NAME(object_id), allocation_unit_type, allocation_unit_type_desc, allocated_page_file_id, allocated_page_page_id 
from sys.dm_db_database_page_allocations(db_id('AdventureWorks'),object_id('viewPage'),NULL,NULL,'DETAILED')
where page_type = 1;
GO


-- Обновленное распределение
-- имя базы, номер файла, номер страницы, 0-3 - подробности вывода
dbcc page('AdventureWorks',1,[INSERT PAGE N],2);
GO

-- 5.4 Удаление таблицы
IF object_id('viewPage') is not null
DROP TABLE viewPage; 
GO

-- 6. Все пользовательские таблицы в базе данных и объем пространства, используемого в каждой из них, по типу единиц распределения
SELECT t.object_id AS ObjectID,
       OBJECT_NAME(t.object_id) AS ObjectName,
       SUM(u.total_pages) * 8 AS Total_Reserved_kb,
       SUM(u.used_pages) * 8 AS Used_Space_kb,
       u.type_desc AS TypeDesc,
       MAX(p.rows) AS RowsCount
FROM sys.allocation_units AS u
JOIN sys.partitions AS p ON u.container_id = p.hobt_id
JOIN sys.tables AS t ON p.object_id = t.object_id
GROUP BY t.object_id,
         OBJECT_NAME(t.object_id),
         u.type_desc
ORDER BY Used_Space_kb DESC,
         ObjectName;