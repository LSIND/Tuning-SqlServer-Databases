-- ������ 1 
-- exclusive lock �� 1 ������ Sales.SalesTerritory ������ ����������
-- XLOCK ����������� ���������� ����������� � ������������ �� ���������� ����������: ����� �������� ������� ROWLOCK, PAGLOCK ��� TABLOCK
-- The XLOCK table hint can be considered unreliable. This is because the SQL engine can ignore the hint if the data being accessed hasn�t changed since the oldest open transaction!
USE AdventureWorks;
GO

BEGIN TRANSACTION 
	UPDATE Sales.SalesTerritory 
	WITH (XLOCK) --TABLOCKX
	SET [Name] = 'Test'
	WHERE TerritoryID = 3 

-- ������ 2
ROLLBACK