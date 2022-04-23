-- 1. ������ ���������
-- rowstore clustered index [PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID]
-- database engine ��������� leaf-level page scan ��� ������������� �������� ��� ProductID � OrderQty; 

SELECT ProductID
 ,SUM(OrderQty) AS ProductTotalQuantitySales
FROM [Sales].[SalesOrderDetail]
GROUP BY ProductID
ORDER BY ProductID;

-- 1.1. �������� ������������� ������� COLUMNSTORE
CREATE NONCLUSTERED COLUMNSTORE INDEX ncci ON [Sales].[SalesOrderDetail]
(ProductID, OrderQty);
GO

-- 1.2 ���� ������� � �������������� ������� COLUMNSTORE � ��� ����
SELECT ProductID
 ,SUM(OrderQty) AS ProductTotalQuantitySales
FROM [Sales].[SalesOrderDetail]
GROUP BY ProductID
ORDER BY ProductID;

ALTER INDEX ncci ON [Sales].[SalesOrderDetail]
DISABLE; 
 
 SELECT ProductID
 ,SUM(OrderQty) AS ProductTotalQuantitySales
FROM [Sales].[SalesOrderDetail]
GROUP BY ProductID
ORDER BY ProductID;
GO

-- 2. ���������� ���������� �������
ALTER INDEX ncci ON [Sales].[SalesOrderDetail]
REBUILD; 

select * from sys.indexes
where name = 'ncci';

-- ���������� ���������� NULL
DBCC SHOW_STATISTICS('[Sales].[SalesOrderDetail]','ncci');

-- �������� �� �������� columnstore �� ������� �����
-- total_rows = ����� ����� �����, ������� ��������� �������� � ������ �����

SELECT * FROM sys.column_store_row_groups;

-- ���������� �� ����� ������ ��� ������� �������� ������� � ������� columnstore. 
-- ��� ������� ������� ������ ����� ������� ���� ������� �������. 
-- ������� � 1 ������� ����� � 4 ��������� ���������� 4 ������
-- encoding_type: 2 = VALUE_HASH_BASED � ����������� ��� �������� ������� � ������ ���������� � �������

SELECT * FROM sys.column_store_segments; 

SELECT * FROM sys.column_store_dictionaries; -- DELTA STORESELECT * FROM sys.column_store_row_groups WHERE delta_store_hobt_id IS NOT NULL; -- DELTASTORE ����� ���������� ������UPDATE[Sales].[SalesOrderDetail]SET [OrderQty] = [OrderQty] + 8WHERE [SalesOrderID] BETWEEN 43660 AND 43895;
SELECT * FROM sys.column_store_row_groups 
WHERE delta_store_hobt_id IS NOT NULL; 

-- UPDATE = DELETE ����� INSERT
-- Deleted Bitmap

SELECT * FROM sys.internal_partitions
WHERE internal_object_type_desc = 'COLUMN_STORE_DELETE_BITMAP';
GO