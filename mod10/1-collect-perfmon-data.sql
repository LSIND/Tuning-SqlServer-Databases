-- 1. Создать БД baseline: SIZE = 8192KB, FILEGROWTH = 2048KB; Log - SIZE = 2048KB, FILEGROWTH = 512KB

-- 2. Создать работу CollectPerfMonData job SQL Server Agent

USE [msdb]
GO

IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = 'CollectPerfMonData')
	EXEC msdb.dbo.sp_delete_job @job_name=N'CollectPerfMonData', @delete_unused_schedule=1
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'CollectPerfMonData', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [collect_1]    Script Date: 2/25/2015 11:37:14 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'collect_1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [Baseline];
		
GO

SET NOCOUNT ON;

IF (OBJECT_ID(''PerfCounters'') IS NULL)

CREATE TABLE PerfCounters (
	[collectionId] INT,
	[Counter] NVARCHAR(770),
	[CounterType] INT,
	[Value] DECIMAL(38,2),
	[logTime] DATETIME	
	);


DECLARE @collectionId INT

IF ((SELECT COUNT(1) FROM PerfCounters) = 0)
	SET @collectionId = 1
ELSE
	SELECT @collectionId = MAX([collectionId]) + 1 FROM PerfCounters

INSERT INTO PerfCounters (
	[collectionId],
	[Counter], 
	[CounterType], 
	[Value], 
	[logTime]
	)
SELECT 
	@collectionId,
	RTRIM([object_name]) + N'':'' + RTRIM([counter_name]) + N'':'' + RTRIM([instance_name]), 
	[cntr_type],
	[cntr_value], 
	GETDATE()
FROM sys.dm_os_performance_counters
WHERE [counter_name] IN (
	''Page life expectancy'', ''Lazy writes/sec'', ''Page reads/sec'', ''Page writes/sec'',''Free Pages'',
	''Free list stalls/sec'',''User Connections'', ''Lock Waits/sec'', ''Number of Deadlocks/sec'',
	''Transactions/sec'', ''Forwarded Records/sec'', ''Index Searches/sec'', ''Full Scans/sec'',
	''Batch Requests/sec'',''SQL Compilations/sec'', ''SQL Re-Compilations/sec'', ''Total Server Memory (KB)'',
	''Target Server Memory (KB)'', ''Latch Waits/sec'', ''CPU usage %'', ''CPU usage % base''
	)
ORDER BY [object_name] + N'':'' + [counter_name] + N'':'' + [instance_name];
', 
		@database_name=N'baseline', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every_10_sec', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130404, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'1f545fc1-8d91-436d-8494-1992f7385ce0'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

-- 3. Запустить рабочую нагрузку 

-- 4. Анализ запросов

-- Step 1 - CPU usage trend
select CPUCount.[Counter], CPUCount.[logTime],
CASE WHEN CPUBase.[Value] = 0
THEN 0
ELSE (CAST(CPUCount.[Value] AS FLOAT) / CPUBase.[Value]) * 100
END AS cntr_Value
from
(select * from baseline.dbo.PerfCounters
where [Counter] = 'SQLServer:Resource Pool Stats:CPU usage %:default') CPUCount
inner join
(select * from baseline.dbo.PerfCounters
where [Counter] = 'SQLServer:Resource Pool Stats:CPU usage % base:default') CPUBase
on CPUCount.[collectionId] = CPUBase.[collectionId]
ORDER BY CPUCount.[logTime]


-- Step 2 - Memory usage trend
SELECT [logTime], [Counter], [Value]/1024 as MemoryUsageMB FROM baseline.dbo.PerfCounters 
WHERE [Counter] = 'SQLServer:Memory Manager:Total Server Memory (KB):'
ORDER BY [logTime]


-- Step 3 - Transaction throughput
SELECT [logTime], [Counter], [Value] FROM baseline.dbo.PerfCounters
WHERE [Counter] = 'SQLServer:Databases:Transactions/sec:AdventureWorks'
ORDER BY [logTime]


-- Step 4 - Transaction reads per second
SELECT [logTime], [Counter], [Value] FROM baseline.dbo.PerfCounters
WHERE [Counter] like '%Page reads/sec%'
ORDER BY [logTime];


-- 5. Удалить работу и базу baseline
USE [msdb]
GO

EXEC msdb.dbo.sp_delete_job @job_name=N'CollectPerfMonData', @delete_unused_schedule=1
GO

USE master
GO

IF (DB_ID('baseline') IS NOT NULL)
BEGIN
	ALTER DATABASE baseline SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE baseline
END
GO