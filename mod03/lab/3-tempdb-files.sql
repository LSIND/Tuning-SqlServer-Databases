-- Перестроение файлов данных tempdb 
-- Был обнаружен конфликт кратковременных блокировок (latch contention) в tempdb. 


-- 1. Откройте Powershell от имени администратора, перейдите в папку ..Tuning-SqlServer-Databases\mod03\lab
-- Выполните скрипт .\start-load-ex.ps1 load-script.sql
-- Скрипт запустит 5 фоновых работ (job), выполняющих один и тот же скрипт load-script.sql
-- Дождитесь окончания выполнения работ

----------------------------------------------------------------
-- 2. С помощью sys.dm_os_wait_stats определите LATCH waits для экземпляра SQL Server
----------------------------------------------------------------



----------------------------------------------------------------
-- 3. Просмотрите информацию о файлах tempdb. Определите физический путь
-- Сколько файлов?
----------------------------------------------------------------


----------------------------------------------------------------
-- 4. Удалите файлы данных tempdb
----------------------------------------------------------------
USE tempdb;
GO
DBCC SHRINKFILE(temp2, EMPTYFILE); 
GO
ALTER DATABASE [tempdb]  REMOVE FILE [temp2]; 
GO
DBCC SHRINKFILE(temp3, EMPTYFILE); 
GO
ALTER DATABASE [tempdb]  REMOVE FILE [temp3];
GO
DBCC SHRINKFILE(temp4, EMPTYFILE);
GO
ALTER DATABASE [tempdb]  REMOVE FILE [temp4];
GO
DBCC SHRINKFILE(temp5, EMPTYFILE);
GO
ALTER DATABASE [tempdb]  REMOVE FILE [temp5];
GO
DBCC SHRINKFILE(temp6, EMPTYFILE);
GO
ALTER DATABASE [tempdb]  REMOVE FILE [temp6];
GO
DBCC SHRINKFILE(temp7, EMPTYFILE);
GO
ALTER DATABASE [tempdb]  REMOVE FILE [temp7];
GO
DBCC SHRINKFILE(temp8, EMPTYFILE);
GO
ALTER DATABASE [tempdb]  REMOVE FILE [temp8];
GO

----------------------------------------------------------------
-- 5. Снова выполните скрипт .\start-load-ex.ps1 load-script.sql
-- Дождитесь окончания выполнения работ
----------------------------------------------------------------

----------------------------------------------------------------
-- 6. Измерьте производительность
-- Что произошло?
----------------------------------------------------------------


----------------------------------------------------------------
-- 7. Верните tempdb к предыдущему состоянию. Добавьте 7 файлов данных в tempdb
----------------------------------------------------------------

USE [master]
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'temp2', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\temp2.ndf' , SIZE = 8MB , FILEGROWTH = 8MB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'temp3', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\temp3.ndf' , SIZE = 8MB , FILEGROWTH = 8MB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'temp4', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\temp4.ndf' , SIZE = 8MB , FILEGROWTH = 8MB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'temp5', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\temp5.ndf' , SIZE = 8MB , FILEGROWTH = 8MB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'temp6', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\temp6.ndf' , SIZE = 8MB , FILEGROWTH = 8MB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'temp7', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\temp7.ndf' , SIZE = 8MB , FILEGROWTH = 8MB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'temp8', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\temp8.ndf' , SIZE = 8MB , FILEGROWTH = 8MB )
GO