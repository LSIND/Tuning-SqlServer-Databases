-- 1. instant_file_initialization
-- ����� ������������� � Local Security Policy = secpol.msc
SELECT servicename, instant_file_initialization_enabled 
FROM sys.dm_server_services

-- 2. Auto growth
-- max_size = -1 = ������ ����� ����� ������������� �� ������� ���������� �����; 0 = ���������� ������� ���������.
-- growth - � ���������. 40 Mb = 5120 x 8�� / 1024
SELECT * FROM sys.database_files;

ALTER DATABASE AdventureWorks
MODIFY FILE
(NAME = AdventureWorks_Data,
filegrowth = 40MB);
GO


-- 3. SHRINK
-- 3.1. �������� �� ��� �������: ~524 Mb, log: ~ 32��
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

-- 3.2. �������� ������ � ������������ ��������

use shrinktest
exec sp_spaceused 

select * from sys.dm_db_index_physical_stats (DB_ID('shrinktest'), NULL, NULL, NULL, NULL) 
where avg_fragmentation_in_percent > 0 order by avg_fragmentation_in_percent desc

-- Shrink ����� ������, 100 ��
-- CurrentSize	= ���������� 8-����������� �������, ������� ������ � ��������� �����.
-- MinimumSize = ����������� ���������� 8-����������� �������, ������� ����� �������� ���� = ��� ������ ����� ��� ��� ��������.
-- UsedPages = ���������� 8-����������� �������, ������������ ������ � ��������� �����.
-- EstimatedPages = ���������� 8-����������� �������, �� �������� ����� ���� �� ����� ���� �� ������ Database Engine.
DBCC SHRINKFILE('shrinktest_data',100)

-- 3.3. �������� ������ � ������������ �������� ����� ������
use shrinktest
exec sp_spaceused 

-- Check index fragmentation
select * from sys.dm_db_index_physical_stats (DB_ID('shrinktest'), NULL, NULL, NULL, NULL) 
where avg_fragmentation_in_percent > 0 order by avg_fragmentation_in_percent desc;


-- 4. ���������� ������ � ����� ��
USE AdventureWorks;  
GO  
EXEC sp_helpfile;  
GO

EXEC sp_helpfile 'AdventureWorks_data';

EXEC sp_helpfilegroup;

EXEC sp_helpfilegroup 'PRIMARY';

SELECT * FROM sys.database_files;
SELECT * FROM sys.filegroups;

-- 4.1 ��� ����� �� � ������� ����������
SELECT * FROM sys.master_files;

-- 4.2 �������� �� ������������� ������������ ��� ������� ����� ������ � ���� ������
-- modified_extent_page_count = ����� ����� �������, ���������� � ���������� ��������� ����� � ������� ���������� ������� ���������� ����������� ���� ������.
SELECT * FROM sys.dm_db_file_space_usage;

-- 4.3. ���������� I/O ��� ������ ������ � ������ �������; db_name, file_id - id �����

SELECT * FROM sys.dm_io_virtual_file_stats(DB_ID(N'AdventureWorks'), NULL); 

SELECT * FROM sys.dm_io_virtual_file_stats(DB_ID(N'AdventureWorks'), 2); 

-- sample_ms = ����� �����������, ��������� �� ������� ������� ����������.
-- num_of_reads / num_of_writes	= ���������� ���������� / ������� ��� ����� �����.
-- num_of_bytes_read / num_of_bytes_written = ����� ����� ������, ��������� / ���������� �� (�) ����� �����.
-- io_stall_read_ms / io_stall_write_ms = ����� ����� �������� ���������� ������ / ������ � ����, � �������������.
-- io_stall	= ����� ����� �������� ���������� �������� ������-������ ��� ������, � �������������.

DROP DATABASE IF EXISTS shrinktest;