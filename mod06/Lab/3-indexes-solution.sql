USE AdventureWorks;
GO

-- 1. Оцените план следующего запроса
SELECT BusinessEntityID, NationalIDNumber, LoginID, HireDate, JobTitle
FROM HumanResources.Employee
WHERE NationalIDNumber = 14417807;

-- 2. Перепишите запрос, чтобы избежать предупреждений в SELECT на Плане

SELECT BusinessEntityID, NationalIDNumber, LoginID, HireDate, JobTitle
FROM HumanResources.Employee
WHERE NationalIDNumber = '14417807';

-- 3. Измените тип данных столбца NationalIDNumber таблицы HumanResources.Employee на INT

ALTER TABLE [HumanResources].[Employee] 
ALTER COLUMN [NationalIDNumber] INT NOT NULL;

-- 4. Столбец NationalIDNumber является частью некластерного индекса [AK_Employee_NationalIDNumber]. 
-- Удалите индекс, измените тип данных столбца, заново создайте индекс

DROP INDEX [AK_Employee_NationalIDNumber] ON [HumanResources].[Employee]
GO

ALTER TABLE [HumanResources].[Employee] 
ALTER COLUMN [NationalIDNumber] INT NOT NULL;
GO

CREATE UNIQUE NONCLUSTERED INDEX [AK_Employee_NationalIDNumber] 
ON [HumanResources].[Employee]( [NationalIDNumber] ASC );
GO