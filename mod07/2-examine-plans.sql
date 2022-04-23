USE AdventureWorks;
GO
-- 1. ����������� Estimated execution plan
-- �������� ��� � Ctrl + L (��� Display Estimated Execution Plan)
-- ����������� ���������� ������� ���������. �������� ���������

SELECT pp.ProductID, pp.Name , ss.SalesOrderID, ss.SalesOrderDetailID
FROM Production.Product AS pp 
JOIN Sales.SalesOrderDetail AS ss
ON pp.ProductID = ss.ProductID
WHERE pp.ProductNumber LIKE 'FW%';

-- 2. ����������� Actual execution plan
-- ������ Ctrl + M (��� Include Actual Exection Plan)
-- ��������� ���
-- ����������� ���������� ������� ���������. �������� ���������
-- Show Execution Plan XML
SELECT pp.ProductID, pp.Name , ss.SalesOrderID, ss.SalesOrderDetailID
FROM Production.Product AS pp 
JOIN Sales.SalesOrderDetail AS ss
ON pp.ProductID=ss.ProductID
WHERE pp.ProductNumber LIKE 'FW%';

-- 3. ��������� ���������� ���� Save Execution Plan As... � \Tuning-SqlServer-Databases\mod07\demo2.sqlplan


-- Step 4 - Live Query Statistics
-- ��������� actual plan = Ctrl + M (��� Include Actual Exection Plan)
-- �������� Include Live Query Statistics
-- ��������� ���

SELECT pp.ProductID, pp.Name , ss.SalesOrderID, ss.SalesOrderDetailID, pr.FirstName
FROM Production.Product AS pp 
JOIN Sales.SalesOrderDetail AS ss
ON pp.ProductID=ss.ProductID
JOIN Person.Person AS pr
ON  CAST(pr.FirstName AS char(1)) = CAST(pp.Name AS char(1));

-- 5. XML estimated execution plan
-- ��������� Live Query Statistics
-- SET SHOWPLAN_XML ON, ����������� XML 
SET SHOWPLAN_XML ON;
GO
SELECT pp.ProductID, pp.Name , ss.SalesOrderID, ss.SalesOrderDetailID
FROM Production.Product AS pp 
JOIN Sales.SalesOrderDetail AS ss
ON pp.ProductID=ss.ProductID
WHERE pp.ProductNumber LIKE 'FW%';
GO
SET SHOWPLAN_XML OFF;
GO

-- 6. XML actual execution plan
-- SET STATISTICS XML ON

SET STATISTICS XML ON;
GO
SELECT pp.ProductID, pp.Name , ss.SalesOrderID, ss.SalesOrderDetailID
FROM Production.Product AS pp 
JOIN Sales.SalesOrderDetail AS ss
ON pp.ProductID=ss.ProductID
WHERE pp.ProductNumber LIKE 'FW%';
GO
SET STATISTICS XML OFF;
GO


-- 7. Text estimated execution plan
-- SHOWPLAN_TEXT ON

SET SHOWPLAN_TEXT ON;
GO
SELECT pp.ProductID, pp.Name , ss.SalesOrderID, ss.SalesOrderDetailID
FROM Production.Product AS pp 
JOIN Sales.SalesOrderDetail AS ss
ON pp.ProductID=ss.ProductID
WHERE pp.ProductNumber LIKE 'FW%';
GO
SET SHOWPLAN_TEXT OFF;
GO

-- 8. Text estimated execution plan
-- SHOWPLAN_ALL

SET SHOWPLAN_ALL ON;
GO
SELECT pp.ProductID, pp.Name , ss.SalesOrderID, ss.SalesOrderDetailID
FROM Production.Product AS pp 
JOIN Sales.SalesOrderDetail AS ss
ON pp.ProductID=ss.ProductID
WHERE pp.ProductNumber LIKE 'FW%';
GO
SET SHOWPLAN_ALL OFF;
GO

-- 9. Text actual execution plan
-- SET STATISTICS PROFILE ON
SET STATISTICS PROFILE ON;
GO
SELECT pp.ProductID, pp.Name , ss.SalesOrderID, ss.SalesOrderDetailID
FROM Production.Product AS pp 
JOIN Sales.SalesOrderDetail AS ss
ON pp.ProductID=ss.ProductID
WHERE pp.ProductNumber LIKE 'FW%';
GO
SET STATISTICS PROFILE OFF;
GO