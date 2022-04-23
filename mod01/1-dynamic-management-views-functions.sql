-- 1. Dynamic Management Views � Functions

-- �������� Powershell �� ����� ��������������, ��������� � ����� ..Tuning-SqlServer-Databases\mod01
-- ��������� ������ .\start-load.ps1 workload1.sql
-- ������ ps �������� 10 ������� ����� (job), ����������� ���� � ��� �� ������ workload1.sql

-- 1.1. dm_exec_*
-- �������� � ������ �������, ������� ����������� � SQL Server 
-- running, runnable ��� suspended
SELECT * FROM sys.dm_exec_requests
WHERE session_id > 50; --��������� ��������� ������;  
GO 

-- ����� SQL batch, ����������������� ��������� sql_handle. 
SELECT t.text, r.session_id, r.start_time, r.status
FROM sys.dm_exec_requests AS r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
WHERE session_id = @@SPID -- ��������� SPID

-- �������� ��� ���� �������� ������������ ������������� � ���������� �������
-- ������� SQLCMD �� ������� ��������
SELECT * FROM sys.dm_exec_sessions 

WHERE session_id > 50
ORDER BY session_id DESC


-- 1.2. dm_os_*
-- ���� ������ ��� ������ �������� ������ � ���������� SQL Server
-- task_state = RUNNING, SUSPENDED ��� RUNNABLE.
SELECT * from sys.dm_os_tasks
WHERE session_id > 50; --��������� ��������� ������;  

-- ���� ������ ��� ������� ������������ SQL Server, ��������������� � ��������� �����������
-- current_tasks_count � runnable_tasks_count columns = ����� ���������� ����� 
-- ������� ���������� runnable ����� � ������ ���������� ������� - �������� �� ��
SELECT * FROM sys.dm_os_schedulers;

-- ���������� ����������
SELECT * 
FROM sys.dm_exec_sessions AS ses
JOIN sys.dm_exec_requests AS req
ON   req.session_id = ses.session_id
JOIN sys.dm_os_tasks AS tsk
ON   tsk.session_id = ses.session_id
JOIN sys.dm_os_schedulers AS sch
ON	 sch.scheduler_id = tsk.scheduler_id
WHERE ses.session_id > 50;

-- �������� � ����������, � ����� � ��������, ��������� ��� ����� SQL Server � ������������ ���.
SELECT * FROM sys.dm_os_sys_info;

-- ������� ������������� ��� �� XML-������� [record] ������������� sys.dm_os_ring_buffers
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
-- ������ � ����������� ��� ���������� SQL Server.
SELECT * FROM sys.dm_tran_active_transactions;

-- SQL SERVER 2019. �������� � �������������, ���������� ����������� � ���������� SQL Server.
SELECT * FROM sys.dm_tran_aborted_transactions;


-- 1.4. dm_io_*
-- C��������� �����-������ ��� ������ � ������ �������.
SELECT * FROM sys.dm_io_virtual_file_stats(DB_ID(N'AdventureWorks'), NULL);  

-- C��������� ��� ����� ������� � ���� ������ AdventureWorks
SELECT * FROM sys.dm_io_virtual_file_stats(DB_ID(N'AdventureWorks'), 2);


-- 1.5. dm_db_*
-- C������� � ������ ������� ����������
SELECT s.name AS 'Database Name', ls.log_backup_time AS [last log backup time], ls.total_log_size_mb
FROM sys.databases AS s
CROSS APPLY sys.dm_db_log_stats(s.database_id) AS ls; 