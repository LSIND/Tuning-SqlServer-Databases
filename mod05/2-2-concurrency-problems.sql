-- 2.2


USE AdventureWorks;
GO

-- ������ 1
-- �������� ���������� � UPDATE ����� ��������
BEGIN TRANSACTION
	UPDATE [Sales].[CustomerPII]
	SET [PhoneNumber] = N'999-999-9999'
	WHERE CustomerID = 19169;

-- ������ 2
ROLLBACK;

-- ������ 3
UPDATE [Sales].[CustomerPII]
SET [PhoneNumber] = N'333-333-3333'
WHERE CustomerID = 19169;

-- ������ 4
UPDATE [Sales].[CustomerPII]
SET [PhoneNumber] = N'444-444-4444'
WHERE CustomerID = 19169;

-- ������ 5 - ���������� ����� ������
INSERT [Sales].[CustomerPII]
([CustomerID], FirstName, LastName, SSN, [CreditCardNumber], EmailAddress, PhoneNumber, TerritoryID)
VALUES (1, 'Anna', 'Ivanova', NULL, NULL, 'anna_i@gmail.com', 
N'111-555-1111', 1);

-- ������ 6
BEGIN TRANSACTION
	UPDATE [Sales].[CustomerPII]
	SET [PhoneNumber] = N'616-666-6666'
	WHERE CustomerID = 19169;

-- ������ 7
COMMIT