USE AdventureWorks;
GO

-- 1. ќцените план следующего запроса
SELECT BusinessEntityID, NationalIDNumber, LoginID, HireDate, JobTitle
FROM HumanResources.Employee
WHERE NationalIDNumber = 14417807;

-- 2. ѕерепишите запрос, чтобы избежать предупреждений в SELECT на ѕлане


-- 3. »зучите тип данных столбца таблицы HumanResources.Employee. »змените при необходимости


-- 4. —оздайте индекс