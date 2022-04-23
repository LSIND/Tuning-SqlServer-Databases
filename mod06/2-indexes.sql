USE AdventureWorks;
GO

-- 1. HEAP
SELECT * FROM sys.partitions
where index_id = 0; -- 0 - ����

SELECT * FROM sys.objects
where is_ms_shipped = 0 -- ������ �� ������ ���������� ����������� SQL Server.
AND type = 'U'
order by name; 

-- ��� ���������������� heaps � ��
SELECT DISTINCT o.name AS heap_name, index_id
FROM sys.partitions AS p
JOIN sys.objects AS o
ON o.object_id = p.object_id
WHERE index_id = 0
AND o.is_ms_shipped = 0; 

-- ��������� �� ������ �������� IAM ��� ���� (first_iam_page) � sys.system_internals_allocation_units 
SELECT OBJECT_NAME(p.object_id) AS ObjName, u.first_iam_page, u.type_desc, u.total_pages, u.data_pages 
FROM sys.allocation_units AS a
JOIN sys.partitions AS p 
ON p.hobt_id = a.container_id
AND a.type in (1,3) -- ��� ������� �������������, ����� 0 = ���������
JOIN sys.system_internals_allocation_units AS u
ON u.allocation_unit_id = a.allocation_unit_id
JOIN sys.objects AS o
ON o.object_id = p.object_id
WHERE p.index_id = 0 AND o.is_ms_shipped = 0;
GO


-- 2. ������� rowstore

DROP SCHEMA IF EXISTS Proseware;
GO

CREATE SCHEMA Proseware;
GO

DROP TABLE IF EXISTS Proseware.CampaignMailer;
GO

-- 2.1 ������� Proseware.CampaignMailer � ���������� ������ - ��������� ���� �� GUID
CREATE TABLE Proseware.CampaignMailer
( 
CampaignMailerID uniqueidentifier NOT NULL 
	CONSTRAINT [PK_TestTable] PRIMARY KEY 
	CONSTRAINT [DF_Id] DEFAULT NEWID(),
CampaignID int NOT NULL,
MailerCount int NOT NULL
);

-- 3. Single Column � Multicolumn Indexes

SELECT BusinessEntityID 
FROM Person.Person 
WHERE FirstName = N'Xavier' 
AND EmailPromotion = 1 
AND ModifiedDate < '2015-01-01';
GO

-- Single Column
CREATE NONCLUSTERED INDEX ix_person_firstname ON Person.Person(Firstname);
CREATE NONCLUSTERED INDEX ix_person_emailpromotion ON Person.Person(EmailPromotion);
CREATE NONCLUSTERED INDEX ix_person_modifieddate ON Person.Person(ModifiedDate);
GO

DROP INDEX Person.Person.ix_person_firstname;
DROP INDEX Person.Person.ix_person_emailpromotion;
DROP INDEX Person.Person.ix_person_modifieddate;
GO

-- Multicolumn
-- optimal query execution plan = single index seek on the multicolumn index
CREATE NONCLUSTERED INDEX ix_person_firstname_emailpromotion_modifieddate 
ON Person.Person(Firstname,Emailpromotion,ModifiedDate);

GO
DROP INDEX Person.Person.ix_person_firstname_emailpromotion_modifieddate;
GO

-- 4. INDEX WHERE
SELECT [Name],[Color],[ListPrice],[ReorderPoint] 
FROM Production.Product
--WITH (INDEX(ix_product_color_filtered))
WHERE Color IS NOT NULL
AND ReorderPoint < 500;

CREATE INDEX ix_product_color_filtered
ON Production.Product (Color)
WHERE Color IS NOT NULL
AND ReorderPoint < 500; 

-- ����������, ��������������� ����� �������, ����� � ��������
DBCC SHOW_STATISTICS('Production.Product','ix_product_color_filtered');

DROP INDEX IF EXISTS Production.Product.ix_product_color_filtered;

-- 5. ������� � SARGable Predicates
SELECT * FROM Person.Person 
WHERE LastName = N'Accah';

SELECT * FROM Person.Person 
WHERE 100 < BusinessEntityID;

SELECT * FROM [Production].[ProductInventory]
WHERE [Quantity] BETWEEN 2 AND 10;

SELECT * FROM Person.Person 
WHERE ModifiedDate = '2007-11-04';

-- SARGable Wildcard - seek
SELECT LastName
FROM Person.Person
WHERE LastName LIKE N'L%'; 

-- NonSARGable Wildcard - scan
SELECT LastName
FROM Person.Person
WHERE LastName LIKE N'%L'; 

-- ��������� SARGability
SELECT AddressID, AddressLine1, AddressLine2, City
FROM Person.Address
WHERE LEFT(City,1) = 'M'; --scan �� �������

SELECT AddressID, AddressLine1, AddressLine2, City
FROM Person.Address
WHERE City LIKE 'M%'; --seek ��� scan �� ������� PK


-- 6. Top 10 Externally Fragmented Indexes
DECLARE @db int = db_id();
SELECT TOP 10 ips.avg_fragmentation_in_percent, i.name
FROM sys.indexes AS i
CROSS APPLY sys.dm_db_index_physical_stats(@db, i.object_id, i.index_id, NULL, NULL) AS ips
ORDER BY ips.avg_fragmentation_in_percent DESC; 
GO

--7. Top 10 Internally Fragmented Indexes
DECLARE @db int = db_id();
SELECT TOP 10 ips.avg_page_space_used_in_percent , i.name
FROM sys.indexes AS i
CROSS APPLY sys.dm_db_index_physical_stats(@db, i.object_id, i.index_id, NULL,
'DETAILED') AS ips
WHERE ips.avg_page_space_used_in_percent > 0
ORDER BY ips.avg_page_space_used_in_percent ASC; 


-- 8. ��������� �������� �� ������������� ��������
SELECT * FROM sys.dm_db_missing_index_details;

-- �������� � �������� ������� ���� ������, � ������� ����������� ������ �� index_handle
SELECT * FROM sys.dm_db_missing_index_columns(8)

SELECT MI.index_handle, MI.statement AS Obj, COL.column_name, COL.column_usage
FROM sys.dm_db_missing_index_details AS MI
CROSS APPLY sys.dm_db_missing_index_columns(MI.index_handle) AS COL;

-- �������� � ������� ������������� �������� (����� ���������������� ��������)
SELECT * FROM sys.dm_db_missing_index_group_stats;
SELECT * FROM sys.dm_db_missing_index_groups;

SELECT MI.index_handle, MI.statement AS Obj, COL.column_name, COL.column_usage,
GS.unique_compiles, GS.user_scans, GS.user_seeks
FROM sys.dm_db_missing_index_details AS MI
CROSS APPLY sys.dm_db_missing_index_columns(MI.index_handle) AS COL
JOIN sys.dm_db_missing_index_groups AS IG
ON IG.index_handle = MI.index_handle
JOIN sys.dm_db_missing_index_group_stats AS GS
ON GS.group_handle = IG.index_group_handle;


-- 9 ������������
-- 9.1 ������� 10000 ����� � ������� Proseware.CampaignMailer
SET NOCOUNT ON;
DECLARE @i INT = 0
WHILE @i < 10000
BEGIN
	INSERT Proseware.CampaignMailer (CampaignID, MailerCount)
	VALUES (RAND()*10000, (RAND()*1000) + 500);
	SET @i += 1;
END

-- 9.2 avg_fragmentation_in_percent ~ 95%:
SELECT object_name(object_id) AS object_name, avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('Proseware.CampaignMailer'), NULL, NULL, 'DETAILED');
GO

-- 9.3 �������� ������������������ ������� 
--  allocate_page_page_id - �� �� �������
WITH dataCTE
AS
(
	SELECT allocated_page_page_id, next_page_page_id, previous_page_page_id
	FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('Proseware.CampaignMailer'), 1, NULL, 'DETAILED')
	WHERE is_allocated = 1
	AND page_type_desc = 'DATA_PAGE'
),
pageCTE
AS
(
	SELECT allocated_page_page_id, next_page_page_id, 1 AS page_sequence
	FROM dataCTE 
	WHERE previous_page_page_id IS NULL
	UNION ALL
	SELECT d.allocated_page_page_id, d.next_page_page_id, p.page_sequence + 1 AS page_sequence
	FROM pageCTE AS p
	JOIN dataCTE AS d
	ON d.allocated_page_page_id = p.next_page_page_id
)
SELECT allocated_page_page_id, page_sequence
FROM pageCTE
ORDER BY page_sequence;

-- 9.4 �������� ������� � PK IDENTITY � ������� 10000 �����
DROP TABLE IF EXISTS Proseware.CampaignPrintRun;

CREATE TABLE Proseware.CampaignPrintRun
( 
CampaignPrintRunID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
  CampaignID int NOT NULL,
  PrintRunID int NOT NULL
);
GO

SET NOCOUNT ON;
DECLARE @i INT = 0
WHILE @i < 10000
BEGIN
	INSERT Proseware.CampaignPrintRun (CampaignID, PrintRunID)
	VALUES (RAND()*10000, (RAND()*1000) + 500);
	SET @i += 1;
END
GO

-- 9.5 avg_fragmentation_in_percent ~ 4%
SELECT object_name(object_id) AS object_name, avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('Proseware.CampaignPrintRun'), NULL, NULL, 'DETAILED');
GO


-- 9.6 �������� ������������������ ������� 
--  allocate_page_page_id - �� �������
WITH dataCTE
AS
(
	SELECT allocated_page_page_id, next_page_page_id, previous_page_page_id
	FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('Proseware.CampaignPrintRun'), 1, NULL, 'DETAILED')
	WHERE is_allocated = 1
	AND page_type_desc = 'DATA_PAGE'
),
pageCTE
AS
(
	SELECT allocated_page_page_id, next_page_page_id, 1 AS page_sequence
	FROM dataCTE 
	WHERE previous_page_page_id IS NULL
	UNION ALL
	SELECT d.allocated_page_page_id, d.next_page_page_id, p.page_sequence + 1 AS page_sequence
	FROM pageCTE AS p
	JOIN dataCTE AS d
	ON d.allocated_page_page_id = p.next_page_page_id
)
SELECT allocated_page_page_id, page_sequence
FROM pageCTE
ORDER BY page_sequence;

DROP TABLE IF EXISTS Proseware.CampaignPrintRun;
GO