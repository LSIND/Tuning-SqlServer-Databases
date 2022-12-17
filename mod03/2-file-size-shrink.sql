-- 1. instant_file_initialization
-- Можно перенастроить в Local Security Policy = secpol.msc
SELECT servicename, instant_file_initialization_enabled 
FROM sys.dm_server_services

-- 2. Auto growth
-- max_size = -1 = размер файла может увеличиваться до полного заполнения диска; 0 = Увеличение размера запрещено.
-- growth - в страницах. 40 Mb = 5120 x 8кб / 1024
SELECT * FROM sys.database_files;

ALTER DATABASE AdventureWorks
MODIFY FILE
(NAME = AdventureWorks_Data,
filegrowth = 40MB);
GO


-- 3. SHRINK
-- 3.1. Создание БД для примера: ~524 Mb, log: ~ 32мб
DROP DATABASE IF EXISTS shrinktest;
USE [master]
GO

CREATE DATABASE [shrinktest]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'shrinktest_data', FILENAME = 'D:\TestDB\sh_data.mdf',  SIZE = 524288KB , FILEGROWTH = 64MB )
 LOG ON 
( NAME = N'shrinktest_log', FILENAME = 'D:\TestDB\sh_log.ldf', SIZE = 32MB , FILEGROWTH = 8MB);
GO


SELECT DATABASEPROPERTYEX(N'shrinktest', N'IsAutoShrink'); -- false


USE shrinktest;
GO
select * into dbo.testtable 
from AdventureWorks.Sales.SalesOrderDetail;
GO

DECLARE @i int =1;
WHILE @i <=5
BEGIN
	insert into shrinktest.dbo.testtable select [SalesOrderID],[CarrierTrackingNumber],[OrderQty],[ProductID],[SpecialOfferID]
      ,[UnitPrice],[UnitPriceDiscount],[LineTotal],[rowguid],[ModifiedDate] from AdventureWorks.Sales.SalesOrderDetail;
	  SET @i = @i +1;
END
GO
create index idx1_testtable on shrinktest.dbo.testtable (salesOrderID);
GO
create index idx2_testtable on shrinktest.dbo.testtable (carrierTrackingNumber,SalesOrderId);
GO
create index idx3_testtable on shrinktest.dbo.testtable (ModifiedDate);
GO

-- 3.2. Проверка файлов и фрагментации индексов

use shrinktest
exec sp_spaceused 

select * from sys.dm_db_index_physical_stats (DB_ID('shrinktest'), NULL, NULL, NULL, NULL) 
where avg_fragmentation_in_percent > 0 order by avg_fragmentation_in_percent desc

-- Shrink файла данных, 100 Мб
-- CurrentSize	= Количество 8-килобайтных страниц, занятых файлом в настоящее время.
-- MinimumSize = Минимальное количество 8-килобайтных страниц, которое может занимать файл = мин размер файла при его создании.
-- UsedPages = Количество 8-килобайтных страниц, используемых файлом в настоящее время.
-- EstimatedPages = Количество 8-килобайтных страниц, до которого можно было бы сжать файл по оценке Database Engine.
DBCC SHRINKFILE('shrinktest_data',100)

-- 3.3. Проверка файлов и фрагментации индексов после сжатия
use shrinktest
exec sp_spaceused 

-- Check index fragmentation
-- Индексы стали сильно фрагментированными (но не куча)
select * from sys.dm_db_index_physical_stats (DB_ID('shrinktest'), NULL, NULL, NULL, NULL) 
where avg_fragmentation_in_percent > 0 order by avg_fragmentation_in_percent desc;

SELECT * FROM sys.database_files;



-- Альтернатива
-- 1. Создание filegroup и файла БД

ALTER DATABASE shrinktest  
ADD FILEGROUP MovingFGData;  
GO  

ALTER DATABASE shrinktest   
ADD FILE   
(  
    NAME = MovingData,  
    FILENAME = 'D:\TestDB\MovingData.ndf',  
    SIZE = 8MB,  
    --MAXSIZE = 100MB,  
    FILEGROWTH = 64MB  
)  
TO FILEGROUP MovingFGData;  
GO

-- 2. Переместить индексы в новую файловую группу  WITH (DROP_EXISTING = ON)  
CREATE CLUSTERED INDEX idx1_testtable  
    ON dbo.testtable (salesOrderID)
    WITH (DROP_EXISTING = ON)  
    ON MovingFGData;  
GO  

CREATE NONCLUSTERED INDEX idx2_testtable 
on dbo.testtable (carrierTrackingNumber,SalesOrderId)
WITH (DROP_EXISTING = ON)  
    ON MovingFGData;
GO

CREATE NONCLUSTERED INDEX idx3_testtable on dbo.testtable (ModifiedDate)
WITH (DROP_EXISTING = ON)  
    ON MovingFGData;
GO


-- 3. Применить SHRINK к кучам (Кучи не становятся фрагментированными)
-- ***Удалить исходную file group.
DBCC SHRINKFILE('shrinktest_data',100)

DBCC SHRINKFILE('shrinktest_log',50)


-- Просмотр объектов в файловых группах

SELECT  OBJECT_NAME(i.id) AS [TableName]
       , i.indid, i.[name] AS [IndexName]
       , i.groupid, f.name  AS [FileGroup]
       , d.physical_name AS [FileName], s.name AS [FileGroup]
FROM    sys.sysindexes AS i
INNER JOIN  sys.filegroups AS f     
ON  f.data_space_id = i.groupid  AND f.data_space_id = i.groupid
INNER JOIN  sys.database_files AS d  
ON  f.data_space_id = d.data_space_id
INNER JOIN  sys.data_spaces AS s  
ON  f.data_space_id = s.data_space_id
WHERE   OBJECTPROPERTY(i.id, 'IsUserTable') = 1
ORDER BY f.name, OBJECT_NAME(i.id), groupid;


DROP DATABASE IF EXISTS shrinktest;
USE [master]
GO


-- 4. Мониторинг файлов и групп БД
USE AdventureWorks;  
GO  
EXEC sp_helpfile;  
GO

EXEC sp_helpfile 'AdventureWorks_data';

EXEC sp_helpfilegroup;

EXEC sp_helpfilegroup 'PRIMARY';

SELECT * FROM sys.database_files;
SELECT * FROM sys.filegroups;

-- 4.1 ВСЕ файлы БД в текущем экземпляре
SELECT * FROM sys.master_files;

-- 4.2 Сведения об использовании пространства для каждого файла данных в базе данных
-- modified_extent_page_count = Общее число страниц, измененных в выделенных экстентах файла с момента последнего полного резервного копирования базы данных.
SELECT * FROM sys.dm_db_file_space_usage;

-- 4.3. статистика I/O для файлов данных и файлов журнала; db_name, file_id - id файла

SELECT * FROM sys.dm_io_virtual_file_stats(DB_ID(N'AdventureWorks'), NULL); 

SELECT * FROM sys.dm_io_virtual_file_stats(DB_ID(N'AdventureWorks'), 2); 

-- sample_ms = Число миллисекунд, прошедших со времени запуска компьютера.
-- num_of_reads / num_of_writes	= Количество считываний / записей для этого файла.
-- num_of_bytes_read / num_of_bytes_written = Общее число байтов, считанных / записанных из (в) этого файла.
-- io_stall_read_ms / io_stall_write_ms = Общее время задержек выполнения чтения / записи в файл, в миллисекундах.
-- io_stall	= Общее время задержек выполнения операций чтения-записи над файлом, в миллисекундах.

DROP DATABASE IF EXISTS shrinktest;