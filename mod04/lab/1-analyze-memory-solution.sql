-- 1. «апустите нагрузочный скрипт 
-- ќткройте Powershell от имени администратора, перейдите в папку ..Tuning-SqlServer-Databases\mod04\lab
-- ¬ыполните скрипт .\start-load-ex.ps1 workload.sql
-- —крипт запустит 10 фоновых работ (job), выполн¤ющих один и тот же скрипт workload.sql
-- ƒождитесь окончани¤ выполнени¤ работ

-- 2. ќпределите статистику дл¤ типа ожиданий MEMORY_ALLOCATION_EXT

SELECT *
FROM sys.dm_os_wait_stats
WHERE wait_type = 'MEMORY_ALLOCATION_EXT';


-- 3. ”становите минимальную пам¤ть сервера, равную 512 ћб
-- ”становите максимальную пам¤ть сервера, равную 4096 ћб

EXEC sp_configure N'Min Server Memory','0';
EXEC sp_configure N'Max Server Memory','8196';

-- 4. ѕерезагрузите экземпл¤р Sql Server


-- 5. —нова выполните скрипт .\start-load-ex.ps1 workload.sql и дождитесь окончани¤ выполнени¤ работ

-- 6. —нова определите статистику дл¤ типа ожиданий MEMORY_ALLOCATION_EXT

select *
from sys.dm_os_wait_stats
where wait_type = 'MEMORY_ALLOCATION_EXT';

-- 7. —равните результаты стататистики с результатами, полученными в п.2