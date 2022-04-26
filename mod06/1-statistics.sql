USE AdventureWorks;
GO

-- 1. Статистика для таблицы Person.Person
SELECT * FROM sys.stats 
WHERE object_id = OBJECT_ID('Person.Person') 
ORDER BY stats_id;
GO

-- 2. Статистика для индекса PK_Person_BusinessEntityID (integer IDENTITY)
-- Метаданные - дата создания, кол-во строк, шагов гистограммы и тд
-- Плотность = 1 / 19972
-- Уникальные значения (RANGE_ROWS = DISTINCT_RANGE_ROWS).
-- Распределение нечеткое - в последней строке большиснство значений
DBCC SHOW_STATISTICS('Person.Person','PK_Person_BusinessEntityID');
GO

-- * Можно вывести только нужные результирующие наборы WITH STAT_HEADER, DENSITY_VECTOR, HISTOGRAM.
DBCC SHOW_STATISTICS('Person.Person','PK_Person_BusinessEntityID') WITH STAT_HEADER;

-- 3. Статистика для индекса IX_Person_LastName_FirstName_MiddleName
-- Несколько строк в векторе плотности
-- ~ 200 шагов гистограммы
-- 'Alexander' - EQ_ROWS = 123
DBCC SHOW_STATISTICS('Person.Person','IX_Person_LastName_FirstName_MiddleName');
GO

-- 4. Estimated Execution Plan 
-- Свойства оператора Index Seek (NonClustered) (F4)
-- Приблизительное кол-во строк = 123 (EQ_ROWS)
SELECT * FROM Person.Person WHERE LastName = N'Alexander';
GO

-- 5. WITH HISTOGRAM
-- 'Adams' -  AVG_RANGE_ROWS = 1.666667.
DBCC SHOW_STATISTICS('Person.Person','IX_Person_LastName_FirstName_MiddleName') WITH HISTOGRAM;
GO

-- 6. Значения вне RANGE_HI_KEY
-- Значение 'Accah' (между 'Abbas' и 'Adams')
-- Estimated Execution Plan - свойства оператора Index Seek (NonClustered) (F4)
-- Приблизительное кол-во строк = 1.66667 (AVG_RANGE_ROWS)
SELECT * FROM Person.Person WHERE LastName = N'Accah';
GO

-- 7. Запрос с параметром
-- Общее количество строк - 19972
-- [All density] - LastName = 0.0008291874
DBCC SHOW_STATISTICS('Person.Person','IX_Person_LastName_FirstName_MiddleName') WITH STAT_HEADER, DENSITY_VECTOR;
GO

-- Estimated Execution Plan - свойства оператора Index Seek (NonClustered) (F4)
-- Приблизительное кол-во строк - 16.5605 = 19972 * 0.0008291874
DECLARE @p1 nvarchar(50) = N'Accah'; 
SELECT * FROM Person.Person WHERE LastName = @p1;
GO

-- Приблизительное кол-во строк = Общее кол-во строк * вектор плотности
SELECT 19972 AS total_rows, 0.0008291874 AS [density_vector],
ROUND(19972 * 0.0008291874,4) AS estimated_row_count;
GO

-- * Тот же расчет = 16.5605, даже если значение в RANGE_HI_KEY
DECLARE @p1 nvarchar(50) = N'Alonso'; 
SELECT * FROM Person.Person WHERE LastName = @p1;
GO

-- * Без объявления параметра - Приблизительное кол-во строк = 93 (EQ_ROWS)
SELECT * FROM Person.Person WHERE LastName = N'Alonso';

-- 8. Запрос с функцией в предикате 
-- Estimated Execution Plan - свойства оператора Clustered Index Scan (F4) 
-- Приблизительное кол-во строк = 1997.2 - 10% от всех строк таблицы = 1 / 19972.
SELECT * FROM Person.Person WHERE LastName = REVERSE(LastName);
GO

-- 8.1 Запрос при сравнении двух стобцов таблицы
-- Estimated Execution Plan - свойства оператора Clustered Index Scan (F4) 
-- Приблизительное кол-во строк = 1997.2 - 10% от всех строк таблицы = 1 / 19972.
SELECT * FROM Person.Person WHERE LastName = FirstName;
GO

-- 9. Запрос с несколькими предикатами
-- Estimated Execution Plan - свойства оператора Clustered Index Scan (F4) 
-- Приблизительное кол-во строк = 24.3312 
SELECT * FROM Person.Person 
WHERE LastName = N'Alonso'
AND MiddleName = N'A';
GO

-- 9.1. AUTO_CREATE_STATISTICS создал новый объект статистики (на MiddleName)
-- в Object Explorer найти эту статистику (_WA_Sys_000..), просмотреть свойства
SELECT * FROM sys.stats 
WHERE object_id = OBJECT_ID('Person.Person') 
ORDER BY stats_id;
GO

-- * Время последнего обновления всех статистик для Таблицы
SELECT name AS stats_name,   
    STATS_DATE(object_id, stats_id) AS statistics_update_date  
FROM sys.stats   
WHERE object_id = OBJECT_ID('Person.Person');  
GO  


-- 9.2. Изучение новой статистики _WA_Sys_000..
-- 'A' - RANGE_HI_KEY = 1367.047 строк
DBCC SHOW_STATISTICS('Person.Person','_WA_Sys_00000006_7C4F7684') WITH HISTOGRAM;

-- 9.3. Кардинальность для запроса
-- Приблизительное кол-во строк WHERE LastName = 'Alonso' -> 93
-- Общее количество строк в таблице -> 19972
-- Приблизительное кол-во строк WHERE MiddleName = 'A' -> 1367,047
-- С Sql Server 2014: Estimate = C * S1 * SQRT(S2) * SQRT(SQRT(S3)) * SQRT(SQRT(SQRT(S4))) …
SELECT  93.0/19972  --selectivity of LastName = Alonso
* SQRT(1367.047/19972) -- square root of selectivity of MiddleName = 'A'
* 19972 -- table cardinality
AS estimated_cardinality;


-- * 10 Добавление еще одного предиката EmailPromotion
-- Приблизительное количество строк = 3815,15
SELECT * FROM Person.Person 
WHERE LastName = N'Alonso' OR EmailPromotion = 2;
GO

-- Новая статистика
-- EmailPromotion = 1 -> EQ_ROWS = 5096,812
DBCC SHOW_STATISTICS('Person.Person','_WA_Sys_00000009_7C4F7684') WITH HISTOGRAM;

-- Estimate = C * S1 * SQRT(S2) * SQRT(SQRT(S3)) * SQRT(SQRT(SQRT(S4))) … exponential backoff
-- S1 наиболее селективный, Sn - наименее
-- OR переводится в AND
-- (A or B) = not ((not A) and (not B)) 
SELECT 19972 *  (1 -  (1 - 93.0/19972) * (SQRT(1-3777.4/19972)))
AS estimated_cardinality;

-- 11. Ручное создание статистики
-- статистика с фильтром
-- Компонент Database Engine просматривает 50% данных, а затем выбирает все строки с EmailPromotion = 2
CREATE STATISTICS ContactPromotion1  
    ON Person.Person (BusinessEntityID, LastName, EmailPromotion)  
WHERE EmailPromotion = 2  
WITH SAMPLE 50 PERCENT;  
GO  

DBCC SHOW_STATISTICS('Person.Person','ContactPromotion1');


-- 12. AUTO UPDATE
-- ASYNC (отключено у БД по умолчанию)
SELECT is_auto_update_stats_on, is_auto_update_stats_async_on from sys.databases

ALTER DATABASE AdventureWorks SET AUTO_UPDATE_STATISTICS_ASYNC ON;
ALTER DATABASE AdventureWorks SET AUTO_UPDATE_STATISTICS_ASYNC OFF;

-- 13. Обновление всей статистики БД
EXEC sp_updatestats; 

-- 14. Обновление статистики для таблицы и индекса
UPDATE STATISTICS Sales.SalesOrderDetail;  --таблица
UPDATE STATISTICS Sales.SalesOrderDetail AK_SalesOrderDetail_rowguid;  --индекс

-- обновление статистики CustomerStats1 на основе проверки всех строк в таблице Customer.
UPDATE STATISTICS Sales.Customer ([AK_Customer_AccountNumber]) WITH FULLSCAN;  