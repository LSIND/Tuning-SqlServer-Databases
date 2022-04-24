-- 1. Включение Query Store с опциями
USE master;
GO
ALTER DATABASE AdventureWorks
SET QUERY_STORE = ON;

-- 2. Изменение опций Query Store
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

-- 3. Просмотр опций Query Store
USE AdventureWorks;
GO
SELECT * FROM sys.database_query_store_options;

-- 5. Отключение
USE master;
GO
ALTER DATABASE AdventureWorks
SET QUERY_STORE = OFF;
GO


-- 5. Включение Query Store для БД TSQL
USE master;
GO

ALTER DATABASE [TSQL] SET QUERY_STORE = ON;

-- 5.1 Очистка данных Query Store
ALTER DATABASE [TSQL] SET QUERY_STORE CLEAR;

-- 5.2 Изменение опций (минимальные интервалы)
-- INTERVAL_LENGTH_MINUTES = Интервал агрегирования статистики в минутах (1, 5, 10, 15, 30, 60 или 1440). По умолчанию — 60 минут.
-- DATA_FLUSH_INTERVAL_SECONDS = Период регулярного сброса данных хранилища запросов на диск в секундах. По умолчанию - 900 секунд (15 мин.)
ALTER DATABASE [TSQL] SET QUERY_STORE (INTERVAL_LENGTH_MINUTES = 1, DATA_FLUSH_INTERVAL_SECONDS = 60)

-- 5.3. Запустить нагрузку load_script1.sql (время выполнения ~ 60 минут)

-- 5.4 В Object Explorer -> Свойства БД TSQL -> Query Store -> Operation Mode = Read Write

-- 5.5 Увеличить размер хранилища Query Store 
ALTER DATABASE [TSQL]
SET QUERY_STORE (MAX_STORAGE_SIZE_MB = 150);

-- 5.6 Отчет Overall Resource Consumption
-- Configure -> Time Interval = Last Hour, agg in Minutes
-- query id (x-axis графика)

-- 5.7 Отчет Tracked Queries
-- В поиск ввести query id из п.5.6. -> История планов для запроса


-- 6. Доп нагрузка: создать временную таблицу ##wideplan
CREATE TABLE ##wideplan (id INT);

-- 6.1 В два раза увеличить количество строк в Sales.Orders 
-- Произойдет обновление статистики и будет создан новый план запроса
INSERT INTO TSQL.Sales.Orders (custid,empid,orderdate,requireddate,shippeddate,shipperid,freight,shipname,shipaddress,shipcity,shipregion,shippostalcode,shipcountry)
SELECT custid,empid,orderdate,requireddate,shippeddate,shipperid,freight,shipname,shipaddress,shipcity,shipregion,shippostalcode,shipcountry
FROM TSQL.Sales.Orders

-- 6.2 Обновить отчет Tracked Queries: скомпилирован новый план

-- 6.3 Отчет Regressed Queries
-- Configure -> Time Interval = Last 5 minutes: ALL

-- 6.4 Отчет Tracked Queries 
-- Выбрать план запроса (точка) и нажать Force Plan.

-- 6.5 Обновить отчет Top Resource Consumers - планы были форсированы V

-- 6.6 Отчет Tracked Queries -> Unforce

-- 6.7 Остановить нагрузку
CREATE TABLE ##stopload (id int)