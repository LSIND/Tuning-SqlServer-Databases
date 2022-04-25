USE [deadLockDb];
GO
 
-- 1. Открыть транзакцию 2 и выполнить первый UPDATE
BEGIN TRAN
 
UPDATE table2
SET student_name = student_name + 'Transaction2'
WHERE id = 1

 -- 4. Выполнить второй UPDATE -> COMMIT
UPDATE table1
SET student_name = student_name + 'Transaction2'
WHERE id IN (1,2,3,4,5)
 
COMMIT TRANSACTION

-- Ошибка 1205
-- TRAN2 менее важная, тк обновляет 1 строку. Приоритет: NORMAL

-- Просмотреть изменения
SELECT * FROM table1;
SELECT * FROM table2;


--SET DEADLOCK_PRIORITY HIGH
--BEGIN TRAN