-- 1. Изменить Security Policy
-- С помощью Local Security Policy (secpol.msc) определите, кто имеет право "Выполнение задач по обслуживанию томов" (Perform volume maintenance right).
-- secpol.msc --> Security Settings -> Local Policies -> User Rights Assignment.
-- Найти в списке Perform volume maintenance right
-- Дважды щелкнуть по Perform volume maintenance right - в свойствах определить права: Administrators, NT SERVICE\MSSQLSERVER

-- 2. Удалить права Administrators, NT SERVICE\MSSQLSERVER.
-- Дважды щелкнуть по Perform volume maintenance right и удалить Administrators, NT SERVICE\MSSQLSERVER.

-- 3. Перезапустить экземпляр SQL Server 

-- 4. Создайте базу данных [InstantFileTest]
-- ЗАМЕНИТЕ FILENAME на полный путь к файлам базы данных
-- Оцените время выполнения ~ 30 сек

USE [master]
GO

DROP DATABASE IF EXISTS [InstantFileTest];
GO

CREATE DATABASE [InstantFileTest]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'InstantFileTestData1', FILENAME = N'...\Tuning-SqlServer-Databases\mod03\lab\InstantFileTest\InstantFileTest_data1.mdf' , SIZE = 2048MB, MAXSIZE = UNLIMITED, FILEGROWTH = 128MB ),
FILEGROUP [USER] DEFAULT
( NAME = N'InstantFileTestData2', FILENAME = N'...\Tuning-SqlServer-Databases\mod03\lab\InstantFileTest\InstantFileTest_data2.mdf' , SIZE = 4096MB, MAXSIZE = UNLIMITED, FILEGROWTH = 128MB )
 LOG ON 
( NAME = N'InstantFileTest_log', FILENAME = N'...\Tuning-SqlServer-Databases\mod03\lab\InstantFileTest\InstantFileTest_log.mdf' , SIZE = 256MB , MAXSIZE = 2048GB , FILEGROWTH = 64MB )
GO


-- 4. Включите "Мгновенная инициализация файлов" (Instant File Initialization)
-- С помощью Local Security Policy (secpol.msc) определите, верните знаечния в  "Выполнение задач по обслуживанию томов" (Perform volume maintenance right).
-- secpol.msc --> Security Settings -> Local Policies -> User Rights Assignment.
-- Найти в списке Perform volume maintenance right

-- 5. Добавьте Administrators, NT SERVICE\MSSQLSERVER

-- 6. Перезапустить экземпляр SQL Server 

-- 7. Выполните скрипт п.4. и оцените время выполнения ~ 1 сек

-- 8. Удалить БД
USE [master]
GO

DROP DATABASE IF EXISTS [InstantFileTest];
GO