USE AdventureWorks;
GO

-- 1. Index Scan. 
-- ��� ������� � ���, ��� SQL Server �� ����� ����������� ���������� �����������, ��������� �� ����� ����� �������� ��������� ���������� �� ����������� ������� ����������.

SET STATISTICS IO, TIME ON;

DECLARE @SalesPersonID INT;
SELECT @SalesPersonID = 288;

SELECT SalesOrderId, OrderDate
FROM Sales.SalesOrderHeader
WHERE SalesPersonID = @SalesPersonID;
GO


-- 2. WITH RECOMPILE
-- ����� ������ ������������ �������� ������� ���������� �����, ������� ������������ ��� �������� �������.
-- logical reads 698 ������ 409
-- �������� RECOMPILE ������������ ����������� �������� �������� ���������� �� �� ��������.

SET STATISTICS IO, TIME ON;

DECLARE @SalesPersonID INT;
SELECT @SalesPersonID = 288;

SELECT SalesOrderId, OrderDate
FROM Sales.SalesOrderHeader
WHERE SalesPersonID= @SalesPersonID
OPTION (RECOMPILE);