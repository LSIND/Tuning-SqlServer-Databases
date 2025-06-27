USE master;
GO

CREATE DATABASE deadLockDb;
GO
 
USE deadLockDb;
 
CREATE TABLE dbo.table1
(
	id INT IDENTITY PRIMARY KEY,
	student_name NVARCHAR(50)
);
 
INSERT INTO dbo.table1 values ('James');
INSERT INTO dbo.table1 values ('Andy');
INSERT INTO dbo.table1 values ('Sal');
INSERT INTO dbo.table1 values ('Helen');
INSERT INTO dbo.table1 values ('Jo');
INSERT INTO dbo.table1 values ('Wik');
 
 
CREATE TABLE dbo.table2
(
	id INT IDENTITY PRIMARY KEY,
	student_name NVARCHAR(50)
);
 
INSERT INTO dbo.table2 values ('Alan');
INSERT INTO dbo.table2 values ('Rik');
INSERT INTO dbo.table2 values ('Jack');
INSERT INTO dbo.table2 values ('Mark');
INSERT INTO dbo.table2 values ('Josh');
INSERT INTO dbo.table2 values ('Fred');