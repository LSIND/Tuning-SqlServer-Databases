-------------------------------------------------------
-- 1. ��������������� ��������� ������� ������� Person.ContactType ���� ������ AdventureWorks.
-------------------------------------------------------

USE AdventureWorks;
GO

SELECT db_name(database_id) AS [Database_Name], 
object_name([object_id]) AS [Table_Name],
allocation_unit_type, allocation_unit_type_desc
allocated_page_file_id, allocated_page_page_id, page_type, page_type_desc 
FROM sys.dm_db_database_page_allocations(db_id('AdventureWorks'), object_id('Person.ContactType'),NULL,NUll,'DETAILED');
GO

-- ������ ��������: 2 IAM pages, index page, data page (page_type_desc). 
-- �������� � ������� allocated_page_page_id column ��� DATA_PAGE


-------------------------------------------------------
-- 2. ��������������� ��������� ������� ������� Person.Contact
-- �������� ���� trace flag 3604
-- �������� � DBCC PAGE �������� allocated_page_page_id ��� DATA_PAGE
-------------------------------------------------------

DBCC TRACEON(3604);
GO

DECLARE @dbid int;
SELECT @dbid = db_id(N'AdventureWorks');

DBCC PAGE(@dbid, 1, allocated_page_page_id, 2)
GO

----

SELECT * FROM sys.dm_db_page_info ( db_id(N'AdventureWorks'), 1, allocated_page_page_id, 'DETAILED' );