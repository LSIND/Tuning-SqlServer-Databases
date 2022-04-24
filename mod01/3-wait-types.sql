-- 1. Откройте скрипт 2-1-hanging-tran.sql и выполните инструкции. Получите update_session_id
-- 2. Откройте скрипт 2-2-blocked-tran.sql и выполните инструкции. Получите select_session_id

-- 3. Сведения об очереди задач, ожидающих освобождения ресурса. 
-- Задача с select_session_id имеет тип ожидания LCK_M_S
SELECT * FROM sys.dm_os_waiting_tasks 
WHERE session_id > 50;

-- 4. Сведения обо всех ожиданиях, которые выполнялись для каждой сессии
-- Подставьте select_session_id в условие WHERE 
-- Сессия select_session_id имеет тип ожидания MEMORY_ALLOCATION_EXT
SELECT * FROM sys.dm_exec_session_wait_stats 
WHERE session_id = <select_session_id>;

-- 5. В скрипте 2-1-hanging-tran.sql выполните команду ROLLBACK; 

-- 6. Подставьте select_session_id в условие WHERE 
-- Сессия select_session_id имеет тип ожидания LCK_M_S
SELECT * FROM sys.dm_exec_session_wait_stats 
WHERE session_id = <select_session_id>;

-- ==============================================

-- 7. Ожидания PAGELATCH и WRITELOG
-- Создать таблицу insertTargetEx

USE AdventureWorks;
GO

IF (Object_Id('dbo.insertTargetEx') IS NOT NULL)
	TRUNCATE TABLE dbo.insertTargetEx;
ELSE
CREATE TABLE dbo.insertTargetEx
(
TableId int PRIMARY KEY IDENTITY(1,1),
date1 datetime2
)
GO

-- Очистить статистику ожиданий командой DBCC
DBCC SQLPERF('sys.dm_os_wait_stats',clear);

-- 8. Определить значения ожиданий PAGELATCH и WRITELOG
SELECT * FROM sys.dm_os_wait_stats 
WHERE wait_type = 'WRITELOG'
UNION ALL
SELECT * FROM sys.dm_os_wait_stats 
WHERE wait_type like 'PAGELATCH%';

-- 9. Откройте "Resource Monitor" -> вкладка Disk -> диаграмма Disk Queue Length ~ 0

-- 10. Откройте Powershell от имени администратора, перейдите в папку ..Tuning-SqlServer-Databases\mod01
-- Выполните скрипт .\start-load.ps1 workload2.sql
-- Скрипт ps запустит 10 фоновых работ (job), выполняющих один и тот же скрипт workload2.sql
-- Просмотрите изменения диаграммы Disk Queue

-- 11. Значения ожиданий PAGELATCH и WRITELOG сильно выросли

SELECT * FROM sys.dm_os_wait_stats WHERE wait_type = 'WRITELOG'
UNION ALL
SELECT * FROM sys.dm_os_wait_stats WHERE wait_type like 'PAGELATCH%';

-- 12. Удалить таблицу dbo.insertTargetEx;
DROP TABLE IF EXISTS dbo.insertTargetEx;