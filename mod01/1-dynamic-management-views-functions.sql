-- 1. Dynamic Management Views и Functions

-- Откройте Powershell от имени администратора, перейдите в папку ..Tuning-SqlServer-Databases\mod01
-- Выполните скрипт .\start-load.ps1 workload1.sql
-- Скрипт ps запустит 10 фоновых работ (job), выполняющих один и тот же скрипт workload1.sql

-- 1.1. dm_exec_*
-- Сведения о каждом запросе, который выполняется в SQL Server 
-- running, runnable или suspended
SELECT * FROM sys.dm_exec_requests
WHERE session_id > 50; --исключить системные сессии;  
GO 

-- Текст SQL batch, идентифицируемого указанным sql_handle. 
SELECT t.text, r.session_id, r.start_time, r.status
FROM sys.dm_exec_requests AS r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
WHERE session_id = @@SPID -- Требуемый SPID

-- сведения обо всех активных подключениях пользователей и внутренних задачах
-- Найдите SQLCMD от рабочей нагрузки
SELECT * FROM sys.dm_exec_sessions 

WHERE session_id > 50
ORDER BY session_id DESC


-- 1.2. dm_os_*
-- Одна строка для каждой активной задачи в экземпляре SQL Server
-- task_state = RUNNING, SUSPENDED или RUNNABLE.
SELECT * from sys.dm_os_tasks
WHERE session_id > 50; --исключить системные сессии;  

-- Одна строка для каждого планировщика SQL Server, сопоставленного с отдельным процессором
-- current_tasks_count и runnable_tasks_count columns = общее количество задач 
-- большое количество runnable задач в долгий промежуток времени - нагрузка на ЦП
SELECT * FROM sys.dm_os_schedulers;

-- Совместная информация
SELECT * 
FROM sys.dm_exec_sessions AS ses
JOIN sys.dm_exec_requests AS req
ON   req.session_id = ses.session_id
JOIN sys.dm_os_tasks AS tsk
ON   tsk.session_id = ses.session_id
JOIN sys.dm_os_schedulers AS sch
ON	 sch.scheduler_id = tsk.scheduler_id
WHERE ses.session_id > 50;

-- Сведения о компьютере, а также о ресурсах, доступных для служб SQL Server и используемых ими.
-- os_quantum = 4 milliseconds
SELECT * FROM sys.dm_os_sys_info;

-- история использования ЦПУ из XML-столбца [record] представления sys.dm_os_ring_buffers
SELECT Notification_Time, ProcessUtilization AS SQLProcessUtilization,
SystemIdle, 100 - SystemIdle - ProcessUtilization AS OtherProcessUtilization
FROM (	SELECT	r.value('(./Record/@id)[1]', 'int') AS record_id,
				r.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS SystemIdle,
				r.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS ProcessUtilization,
				Notification_Time
		FROM (	SELECT	CONVERT(xml, record) as r,
						DATEADD(ms, (rbf.timestamp - tme.ms_ticks), 
						GETDATE()) as Notification_Time
				FROM sys.dm_os_ring_buffers AS rbf
				CROSS join sys.dm_os_sys_info AS tme
				WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
			) AS x
	) AS y
ORDER BY record_id DESC;


-- 1.3. dm_tran_*
-- Данные о транзакциях для экземпляра SQL Server.
SELECT * FROM sys.dm_tran_active_transactions;

-- SQL SERVER 2019. Сведения о неразрешенных, прерванных транзакциях в экземпляре SQL Server.
SELECT * FROM sys.dm_tran_aborted_transactions;


-- 1.4. dm_io_*
-- Cтатистика ввода-вывода для данных и файлов журнала.
SELECT * FROM sys.dm_io_virtual_file_stats(DB_ID(N'AdventureWorks'), NULL);  

-- Cтатистика для файла журнала в базе данных AdventureWorks
SELECT * FROM sys.dm_io_virtual_file_stats(DB_ID(N'AdventureWorks'), 2);


-- 1.5. dm_db_*
-- Cведения о файлах журнала транзакций
SELECT s.name AS 'Database Name', ls.log_backup_time AS [last log backup time], ls.total_log_size_mb
FROM sys.databases AS s
CROSS APPLY sys.dm_db_log_stats(s.database_id) AS ls; 