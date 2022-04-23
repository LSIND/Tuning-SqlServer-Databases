USE AdventureWorks;
GO

-- 1. ���������� ��� ������� Person.Person
SELECT * FROM sys.stats 
WHERE object_id = OBJECT_ID('Person.Person') 
ORDER BY stats_id;
GO

-- 2. ���������� ��� ������� PK_Person_BusinessEntityID (integer IDENTITY)
-- ���������� - ���� ��������, ���-�� �����, ����� ����������� � ��
-- ��������� = 1 / 19972
-- ���������� �������� (RANGE_ROWS = DISTINCT_RANGE_ROWS).
-- ������������� �������� - � ��������� ������ ������������ ��������
DBCC SHOW_STATISTICS('Person.Person','PK_Person_BusinessEntityID');
GO

-- * ����� ������� ������ ������ �������������� ������ WITH STAT_HEADER, DENSITY_VECTOR, HISTOGRAM.
DBCC SHOW_STATISTICS('Person.Person','PK_Person_BusinessEntityID') WITH STAT_HEADER;

-- 3. ���������� ��� ������� IX_Person_LastName_FirstName_MiddleName
-- ��������� ����� � ������� ���������
-- ~ 200 ����� �����������
-- 'Alexander' - EQ_ROWS = 123
DBCC SHOW_STATISTICS('Person.Person','IX_Person_LastName_FirstName_MiddleName')
GO

-- 4. Estimated Execution Plan 
-- �������� ��������� Index Seek (NonClustered) (F4)
-- ��������������� ���-�� ����� = 123 (EQ_ROWS)
SELECT * FROM Person.Person WHERE LastName = N'Alexander';
GO

-- 5. WITH HISTOGRAM
-- 'Adams' -  AVG_RANGE_ROWS = 1.666667.
DBCC SHOW_STATISTICS('Person.Person','IX_Person_LastName_FirstName_MiddleName') WITH HISTOGRAM;
GO

-- 6. �������� ��� RANGE_HI_KEY
-- �������� 'Accah' (����� 'Abbas' � 'Adams')
-- Estimated Execution Plan - �������� ��������� Index Seek (NonClustered) (F4)
-- ��������������� ���-�� ����� = 1.66667 (AVG_RANGE_ROWS)
SELECT * FROM Person.Person WHERE LastName = N'Accah';
GO

-- 7. ������ � ����������
-- ����� ���������� ����� - 19972
-- [All density] - LastName = 0.0008291874
DBCC SHOW_STATISTICS('Person.Person','IX_Person_LastName_FirstName_MiddleName') WITH STAT_HEADER, DENSITY_VECTOR;
GO

-- Estimated Execution Plan - �������� ��������� Index Seek (NonClustered) (F4)
-- ��������������� ���-�� ����� - 16.5605 = 19972 * 0.0008291874
DECLARE @p1 nvarchar(50) = N'Accah'; 
SELECT * FROM Person.Person WHERE LastName = @p1;
GO

-- ��������������� ���-�� ����� = ����� ���-�� ����� * ������ ���������
SELECT 19972 AS total_rows, 0.0008291874 AS [density_vector],
ROUND(19972 * 0.0008291874,4) AS estimated_row_count;
GO

-- * ��� �� ������ = 16.5605, ���� ���� �������� � RANGE_HI_KEY
DECLARE @p1 nvarchar(50) = N'Alonso'; 
SELECT * FROM Person.Person WHERE LastName = @p1;
GO

-- * ��� ���������� ��������� - ��������������� ���-�� ����� = 93 (EQ_ROWS)
SELECT * FROM Person.Person WHERE LastName = N'Alonso';

-- 8. ������ � �������� � ��������� 
-- Estimated Execution Plan - �������� ��������� Clustered Index Scan (F4) 
-- ��������������� ���-�� ����� = 1997.2 - 10% �� ���� ����� ������� = 1 / 19972.
SELECT * FROM Person.Person WHERE LastName = REVERSE(LastName);
GO

-- 8.1 ������ ��� ��������� ���� ������� �������
-- Estimated Execution Plan - �������� ��������� Clustered Index Scan (F4) 
-- ��������������� ���-�� ����� = 1997.2 - 10% �� ���� ����� ������� = 1 / 19972.
SELECT * FROM Person.Person WHERE LastName = FirstName;
GO

-- 9. ������ � ����������� �����������
-- Estimated Execution Plan - �������� ��������� Clustered Index Scan (F4) 
-- ��������������� ���-�� ����� = 24.3312 
SELECT * FROM Person.Person 
WHERE LastName = N'Alonso'
AND MiddleName = N'A';
GO

-- 9.1. AUTO_CREATE_STATISTICS ������ ����� ������ ���������� (�� MiddleName)
-- � Object Explorer ����� ��� ���������� (_WA_Sys_000..), ����������� ��������
SELECT * FROM sys.stats 
WHERE object_id = OBJECT_ID('Person.Person') 
ORDER BY stats_id;
GO

-- 9.2. �������� ����� ���������� _WA_Sys_000..
-- 'A' - RANGE_HI_KEY = 1367.047 �����
DBCC SHOW_STATISTICS('Person.Person','_WA_Sys_00000006_7C4F7684') WITH HISTOGRAM;

-- 9.3. �������������� ��� �������
-- ��������������� ���-�� ����� WHERE LastName = 'Alonso' -> 93
-- ����� ���������� ����� � ������� -> 19972
-- ��������������� ���-�� ����� WHERE MiddleName = 'A' -> 1367,047
-- � Sql Server 2014: Estimate = C * S1 * SQRT(S2) * SQRT(SQRT(S3)) * SQRT(SQRT(SQRT(S4))) �
SELECT  93.0/19972  --selectivity of LastName = Alonso
* SQRT(1367.047/19972) -- square root of selectivity of MiddleName = 'A'
* 19972 -- table cardinality
AS estimated_cardinality;

-- Cardinality will be estimated based on the four most selective predicates

-- * 10 ���������� ��� ������ ��������� EmailPromotion
-- ��������������� ���������� ����� = 3815,15
SELECT * FROM Person.Person 
WHERE LastName = N'Alonso' OR EmailPromotion = 2;
GO

-- ����� ����������
-- EmailPromotion = 1 -> EQ_ROWS = 5096,812
DBCC SHOW_STATISTICS('Person.Person','_WA_Sys_00000009_7C4F7684') WITH HISTOGRAM;

-- Estimate = C * S1 * SQRT(S2) * SQRT(SQRT(S3)) * SQRT(SQRT(SQRT(S4))) � exponential backoff
-- S1 �������� �����������, Sn - ��������
-- OR ����������� � AND
-- (A or B) = not ((not A) and (not B)) 
SELECT 19972 *  (1 -  (1 - 93.0/19972) * (SQRT(1-3777.4/19972)))
AS estimated_cardinality;

-- 11. ������ �������� ����������
-- ���������� � ��������
-- ��������� Database Engine ������������� 50% ������, � ����� �������� ��� ������ � EmailPromotion = 2
CREATE STATISTICS ContactPromotion1  
    ON Person.Person (BusinessEntityID, LastName, EmailPromotion)  
WHERE EmailPromotion = 2  
WITH SAMPLE 50 PERCENT;  
GO  

DBCC SHOW_STATISTICS('Person.Person','ContactPromotion1');


-- 12. AUTO UPDATE
-- ASYNC (��������� � �� �� ���������)
SELECT is_auto_update_stats_on, is_auto_update_stats_async_on from sys.databases

ALTER DATABASE AdventureWorks SET AUTO_UPDATE_STATISTICS_ASYNC ON;
ALTER DATABASE AdventureWorks SET AUTO_UPDATE_STATISTICS_ASYNC OFF;

-- 13. ���������� ���� ���������� ��
EXEC sp_updatestats; 

-- 14. ���������� ���������� ��� ������� � �������
UPDATE STATISTICS Sales.SalesOrderDetail;  --�������
UPDATE STATISTICS Sales.SalesOrderDetail AK_SalesOrderDetail_rowguid;  --������

-- ���������� ���������� CustomerStats1 �� ������ �������� ���� ����� � ������� Customer.
UPDATE STATISTICS Sales.Customer ([AK_Customer_AccountNumber]) WITH FULLSCAN;  