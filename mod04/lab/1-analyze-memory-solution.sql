-- 1. Запустите нагрузочный скрипт 
-- Откройте Powershell от имени администратора, перейдите в папку ..Tuning-SqlServer-Databases\mod04\lab
-- Выполните скрипт .\start-load-ex.ps1 workload.sql
-- Скрипт запустит 10 фоновых работ (job), выполняющих один и тот же скрипт workload.sql
-- Дождитесь окончания выполнения работ

-- 2. Определите статистику для типа ожиданий MEMORY_ALLOCATION_EXT

SELECT *
FROM sys.dm_os_wait_stats
WHERE wait_type = 'MEMORY_ALLOCATION_EXT';


-- 3. Установите минимальную память сервера, равную 512 Мб
-- Установите максимальную память сервера, равную 4096 Мб

EXEC sp_configure N'Min Server Memory','0';
EXEC sp_configure N'Max Server Memory','8196';

-- 4. Перезагрузите экземпляр Sql Server


-- 5. Снова выполните скрипт .\start-load-ex.ps1 workload.sql и дождитесь окончания выполнения работ

-- 6. Снова определите статистику для типа ожиданий MEMORY_ALLOCATION_EXT

select *
from sys.dm_os_wait_stats
where wait_type = 'MEMORY_ALLOCATION_EXT';

-- 7. Сравните результаты стататистики с результатами, полученными в п.2