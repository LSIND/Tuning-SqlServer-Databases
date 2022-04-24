-- 2.1

USE AdventureWorks;
GO

-- I. Текущий уровень изоляции транзакций
SELECT name, snapshot_isolation_state_desc, is_read_committed_snapshot_on 
FROM sys.databases;

-- II. Найти номер телефона для заказчика CustomerID = 19169: 725-555-0131
SELECT CustomerID,  [PhoneNumber]
FROM [Sales].[CustomerPII]
WHERE CustomerID = 19169;


-- III. Работа с разными уровнями изоляции транзакций
-- Выполнить "Запрос 1" в 2-2-concurrency.sql

-- 1. Dirty Read в READ UNCOMMITTED
-- ISOLATION LEVEL READ UNCOMMITTED - номер телефона: 999-999-9999
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
GO
SELECT CustomerID,  [PhoneNumber]
FROM [Sales].[CustomerPII]
WHERE CustomerID = 19169;
GO

-- 2. READ COMMITTED isolation с READ_COMMITTED_SNAPSHOT OFF предотвращает DIRTY READ
-- READCOMMITTEDLOCK table hint отключает версионность строк
-- Ожидание

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
GO
SELECT CustomerID,  [PhoneNumber]
FROM [Sales].[CustomerPII] WITH (READCOMMITTEDLOCK)
WHERE CustomerID = 19169
GO

-- Выполнить "Запрос 2" в 2-2-concurrency.sql
-- Предыдущий запрос вернет значение: 725-555-0131


-- 3. non-repeatable read с READ COMMITTED isolation и READ_COMMITTED_SNAPSHOT OFF

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION
SELECT CustomerID,  [PhoneNumber]
FROM [Sales].[CustomerPII] WITH (READCOMMITTEDLOCK)
WHERE CustomerID = 19169;

-- Выполнить "Запрос 3" в 2-2-concurrency.sql
-- Выполнить запрос; вернет значение: 333-333-3333

SELECT CustomerID,  [PhoneNumber]
FROM [Sales].[CustomerPII] WITH (READCOMMITTEDLOCK)
WHERE CustomerID = 19169;
COMMIT

-- 4. REPEATABLE READ isolation предотвращает non-repeatable read
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
GO
BEGIN TRANSACTION
	SELECT CustomerID, [PhoneNumber]
	FROM [Sales].[CustomerPII]
	WHERE CustomerID = 19169;

-- Выполнить "Запрос 4" в 2-2-concurrency.sql
-- "Запрос 4" ожидает
-- Выполнить запрос; вернет значение: 333-333-3333. "Запрос 4" также выполнится и изменит данные на 444-444-4444
	SELECT CustomerID,  [PhoneNumber]
	FROM [Sales].[CustomerPII]
	WHERE CustomerID = 19169;
COMMIT

-- 5. phantom read при REPEATABLE READ 
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
GO
BEGIN TRANSACTION
	SELECT COUNT(*) AS CustCount 
	FROM [Sales].[CustomerPII]
	WHERE [PhoneNumber] < '111-555-2222';

-- Выполнить "Запрос 5" в 2-2-concurrency.sql
-- Выполнить запрос. Значение количества заказчиков увеличилось на 1
	SELECT COUNT(*) AS CustCount 
	FROM [Sales].[CustomerPII]
	WHERE [PhoneNumber] < '111-555-2222';
COMMIT

-- 6. SERIALIZABLE предотвращает phantom read
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
	SELECT COUNT(*) AS CustCount 
	FROM [Sales].[CustomerPII]
	WHERE [PhoneNumber] < '111-555-2222';

-- Выполнить "Запрос 5" в 2-2-concurrency.sql. Запрос 5 ожидает
-- Выполнить запрос. Значение количества заказчиков не изменилось
	SELECT COUNT(*) AS CustCount 
	FROM [Sales].[CustomerPII]
	WHERE [PhoneNumber] < '111-555-2222';
COMMIT

-- 7. READ COMMITTED с READ_COMMITTED_SNAPSHOT ON
-- Изменить номер телефона для CustomerID = 19169
UPDATE [Sales].[CustomerPII]
SET [PhoneNumber] = N'170-555-0127' 
WHERE CustomerID = 19169;
GO

-- Выполнить "Запрос 6" в 2-2-concurrency.sql. 
-- Выполнить запрос. Запрос ожидает
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
GO
BEGIN TRANSACTION 
	SELECT CustomerID, [PhoneNumber]
	FROM [Sales].[CustomerPII]
	WHERE CustomerID = 19169;

-- Выполнить "Запрос 7" в 2-2-concurrency.sql. 
-- Выполнить запрос: 616-666-6666
	SELECT CustomerID, [PhoneNumber]
	FROM [Sales].[CustomerPII]
	WHERE CustomerID = 19169;
COMMIT

-- 8. SNAPSHOT 
UPDATE [Sales].[CustomerPII]
SET [PhoneNumber] = N'170-555-0127' 
WHERE CustomerID = 19169;
GO

-- Выполнить "Запрос 6" в 2-2-concurrency.sql. 
-- Выполнить запрос.

/*ALTER DATABASE AdventureWorks
SET ALLOW_SNAPSHOT_ISOLATION ON
GO */

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
GO
BEGIN TRANSACTION 
	SELECT CustomerID, [PhoneNumber]
	FROM [Sales].[CustomerPII]
	WHERE CustomerID = 19169;

-- Выполнить "Запрос 7" в 2-2-concurrency.sql. 
-- Выполнить запрос: значение не изменилось в рамках этой транзакции
SELECT CustomerID, [PhoneNumber]
	FROM [Sales].[CustomerPII]
	WHERE CustomerID = 19169;
COMMIT

-- 9. Конфликт при обновлении с SNAPSHOT:
UPDATE [Sales].[CustomerPII]
SET [PhoneNumber] = N'170-555-0127' 
WHERE CustomerID = 19169;
GO
-- Выполнить "Запрос 6" в 2-2-concurrency.sql. 
-- Выполнить запрос. Ожидание
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
GO
BEGIN TRANSACTION 
	UPDATE [Sales].[CustomerPII]
	SET [PhoneNumber] = N'777-555-7777'
	WHERE CustomerID = 19169;

-- Выполнить "Запрос 7" в 2-2-concurrency.sql. 
-- Ошибка: откат транзакции

-- Убедиться, что нет открытых транзакций
SELECT @@TRANCOUNT;