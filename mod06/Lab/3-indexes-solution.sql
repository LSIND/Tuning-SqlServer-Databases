USE AdventureWorks;
GO

-- 1. ������� ���� ���������� �������
SELECT BusinessEntityID, NationalIDNumber, LoginID, HireDate, JobTitle
FROM HumanResources.Employee
WHERE NationalIDNumber = 14417807;

-- 2. ���������� ������, ����� �������� �������������� � SELECT �� �����

SELECT BusinessEntityID, NationalIDNumber, LoginID, HireDate, JobTitle
FROM HumanResources.Employee
WHERE NationalIDNumber = '14417807';

-- 3. �������� ��� ������ ������� NationalIDNumber ������� HumanResources.Employee �� INT

ALTER TABLE [HumanResources].[Employee] 
ALTER COLUMN [NationalIDNumber] INT NOT NULL;

-- 4. ������� NationalIDNumber �������� ������ ������������� ������� [AK_Employee_NationalIDNumber]. 
-- ������� ������, �������� ��� ������ �������, ������ �������� ������

DROP INDEX [AK_Employee_NationalIDNumber] ON [HumanResources].[Employee]
GO

ALTER TABLE [HumanResources].[Employee] 
ALTER COLUMN [NationalIDNumber] INT NOT NULL;
GO

CREATE UNIQUE NONCLUSTERED INDEX [AK_Employee_NationalIDNumber] 
ON [HumanResources].[Employee]( [NationalIDNumber] ASC );
GO