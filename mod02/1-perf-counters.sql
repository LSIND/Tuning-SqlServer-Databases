-- 1. Откройте файл PM 1-perf-counters-disk.PerfmonCfg

-- 2. Создайте таблицу insertTargetEx и заполните ее данными в цикле

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

DECLARE @start datetime2 = GETDATE();

WHILE DATEDIFF(ss,@start,GETDATE()) < 300
BEGIN
	INSERT INTO dbo.insertTargetEX (date1)
	VALUES (GETDATE())
END
GO

-- 3. Вернитесь в PM и просмотрите работу диска
-- IOPS:
---- Physical Disk: Avg. Disk Bytes/Read
---- Physical Disk: Avg. Disk Bytes/Write
-- Throughput:
---- Physical Disk: Disk Read Bytes/Sec
---- Physical Disk: Disk Write Bytes/Sec
-- Latency factor:
---- Physical Disk: Avg. Disk sec/Read
---- Physical Disk: Avg. Disk sec/Write

-- 4. Удалите таблицу
DROP TABLE IF EXISTS dbo.insertTargetEx;