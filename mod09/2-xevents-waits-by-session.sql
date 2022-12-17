-- 1. Создать Сессию с помощью SSMS
-- Management -> Sessions -> Add Session...
-- New Session -> General -> "Session name" -> название Waits by Session
-- New Session -> Events -> Event library найти и добавить wait_info в Selected events list
-- Для wait_info -> Event configuration options -> Global Fields (Actions) выбрать session_id
-- Для wait_info -> Event configuration options -> Filter (Predicate) -> добавить условие sqlserver.session_id > 50.
-- New Session -> Data Storage -> добавить цель (Add) -> выбрать event_file, а также расположение файла .XEL
-- Максимальный размер файла - 5 Mb
-- OK
-- Запустить сессию Start Session


-- Сгенерированный код T-SQL Сессии
CREATE EVENT SESSION [Waits by Session] ON SERVER 
ADD EVENT sqlos.wait_info(
    ACTION(sqlserver.session_id)
    WHERE ([sqlserver].[session_id]>(50)))
ADD TARGET package0.event_file(
SET filename=N'<путь к файлу>\waitbysession.xel',max_file_size=(5))
WITH (MAX_MEMORY=4096 KB,
	EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=30 SECONDS,
	MAX_EVENT_SIZE=0 KB,
	MEMORY_PARTITION_MODE=NONE,
	TRACK_CAUSALITY=OFF,
	STARTUP_STATE=OFF)
GO

ALTER EVENT SESSION [Waits by Session] ON SERVER
	STATE=START
GO


-- 2. Запустить скрипт load_script1.sql (~60 минут)


-- 3. Агрегирование результатов из файла по session_id
WITH xeCTE
AS
(
	SELECT CAST(event_data AS xml) AS xe_xml
	FROM sys.fn_xe_file_target_read_file('<путь к файлу>\waitbysession*.xel', NULL, NULL, NULL)
)
,valueCTE
AS
(
	SELECT xe_xml.value('(event/action[@name="session_id"]/value)[1]','int') AS sessionID,
	xe_xml.value('(event/data[@name="wait_type"]/text)[1]','varchar(50)') AS wait_type,
	xe_xml.value('(event/data[@name="duration"]/value)[1]','int') AS wait_duration,
	xe_xml.value('(event/data[@name="signal_duration"]/value)[1]','int') AS wait_signal_duration
	FROM xeCTE
)
SELECT sessionID, wait_type, 
SUM(wait_duration) AS total_wait_duration, 
SUM(wait_signal_duration) AS signal_wait_duration, 
SUM(wait_duration - wait_signal_duration) AS resource_wait_duration
FROM valueCTE
WHERE wait_duration > 0
GROUP BY sessionID, wait_type
ORDER BY sessionID, wait_type;

-- 4. Остановка и удаление сессии, а также остановка нагрузки load_script1.sql
ALTER EVENT SESSION [Waits by Session] ON SERVER
	STATE=STOP
GO

DROP EVENT SESSION [Waits by Session] ON SERVER
GO

CREATE TABLE ##stopload (id int)
GO