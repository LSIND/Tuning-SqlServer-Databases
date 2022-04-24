-- 1. Создание сессии [SqlStatementCompleted] для сбора выполненных SQL-запросов. ON SERVER
-- выполняется под учетной записью A\A

CREATE EVENT SESSION SqlStatementCompleted ON SERVER
ADD EVENT sqlserver.sql_statement_completed (
	ACTION (sqlserver.sql_text,sqlserver.session_id)
	WHERE server_principal_name = 'Education\dvchemkaeva'
)
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,
	EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=30 SECONDS,
	MAX_EVENT_SIZE=0 KB,
	MEMORY_PARTITION_MODE=NONE,
	TRACK_CAUSALITY=OFF,
	STARTUP_STATE=OFF);
GO

-- 2. Сессия серверная в sys.server_event_sessions
SELECT * FROM sys.server_event_sessions WHERE name = 'SqlStatementCompleted';
SELECT * FROM sys.dm_xe_sessions WHERE name = 'SqlStatementCompleted';

-- 3. Запуск сессии 
ALTER EVENT SESSION SqlStatementCompleted ON SERVER
	STATE=START
GO

-- 4. Выполнение запросов
SELECT 'sample extended events 1' AS v1;
GO
SELECT 'sample extended events 2' AS v2;
GO

-- 5. Просмотр собранных данных: XML-формат
SELECT CAST(target_data AS XML) AS xe_data
FROM sys.dm_xe_session_targets AS st
JOIN sys.dm_xe_sessions AS  s 
ON st.event_session_address = s.address
WHERE s.name = 'SqlStatementCompleted';

-- 6. Запрос к собранным данным в формате XML из п.5 
-- Информация о конкретном событии, запрос, длительность, дата начала
SELECT TOP (10) xa.xe_xml.query('.') AS xe_event,
xa.xe_xml.value('(./data[@name="statement"]/value)[1]', 'nvarchar(MAX)') AS sql_statement,
xa.xe_xml.value('(./data[@name="duration"]/value)[1]', 'bigint') AS duration_ms,
xa.xe_xml.value('(./@timestamp[1])', 'nvarchar(100)') AS time_start
FROM	(	SELECT CAST(target_data AS XML) AS xe_data
			FROM sys.dm_xe_session_targets AS st
			JOIN sys.dm_xe_sessions AS  s 
			ON st.event_session_address = s.address
			WHERE s.name = 'SqlStatementCompleted'
		) AS xe
CROSS APPLY xe_data.nodes('//event') xa (xe_xml);

-- 7. SSMS: Object Explorer -> Management -> Extended Events -> Sessions ->  SqlStatementCompleted 
-- Выбрать package0.ring_buffer: XML из п.5


-- 8. Live activity
-- SqlStatementCompleted -> Watch Live Data.

-- 9. Выполнить новые запросы - появятся в окне Live Data
SELECT 'sample extended events 3' AS v1;
GO
SELECT 'sample extended events 4' AS v2;
GO

-- 10. Остановить сессию
ALTER EVENT SESSION SqlStatementCompleted ON SERVER
	STATE=STOP
GO

-- 11. Свойства сессии
-- SqlStatementCompleted -> Properties.

-- 12. Удалить сессию
DROP EVENT SESSION SqlStatementCompleted ON SERVER