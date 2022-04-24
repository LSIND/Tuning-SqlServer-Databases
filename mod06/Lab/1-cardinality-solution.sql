-- 1. Запустите рабочую нагрузку
-- Откройте Powershell от имени администратора, перейдите в папку ..Tuning-SqlServer-Databases\mod06\Lab\
-- Выполните скрипт .\1-start-load.ps1
-- * Если PS выдает ошибку об отсутствии цифровой подписи, в консоли напишите Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
-- Скрипт ps запустит 10 workers, выполняющих один и тот же скрипт 1-start-load-sql.sql
-- Запомните длительность выполнения (например, Finished after  00:00:19.4165261)
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 2. Просмотрите статистику из sys.stats для таблиц Proseware.WebResponse, 
-- Proseware.Campaign, Proseware.CampaignAdvert.
-- Требуется ли обновление статистики?
---------------------------------------------------------------------
USE AdventureWorks;
GO

SELECT OBJECT_NAME(object_id), STATS_DATE(object_id, stats_id) stats_date, * 
FROM sys.stats 
WHERE OBJECT_NAME(object_id) IN ('Campaign','CampaignAdvert','WebResponse')
ORDER BY object_id, stats_id;

---------------------------------------------------------------------
-- 3. Изучите статистику IX_WebResponse_CampaignAdvertID с помощью DBCC SHOW_STATISTICS 
-- Сколько строк содержит таблица Proseware.WebResponse?
---------------------------------------------------------------------
DBCC SHOW_STATISTICS ('Proseware.WebResponse','IX_WebResponse_CampaignAdvertID');


-- Определите реальное количество строк таблицы Proseware.WebResponse
SELECT rows FROM sys.partitions 
WHERE object_id = OBJECT_ID('Proseware.WebResponse');

---------------------------------------------------------------------
-- 4. Обновите статистику для всех строк (WITH FULLSCAN или SAMPLE 100 PERCENT)
---------------------------------------------------------------------
UPDATE STATISTICS Proseware.WebResponse WITH FULLSCAN;


-- Снова изучите статистику IX_WebResponse_CampaignAdvertID с помощью DBCC SHOW_STATISTICS 
-- Сколько строк содержит таблица Proseware.WebResponse?
DBCC SHOW_STATISTICS ('Proseware.WebResponse','IX_WebResponse_CampaignAdvertID');

-- Обновите все статистики для таблицы Proseware.CampaignAdvert
-- с сэмплированием 50% строк таблицы.
UPDATE STATISTICS Proseware.CampaignAdvert WITH SAMPLE 50 PERCENT;

---------------------------------------------------------------------
-- 5. Снова выполните скрипт .\1-start-load.ps1
-- Запомните длительность выполнения 
-- Сравните результаты с п.1