---------------------------------------------------------------------
-- LAB 05
--
-- Exercise 2
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 1. - Откройте Activity Monitor в SSMS
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 2. Очистить статистику ожиданий
---------------------------------------------------------------------
DBCC SQLPERF('sys.dm_os_wait_stats',CLEAR);

---------------------------------------------------------------------
-- 3. Начало рабочей нагрузки
-- Откройте Powershell от имени администратора, перейдите в папку ..Tuning-SqlServer-Databases\mod05\lab
-- Выполните скрипт .\start-load-ex.ps1 workload2.sql
-- Скрипт ps запустит 10 фоновых работ (job), выполняющих один и тот же скрипт workload1.sql
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 4. Просмотрите ожидания блокировок (Lock Waits) в Activity Monitor
-- значение Cumulative Wait Time (sec) для Lock wait
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 5. Включить блокировку на уровне партиций (Partition-Level) для таблицы Proseware.CampaignResponsePartitioned
-- LOCK_ESCALATION = AUTO
---------------------------------------------------------------------

USE AdventureWorks;
GO
ALTER TABLE Proseware.CampaignResponsePartitioned 
SET (LOCK_ESCALATION = AUTO);
GO

---------------------------------------------------------------------
-- 6. Снова очистите статистику ожиданий (п.2)
---------------------------------------------------------------------

DBCC SQLPERF('sys.dm_os_wait_stats',CLEAR);


---------------------------------------------------------------------
-- 7.
-- Снова выполните скрипт .\start-load-ex.ps1 workload2.sql
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 8. Просмотрите ожидания блокировок (Lock Waits) в Activity Monitor
-- значение Cumulative Wait Time (sec) для Lock wait
---------------------------------------------------------------------