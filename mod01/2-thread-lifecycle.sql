-- 1. �������� ������ 2-1-hanging-tran.sql � ��������� ����������. �������� update_session_id
-- 2. �������� ������ 2-2-blocked-tran.sql � ��������� ����������. �������� select_session_id

-- 3. �������� �������� update_session_id � select_session_id �� ���������� �������� �� ��������� ������� #

DROP TABLE IF EXISTS #session;
CREATE TABLE #session (session_id int NOT NULL);

INSERT #session
--VALUES (75),(77);
VALUES (<update_session_id>),(<select_session_id>);


-- 4. �������� ��������� ������. ������ update - ��������� sleeping; ������ select - ��������� running 
SELECT status, * 
FROM sys.dm_exec_sessions 
WHERE session_id IN (SELECT session_id FROM #session);

-- 5. �������� ��������� �������. ������ update �� ����� �������; ������ select - suspended (���� ������������ �������)
SELECT status, * 
FROM sys.dm_exec_requests  
WHERE session_id IN (SELECT session_id FROM #session);

-- 6. �������� ������� �����. ������ update �� ����� ������; ������ select - suspended (���� ������������ �������)
SELECT * 
FROM sys.dm_os_tasks
WHERE session_id IN (SELECT session_id FROM #session);

-- 7. �������� ��������� worker. ������ update �� ����� worker; ������ select - suspended (���� ������������ �������)
SELECT dot.session_id, dow.state, dow.*
FROM sys.dm_os_workers AS dow
JOIN sys.dm_os_tasks AS dot
ON   dot.task_address = dow.task_address
WHERE dot.session_id IN (SELECT session_id FROM #session);

-- 8. �������� ������� �������� / ���������� � �������
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

-- 9. �������� ��������� ������. ������ update �� ����� ������; ������ select - suspended (���� ������������ �������)
SELECT dot.session_id,  dth.*
FROM sys.dm_os_threads dth
JOIN sys.dm_os_workers AS dow
ON	 dow.worker_address = dth.worker_address
JOIN sys.dm_os_tasks AS dot
ON   dot.task_address = dow.task_address
WHERE dot.session_id IN (SELECT session_id FROM #session);

-- 10. � ������� 2-1-hanging-tran.sql ��������� ������� ROLLBACK;

-- 11. ��������� � ���� ������� 2-2-blocked-tran.sql. ���������, ��� ������ select ������ ����������.

-- 12. �������� ��������� ������. Sleeping
SELECT status, * 
FROM sys.dm_exec_sessions 
WHERE session_id IN (SELECT session_id FROM #session);

-- 13. ������� ��������� �������
DROP TABLE IF EXISTS #session