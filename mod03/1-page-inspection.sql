-- 1. >= sql server 2016
-- 1 = database table will get the first 8 pages from the mixed extent and subsequent pages from the uniform extent. 
-- 0 = all the pages for the table are from the uniform extent.
-- TempDB and user databases by default will have the page allocated from uniform extent.
SELECT  [name], [is_mixed_page_allocation_on]
FROM sys.databases;
GO

ALTER DATABASE [DBNAME] 
SET MIXED_PAGE_ALLOCATION ON
GO

--2. SP_SPACEUSED ������� ���������� �����, ����������������� ����� �� ����� � ����� �� �����, ������� ������������ ��������, 
--��������������� �������������� ��� �������� ���������� ��������� Service Broker � ������� ��, 
--���� ������� ����� �� �����, ����������������� � ������������ ���� ����� ������.
EXECUTE SP_SPACEUSED 'Sales.SalesOrderHeader'
GO

--��� ������� ���� ������.
--������ ������� ���� ������ � ����������. database_size �������� ����� ������ � ��������.
--����� � ���� ������, �� ����������������� ��� �������� ���� ������.

-- reserved = ����� ����� ������������, ���������� �������� � ���� ������.
-- data = ����� ����� ������������, ������������ �������.
-- index_size = ����� ����� ������������, ������������ ���������.
-- unuised = ����� ����� ������������, ����������������� ��� �������� � ���� ������, �� ���� �� ������������

 -- ���� ���� ������ �������� MEMORY_OPTIMIZED_DATA �������� ������ �� ������� ���� � ����� �����������
 --xtp_precreated = ����� ������ ������ ����������� ����� � ��������� ���������� � ��. ������������ ���������� ����������������� ������������ � ���� ������ � �����. [��������, ���� ������� 600 000 �� ��������� ������ ����������� �����, ���� ������� �������� "600000 ��"]
-- xtp_used	= ����� ������ ������ ����������� ����� � ����������� � ������� ��������, �������� � ������� ������ �������, � ��. ��� ����� �� �����, ������� ������������ ��� ������ � ���������������� ��� ������ ��������.
-- xtp_pending_truncation = ����� ������ ������ ����������� ����� � WAITING_FOR_LOG_TRUNCATION ���������, � ��. ��� ����� �� �����, ������������ ��� ������ ����������� �����, ��������� �������, ����� �������� �������.

EXECUTE SP_SPACEUSED 
GO


-- 3. �������� � ������������� ������� ��� ���� ������, �������, ������� � ������
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

--4. ����� ������� sys.dm_db_page_info. �������� Exec Plan

DECLARE 
  @dbid   int = DB_ID(),  
  @fileid int = 1, 
  @pageid int = 9379, 
  @objid  int = OBJECT_ID(N'Sales.SalesOrderHeader');

SELECT *
  FROM sys.dm_db_database_page_allocations(@dbid, NULL, NULL, NULL, N'LIMITED')
  WHERE allocated_page_page_id = @pageid;

  -- sql server 2019 NEW DMF ���������� �������� � �������� � ���� ������ (header).
SELECT *
  FROM sys.dm_db_page_info(@dbid, 1, @pageid, N'LIMITED');	



-- 5. ������������ ����� �������
-- 5.1 ������� ������� � ��������� �������

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

-- 5.2 �������� ���������� � ��������
select db_name(database_id) as DatabaseName, OBJECT_NAME(object_id) TableName, allocation_unit_type, allocation_unit_type_desc, allocated_page_file_id, allocated_page_page_id 
from sys.dm_db_database_page_allocations(db_id('AdventureWorks'),object_id('viewPage'),NULL,NULL,'DETAILED')
where page_type = 1;
GO

-- Enable trace flag
DBCC TRACEON(3604);
GO

-- �������� ���������� � �������������
DBCC PAGE('AdventureWorks',1,[INSERT PAGE N],3);
GO

-- 5.3 ���������� ������ � �������� ���������� � ��������
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


-- ����������� �������������
-- ��� ����, ����� �����, ����� ��������, 0-3 - ����������� ������
dbcc page('AdventureWorks',1,[INSERT PAGE N],3);
GO

-- 5.4 �������� �������
IF object_id('viewPage') is not null
DROP TABLE viewPage; 
GO