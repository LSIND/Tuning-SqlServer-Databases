USE AdventureWorks;
GO

/*ALTER DATABASE AdventureWorks
SET ALLOW_SNAPSHOT_ISOLATION OFF
GO 

ALTER DATABASE AdventureWorks
SET READ_COMMITTED_SNAPSHOT OFF; */

--I.  Сведения об активных в данный момент в SQL Server ресурсах диспетчера блокировок
SELECT * 
FROM sys.dm_tran_locks;

-- 1. Текущий уровень изоляции транзакций для БД
SELECT d.snapshot_isolation_state, d.is_read_committed_snapshot_on,
CASE transaction_isolation_level 
	WHEN 0 THEN 'UNSPECIFIED' 
	WHEN 1 THEN 'READ UNCOMMITTED' 
	WHEN 2 THEN 'READ COMMITTED' 
	WHEN 3 THEN 'REPEATABLE READ' 
	WHEN 4 THEN 'SERIALIZABLE' 
	WHEN 5 THEN 'SNAPSHOT'  
END AS transaction_isolation_level 
FROM sys.dm_exec_sessions AS es
join sys.databases  AS d
ON d.database_id = es.database_id
WHERE es.session_id = @@SPID;

-- 2. Блокировки SELECT-запроса при уровне READ UNCOMMITTED
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRANSACTION
	SELECT TOP (100) * FROM AdventureWorks.Person.Person;

-- 3. Виды блокировок данной транзакции: DATABASE (S) и METADATA (Sch-S)
	SELECT resource_type, request_mode,COUNT(*) AS lock_count
	FROM sys.dm_tran_locks 
	WHERE request_session_id = @@SPID 
	GROUP BY resource_type,request_mode;

ROLLBACK

-- II. HINTS, влияющие на уровень изоляции

-- 1. Блокировка SELECT-запроса при уровне REPEATABLE READ
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRANSACTION
	SELECT TOP (100) * FROM AdventureWorks.Person.Person;

-- 2. Виды блокировок данной транзакции: DATABASE = 1, PAGE (IS) = 8, OBJECT (IS) = 1, KEY = 100, METADATA = 3
	SELECT resource_type, request_mode,COUNT(*) AS lock_count
	FROM sys.dm_tran_locks 
	WHERE request_session_id = @@SPID 
	GROUP BY resource_type,request_mode;

ROLLBACK

-- 3. Блокировка SELECT-запроса при уровне REPEATABLE READ, но с  READCOMMITTED locking hint
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRANSACTION
	SELECT TOP (100) * FROM AdventureWorks.Person.Person
	WITH (READCOMMITTED);

-- 4. Виды блокировок данной транзакции: DATABASE = 1, METADATA = 3; как в случае I.2-3.
	SELECT resource_type, request_mode,COUNT(*) AS lock_count
	FROM sys.dm_tran_locks 
	WHERE request_session_id = @@SPID 
	GROUP BY resource_type,request_mode;

ROLLBACK

-- III. HINTS, влияющие на уровень блокировки

-- 1. Блокировка SELECT-запроса при уровне READ COMMITTED, но с TABLOCKX locking hint
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION
	SELECT TOP (100) * FROM AdventureWorks.Person.Person 
	WITH (TABLOCKX);

-- 2. Виды блокировок данной транзакции: DATABASE = 1, METADATA = 2, OBJECT (X) = 1
	SELECT resource_type, request_mode,COUNT(*) AS lock_count
	FROM sys.dm_tran_locks 
	WHERE request_session_id = @@SPID 
	GROUP BY resource_type,request_mode;

ROLLBACK

-- 3. Блокировка SELECT-запроса при уровне REPEATABLE READ, но с TABLOCKX
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRANSACTION
	SELECT TOP (100) * FROM AdventureWorks.Person.Person 
	WITH (TABLOCKX);

-- 4. Виды блокировок данной транзакции: DATABASE = 1, METADATA = 2, TABLE (X) = 1
	SELECT resource_type, request_mode,COUNT(*) AS lock_count
	FROM sys.dm_tran_locks 
	WHERE request_session_id = @@SPID 
	GROUP BY resource_type,request_mode;

ROLLBACK

-- 5. READPAST HINT
-- 5.1. Выполните "Запрос 1" в 3-2-locks.sql

-- 5.2. Выполните запрос без Hint. Ожидадание
SELECT * 
FROM Sales.SalesTerritory;

-- 5.3. READPAST
-- 9 строк возвращено. TerritoryID = 3 не включена в результирующий набор
SELECT * 
FROM Sales.SalesTerritory 
WITH (READPAST);

-- 5.4. Выполните "Запрос 2" в 3-2-locks.sql - откат транзакции