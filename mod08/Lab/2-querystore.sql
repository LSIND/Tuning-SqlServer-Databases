---------------------------------------------------------------------
-- 1. Откройте Powershell от имени администратора, перейдите в папку ..Tuning-SqlServer-Databases\mod08\lab
-- Выполните скрипт .\start-load-ex.ps1 workload2.sql
-- Скрипт запустит 10 фоновых работ (job), выполняющих один и тот же скрипт workload2.sql
---------------------------------------------------------------------

-- 2. Откройте свойства БД TSQL
-- Query Store -> Operation Mode (Requested) = Read Write
-- Query Store -> Statistics Collection Interval = 1 minute

-- 3. В Object Explorer раскройте TSQL-> Query Store -> Top Resource Consuming Queries
-- Определите query id в гистограмме слева


---------------------------------------------------------------------
-- 4. Создайте недостающий индекс
---------------------------------------------------------------------
USE TSQL
GO
CREATE NONCLUSTERED INDEX ix_CampaignResponse_CampaignID
ON Proseware.CampaignResponse (CampaignID)
INCLUDE (ResponseDate,ConvertedToSale,ConvertedSaleValueUSD)
GO


-- 5. В Object Explorer раскройте TSQL-> Query Store -> Tracked Queries.
-- В поиске введите query id из п.3
-- Выберите план -> нажмите Force Plan
-- Просмотрите отчет Top Resource Consuming Queries


---------------------------------------------------------------------
-- 6. Остановите нагрузку
---------------------------------------------------------------------
CREATE TABLE ##stopload(id int);