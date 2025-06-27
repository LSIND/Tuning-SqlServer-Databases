USE [deadLockDb];
GO
 
-- 1. Открыть транзакцию 1 и выполнить первый UPDATE
BEGIN TRAN
 
UPDATE dbo.table1
SET student_name = student_name + 'Transaction1'
WHERE id IN (1,2,3,4,5)
 
 -- 3. Выполнить второй UPDATE -> COMMIT
UPDATE dbo.table2
SET student_name = student_name + 'Transaction1'
WHERE id = 1
 
COMMIT TRANSACTION