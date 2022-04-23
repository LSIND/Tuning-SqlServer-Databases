
-- 1. ��������� Query Store � �������
USE master;
GO
ALTER DATABASE AdventureWorks
SET QUERY_STORE = ON;

-- 2. ��������� ����� Query Store
USE master;
GO
ALTER DATABASE AdventureWorks
SET QUERY_STORE = ON
    (
      OPERATION_MODE = READ_WRITE,
      CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 90),
      DATA_FLUSH_INTERVAL_SECONDS = 900,
	  QUERY_CAPTURE_MODE = AUTO,
      MAX_STORAGE_SIZE_MB = 1024,
      INTERVAL_LENGTH_MINUTES = 60,
	  MAX_PLANS_PER_QUERY = 200
    );

-- 3. �������� ����� Query Store
USE AdventureWorks;
GO
SELECT * FROM sys.database_query_store_options;

-- 5. ����������
USE master;
GO
ALTER DATABASE AdventureWorks
SET QUERY_STORE = OFF;
GO


-- 5. ��������� Query Store ��� �� TSQL
USE master;
GO

ALTER DATABASE [TSQL] SET QUERY_STORE = ON;

-- 5.1 ������� ������ Query Store
ALTER DATABASE [TSQL] SET QUERY_STORE CLEAR;

-- 5.2 ��������� ����� (����������� ���������)
-- INTERVAL_LENGTH_MINUTES = �������� ������������� ���������� � ������� (1, 5, 10, 15, 30, 60 ��� 1440). �� ��������� � 60 �����.
-- DATA_FLUSH_INTERVAL_SECONDS = ������ ����������� ������ ������ ��������� �������� �� ���� � ��������. �� ��������� - 900 ������ (15 ���.)
ALTER DATABASE [TSQL] SET QUERY_STORE (INTERVAL_LENGTH_MINUTES = 1, DATA_FLUSH_INTERVAL_SECONDS = 60)

-- 5.3. ��������� �������� load_script1.sql (����� ���������� ~ 60 �����)

-- 5.4 � Object Explorer -> �������� �� TSQL -> Query Store -> Operation Mode = Read Write

-- 5.5 ��������� ������ ��������� Query Store 
ALTER DATABASE [TSQL]
SET QUERY_STORE (MAX_STORAGE_SIZE_MB = 150);

-- 5.6 ����� Overall Resource Consumption
-- Configure -> Time Interval = Last Hour, agg in Minutes
-- query id (x-axis �������)

-- 5.7 ����� Tracked Queries
-- � ����� ������ query id �� �.5.6. -> ������� ������ ��� �������


-- 6. ��� ��������: ������� ��������� ������� ##wideplan
CREATE TABLE ##wideplan (id INT);

-- 6.1 � ��� ���� ��������� ���������� ����� � Sales.Orders 
-- ���������� ���������� ���������� � ����� ������ ����� ���� �������
INSERT INTO TSQL.Sales.Orders (custid,empid,orderdate,requireddate,shippeddate,shipperid,freight,shipname,shipaddress,shipcity,shipregion,shippostalcode,shipcountry)
SELECT custid,empid,orderdate,requireddate,shippeddate,shipperid,freight,shipname,shipaddress,shipcity,shipregion,shippostalcode,shipcountry
FROM TSQL.Sales.Orders

-- 6.2 �������� ����� Tracked Queries: ������������� ����� ����

-- 6.3 ����� Regressed Queries
-- Configure -> Time Interval = Last 5 minutes: ALL

-- 6.4 ����� Tracked Queries 
-- ������� ���� ������� (�����) � ������ Force Plan.

-- 6.5 �������� ����� Top Resource Consumers - ����� ���� ����������� V

-- 6.6 ����� Tracked Queries -> Unforce

-- 6.7 ���������� ��������
CREATE TABLE ##stopload (id int)