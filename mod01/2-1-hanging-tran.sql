-- �������� ���������� � ��������� ���������� � 2-2-blocked-tran.sql
USE AdventureWorks;
GO

SELECT @@SPID as update_session_id;

BEGIN TRAN

	UPDATE [Production].[Product]
	SET  [Name]= N'New Product Demo Update'
	WHERE ProductID = 1;

-- ���������  ������� ����� �.9 ������� 2-thread-lifecycle.sql
--ROLLBACK
