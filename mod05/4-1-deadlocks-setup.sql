USE master;
GO

CREATE DATABASE deadLockDb;
GO
 
USE deadLockDb;
 
CREATE TABLE table1
(
	id INT IDENTITY PRIMARY KEY,
	student_name NVARCHAR(50)
);
 
INSERT INTO table1 values ('James');
INSERT INTO table1 values ('Andy');
INSERT INTO table1 values ('Sal');
INSERT INTO table1 values ('Helen');
INSERT INTO table1 values ('Jo');
INSERT INTO table1 values ('Wik');
 
 
CREATE TABLE table2
(
	id INT IDENTITY PRIMARY KEY,
	student_name NVARCHAR(50)
);
 
INSERT INTO table2 values ('Alan');
INSERT INTO table2 values ('Rik');
INSERT INTO table2 values ('Jack');
INSERT INTO table2 values ('Mark');
INSERT INTO table2 values ('Josh');
INSERT INTO table2 values ('Fred');