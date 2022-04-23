-- 1. Откройте скрипт 2-1-hanging-tran.sql и выполните инструкции. Получите update_session_id
-- 2. Откройте скрипт 2-2-blocked-tran.sql и выполните инструкции. Получите select_session_id

-- 3. Добавьте значения update_session_id и select_session_id из предыдущих запросов во временную таблицу #

DROP TABLE IF EXISTS #session;
CREATE TABLE #session (session_id int NOT NULL);

INSERT #session
--VALUES (75),(77);
VALUES (<update_session_id>),(<select_session_id>);


-- 4. Просмотр состояния сессии. Сессия update - состояние sleeping; Сессия select - состояние running 
SELECT status, * 
FROM sys.dm_exec_sessions 
WHERE session_id IN (SELECT session_id FROM #session);

-- 5. Просмотр состояния запроса. Сессия update не имеет запроса; Сессия select - suspended (ждет освобождения ресурса)
SELECT status, * 
FROM sys.dm_exec_requests  
WHERE session_id IN (SELECT session_id FROM #session);

-- 6. Просмотр статуса задач. Сессия update не имеет задачи; Сессия select - suspended (ждет освобождения ресурса)
SELECT * 
FROM sys.dm_os_tasks
WHERE session_id IN (SELECT session_id FROM #session);

-- 7. Просмотр состояния worker. Сессия update не имеет worker; Сессия select - suspended (ждет освобождения ресурса)
SELECT dot.session_id, dow.state, dow.*
FROM sys.dm_os_workers AS dow
JOIN sys.dm_os_tasks AS dot
ON   dot.task_address = dow.task_address
WHERE dot.session_id IN (SELECT session_id FROM #session);

-- 8. Просмотр времени ожидания / готовность к запуску
SELECT	dot.session_id, dow.state,
		CASE WHEN dow.state = 'SUSPENDED' 
			 THEN (SELECT ms_ticks FROM sys.dm_os_sys_info) - dow.wait_started_ms_ticks
			 ELSE NULL
		END AS time_spent_waiting_ms,
		CASE WHEN dow.state = 'RUNNABLE' 
			 THEN (SELECT ms_ticks FROM sys.dm_os_sys_info) - dow.wait_resumed_ms_ticks
			 ELSE NULL
		END AS time_spent_runnable_ms
FROM sys.dm_os_workers AS dow
JOIN sys.dm_os_tasks AS dot
ON   dot.task_address = dow.task_address
WHERE dot.session_id IN (SELECT session_id FROM #session);

-- 9. Просмотр состояния потока. Сессия update не имеет потока; Сессия select - suspended (ждет освобождения ресурса)
SELECT dot.session_id,  dth.*
FROM sys.dm_os_threads dth
JOIN sys.dm_os_workers AS dow
ON	 dow.worker_address = dth.worker_address
JOIN sys.dm_os_tasks AS dot
ON   dot.task_address = dow.task_address
WHERE dot.session_id IN (SELECT session_id FROM #session);

-- 10. В скрипте 2-1-hanging-tran.sql выполните команду ROLLBACK;

-- 11. Вернитесь к окну скрипта 2-2-blocked-tran.sql. Убедитесь, что запрос select вернул результаты.

-- 12. Просмотр состояния сессий. Sleeping
SELECT status, * 
FROM sys.dm_exec_sessions 
WHERE session_id IN (SELECT session_id FROM #session);

-- 13. Удалить временную таблицу
DROP TABLE IF EXISTS #session