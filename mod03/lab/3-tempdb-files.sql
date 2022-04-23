-- ������������ ������ ������ tempdb 
-- ��� ��������� �������� ��������������� ���������� (latch contention) � tempdb. 


-- 1. �������� Powershell �� ����� ��������������, ��������� � ����� ..Tuning-SqlServer-Databases\mod03\lab
-- ��������� ������ .\start-load-ex.ps1 load-script.sql
-- ������ �������� 5 ������� ����� (job), ����������� ���� � ��� �� ������ load-script.sql
-- ��������� ��������� ���������� �����

----------------------------------------------------------------
-- 2. � ������� sys.dm_os_wait_stats ���������� LATCH waits ��� ���������� SQL Server
----------------------------------------------------------------



----------------------------------------------------------------
-- 3. ����������� ���������� � ������ tempdb. ���������� ���������� ����
-- ������� ������?
----------------------------------------------------------------


----------------------------------------------------------------
-- 4. ������� ����� ������ tempdb
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
-- 5. ����� ��������� ������ .\start-load-ex.ps1 load-script.sql
-- ��������� ��������� ���������� �����
----------------------------------------------------------------

----------------------------------------------------------------
-- 6. �������� ������������������
-- ��� ���������?
----------------------------------------------------------------


----------------------------------------------------------------
-- 7. ������� tempdb � ����������� ���������. �������� 7 ������ ������ � tempdb
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