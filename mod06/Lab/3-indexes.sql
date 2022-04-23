USE AdventureWorks;
GO

-- 1. Оцените план следующего запроса
SELECT BusinessEntityID, NationalIDNumber, LoginID, HireDate, JobTitle
FROM HumanResources.Employee
WHERE NationalIDNumber = 14417807;

-- 2. Перепишите запрос, чтобы избежать предупреждений в SELECT на Плане


-- 3. Изучите тип данных столбца таблицы HumanResources.Employee. Измените при необходимости


-- 4. Создайте индекс