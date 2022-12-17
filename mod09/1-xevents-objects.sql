
-- 1. Packages
SELECT * FROM sys.dm_xe_packages;

-- 2. Events
SELECT * FROM sys.dm_xe_objects
WHERE object_type = 'event';

-- 3. Ключевые слова Keyword

SELECT map_value AS keyword
FROM sys.dm_xe_map_values
WHERE name = 'keyword_map'
ORDER BY keyword;

-- 4. События и их пакеты
SELECT xp.name AS package_name,
xo.name AS event_name,
xo.[description] AS event_description
FROM sys.dm_xe_objects AS xo
JOIN sys.dm_xe_packages AS xp
ON xp.guid = xo.package_guid
WHERE object_type = 'event'
ORDER BY package_name, event_name;

-- 5. Атрибуты событий sys.dm_xe_objects
SELECT xoc.* FROM sys.dm_xe_objects AS xo
JOIN sys.dm_xe_object_columns AS xoc
ON xoc.object_package_guid = xo.package_guid AND xoc.object_name = xo.name
WHERE xo.object_type = 'event';

-- 6. Предикаты
SELECT * FROM sys.dm_xe_objects
WHERE object_type LIKE 'pred%'
ORDER BY object_type, name;

-- 7. Действия
SELECT * FROM sys.dm_xe_objects
WHERE object_type = 'action';

-- 8. Цели
SELECT * FROM sys.dm_xe_objects
WHERE object_type = 'target';

-- 9. Типы
SELECT * FROM sys.dm_xe_objects
WHERE object_type = 'type';

-- 10. Maps
SELECT * FROM sys.dm_xe_map_values
ORDER BY name, map_key;

select map_key, map_value from sys.dm_xe_map_values  
where name = 'lock_mode'  

-- 11. Сессии
SELECT * FROM sys.dm_xe_sessions;

-- Серверные
SELECT * FROM sys.server_event_sessions;


-- События из system_health по количеству

 WITH CTE_EventXML AS 
(  SELECT ed = CAST(event_data AS XML)   
 FROM sys.fn_xe_file_target_read_file(N'system_health*.xel', NULL, NULL, NULL)
 ) 
 SELECT -- TOP(3)
    EventName,  EventCount = COUNT(*)
  FROM (  
  SELECT  ed.value(N'(event/@timestamp)[1]', N'datetime'),  
    ed.value(N'(event/@name)[1]',      N'nvarchar(255)')  
   FROM CTE_EventXML  
   WHERE ed.value(N'(event/@timestamp)[1]', N'datetime') > '20221208') AS t(EventTime, EventName)
  GROUP BY EventName
  ORDER BY EventCount DESC;