USE tempdb;
GO
-- 1 TempDb: ���-�� ������ ����� ���-�� ���� ���������� 
SELECT *
FROM sys.database_files;


-- 2. ����� ������ ������ � �� (Free � Used)
SELECT name, physical_name, SUM(size)*1.0/128 AS [size in MB] -- size * 8 (page) / 1024
FROM sys.database_files
group by name, physical_name;

-- 3. ����� ������ ���������� ������������ � �� 
SELECT b.name, b.physical_name, 
SUM(unallocated_extent_page_count) AS [free pages], 
(SUM(unallocated_extent_page_count)*1.0/128) AS [free space in MB]
FROM sys.dm_db_file_space_usage AS a 
join sys.database_files AS b
on a.file_id = b.file_id
GROUP BY b.name, b.physical_name;

-- 4. ������ ������������ � ��, ������������ Version Store
SELECT SUM(version_store_reserved_page_count) AS [version store pages used],
(SUM(version_store_reserved_page_count)*1.0/128) AS [version store space in MB]
FROM sys.dm_db_file_space_usage;

-- 5. ������ ������������ � ��, ������������ ����������� ���������
SELECT SUM(internal_object_reserved_page_count) AS [internal object pages used],
(SUM(internal_object_reserved_page_count)*1.0/128) AS [internal object space in MB]
FROM sys.dm_db_file_space_usage;

-- 6. ������ ������������ � ��, ������������ �������������
SELECT SUM(user_object_reserved_page_count) AS [user object pages used],
(SUM(user_object_reserved_page_count)*1.0/128) AS [user object space in MB]
FROM sys.dm_db_file_space_usage;

-- 7. ��������� ������ ����� �������� ��������� ������� #
select * into #testtable 
from AdventureWorks.Sales.SalesOrderDetail;
GO

DROP TABLE IF EXISTS #testtable;

-- 8. ����� ������, ������������ ����������� ��������� �� �������
SELECT session_id,
  SUM(internal_objects_alloc_page_count) AS task_internal_objects_alloc_page_count,
  SUM(internal_objects_dealloc_page_count) AS task_internal_objects_dealloc_page_count
FROM sys.dm_db_task_space_usage
GROUP BY session_id;