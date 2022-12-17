
-- Сессия с гистогоаммой


CREATE EVENT SESSION XECollectWaitStats ON SERVER 
ADD EVENT sqlos.wait_info(
    ACTION(sqlserver.database_id))
	ADD TARGET package0.histogram(SET slots = 64, filtering_event_name=N'sqlos.wait_info', source=N'wait_type',source_type=(0))
GO

-- Запуск сессии
ALTER EVENT SESSION XECollectWaitStats ON SERVER
	STATE=START
GO


-- Данные всех сессий
SELECT name, target_name, CAST(xet.target_data AS xml) as XML_data
FROM sys.dm_xe_session_targets AS xet  
JOIN sys.dm_xe_sessions AS xe
ON (xe.address = xet.event_session_address)


-- Данные сессии (гистограмма)
SELECT 
xed.XML_data.value('(value)[1]', 'varchar(256)') AS wait_type,
xed.XML_data.value('(@count)[1]', 'varchar(256)') AS wait_count
FROM (
SELECT CAST(xet.target_data AS xml) as XML_data
FROM sys.dm_xe_session_targets AS xet  
JOIN sys.dm_xe_sessions AS xe
ON (xe.address = xet.event_session_address)
WHERE xe.name = 'XECollectWaitStats' -- Сессия
AND target_name= 'histogram' -- target 
    ) as t
CROSS APPLY t.XML_data.nodes('//HistogramTarget/Slot') AS xed (XML_data)


-- Типы ожиданий из map
SELECT * FROM sys.dm_xe_map_values as mv
WHERE mv.name='wait_types';


-- Типы ожиданий и их количество
SELECT 
xm.wait_count
,xm.wait_type
,mv.map_value 
FROM (
	SELECT 
	xed.XML_data.value('(value)[1]', 'varchar(256)') AS wait_type,
	xed.XML_data.value('(@count)[1]', 'varchar(256)') AS wait_count
	FROM (
	SELECT CAST(xet.target_data AS xml) as XML_data
	FROM sys.dm_xe_session_targets AS xet  
	JOIN sys.dm_xe_sessions AS xe
	ON (xe.address = xet.event_session_address)
	WHERE xe.name = 'XECollectWaitStats' -- Сессия
	AND target_name= 'histogram' -- target 
		) as t
	CROSS APPLY t.XML_data.nodes('//HistogramTarget/Slot') AS xed (XML_data)) xm
JOIN sys.dm_xe_map_values as mv
ON xm.wait_type = mv.map_key
WHERE mv.name='wait_types'


-- остановка сессии
ALTER EVENT SESSION XECollectWaitStats ON SERVER
	STATE=STOP
GO