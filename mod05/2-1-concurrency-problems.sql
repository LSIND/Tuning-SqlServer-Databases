-- 2.1

USE AdventureWorks;
GO

-- I. ������� ������� �������� ����������
SELECT name, snapshot_isolation_state_desc, is_read_committed_snapshot_on 
FROM sys.databases;

-- II. ����� ����� �������� ��� ��������� CustomerID = 19169: 725-555-0131
SELECT CustomerID,  [PhoneNumber]
FROM [Sales].[CustomerPII]
WHERE CustomerID = 19169;


-- III. ������ � ������� �������� �������� ����������
-- ��������� "������ 1" � 2-2-concurrency.sql

-- 1. Dirty Read � READ UNCOMMITTED
-- ISOLATION LEVEL READ UNCOMMITTED - ����� ��������: 999-999-9999
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
GO
SELECT CustomerID,  [PhoneNumber]
FROM [Sales].[CustomerPII]
WHERE CustomerID = 19169;
GO

-- 2. READ COMMITTED isolation � READ_COMMITTED_SNAPSHOT OFF ������������� DIRTY READ
-- READCOMMITTEDLOCK table hint ��������� ������������ �����
-- ��������

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
GO
SELECT CustomerID,  [PhoneNumber]
FROM [Sales].[CustomerPII] WITH (READCOMMITTEDLOCK)
WHERE CustomerID = 19169
GO

-- ��������� "������ 2" � 2-2-concurrency.sql
-- ���������� ������ ������ ��������: 725-555-0131


-- 3. non-repeatable read � READ COMMITTED isolation � READ_COMMITTED_SNAPSHOT OFF

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION
SELECT CustomerID,  [PhoneNumber]
FROM [Sales].[CustomerPII] WITH (READCOMMITTEDLOCK)
WHERE CustomerID = 19169;

-- ��������� "������ 3" � 2-2-concurrency.sql
-- ��������� ������; ������ ��������: 333-333-3333

SELECT CustomerID,  [PhoneNumber]
FROM [Sales].[CustomerPII] WITH (READCOMMITTEDLOCK)
WHERE CustomerID = 19169;
COMMIT

-- 4. REPEATABLE READ isolation ������������� non-repeatable read
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
GO
BEGIN TRANSACTION
	SELECT CustomerID, [PhoneNumber]
	FROM [Sales].[CustomerPII]
	WHERE CustomerID = 19169;

-- ��������� "������ 4" � 2-2-concurrency.sql
-- "������ 4" �������
-- ��������� ������; ������ ��������: 333-333-3333. "������ 4" ����� ���������� � ������� ������ �� 444-444-4444
	SELECT CustomerID,  [PhoneNumber]
	FROM [Sales].[CustomerPII]
	WHERE CustomerID = 19169;
COMMIT

-- 5. phantom read ��� REPEATABLE READ 
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
GO
BEGIN TRANSACTION
	SELECT COUNT(*) AS CustCount 
	FROM [Sales].[CustomerPII]
	WHERE [PhoneNumber] < '111-555-2222';

-- ��������� "������ 5" � 2-2-concurrency.sql
-- ��������� ������. �������� ���������� ���������� ����������� �� 1
	SELECT COUNT(*) AS CustCount 
	FROM [Sales].[CustomerPII]
	WHERE [PhoneNumber] < '111-555-2222';
COMMIT

-- 6. SERIALIZABLE ������������� phantom read
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
	SELECT COUNT(*) AS CustCount 
	FROM [Sales].[CustomerPII]
	WHERE [PhoneNumber] < '111-555-2222';

-- ��������� "������ 5" � 2-2-concurrency.sql. ������ 5 �������
-- ��������� ������. �������� ���������� ���������� �� ����������
	SELECT COUNT(*) AS CustCount 
	FROM [Sales].[CustomerPII]
	WHERE [PhoneNumber] < '111-555-2222';
COMMIT

-- 7. READ COMMITTED � READ_COMMITTED_SNAPSHOT ON
-- �������� ����� �������� ��� CustomerID = 19169
UPDATE [Sales].[CustomerPII]
SET [PhoneNumber] = N'170-555-0127' 
WHERE CustomerID = 19169;
GO

-- ��������� "������ 6" � 2-2-concurrency.sql. 
-- ��������� ������. ������ �������
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
GO
BEGIN TRANSACTION 
	SELECT CustomerID, [PhoneNumber]
	FROM [Sales].[CustomerPII]
	WHERE CustomerID = 19169;

-- ��������� "������ 7" � 2-2-concurrency.sql. 
-- ��������� ������: 616-666-6666
	SELECT CustomerID, [PhoneNumber]
	FROM [Sales].[CustomerPII]
	WHERE CustomerID = 19169;
COMMIT

-- 8. SNAPSHOT 
UPDATE [Sales].[CustomerPII]
SET [PhoneNumber] = N'170-555-0127' 
WHERE CustomerID = 19169;
GO

-- ��������� "������ 6" � 2-2-concurrency.sql. 
-- ��������� ������.

/*ALTER DATABASE AdventureWorks
SET ALLOW_SNAPSHOT_ISOLATION ON
GO */

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
GO
BEGIN TRANSACTION 
	SELECT CustomerID, [PhoneNumber]
	FROM [Sales].[CustomerPII]
	WHERE CustomerID = 19169;

-- ��������� "������ 7" � 2-2-concurrency.sql. 
-- ��������� ������: �������� �� ���������� � ������ ���� ����������
SELECT CustomerID, [PhoneNumber]
	FROM [Sales].[CustomerPII]
	WHERE CustomerID = 19169;
COMMIT

-- 9. �������� ��� ���������� � SNAPSHOT:
UPDATE [Sales].[CustomerPII]
SET [PhoneNumber] = N'170-555-0127' 
WHERE CustomerID = 19169;
GO
-- ��������� "������ 6" � 2-2-concurrency.sql. 
-- ��������� ������. ��������
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
GO
BEGIN TRANSACTION 
	UPDATE [Sales].[CustomerPII]
	SET [PhoneNumber] = N'777-555-7777'
	WHERE CustomerID = 19169;

-- ��������� "������ 7" � 2-2-concurrency.sql. 
-- ������: ����� ����������

-- ���������, ��� ��� �������� ����������
SELECT @@TRANCOUNT;