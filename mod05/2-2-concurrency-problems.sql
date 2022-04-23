-- 2.2


USE AdventureWorks;
GO

-- Запрос 1
-- Открытие транзакции и UPDATE номер телефона
BEGIN TRANSACTION
	UPDATE [Sales].[CustomerPII]
	SET [PhoneNumber] = N'999-999-9999'
	WHERE CustomerID = 19169;

-- Запрос 2
ROLLBACK;

-- Запрос 3
UPDATE [Sales].[CustomerPII]
SET [PhoneNumber] = N'333-333-3333'
WHERE CustomerID = 19169;

-- Запрос 4
UPDATE [Sales].[CustomerPII]
SET [PhoneNumber] = N'444-444-4444'
WHERE CustomerID = 19169;

-- Запрос 5 - добавление новой строки
INSERT [Sales].[CustomerPII]
([CustomerID], FirstName, LastName, SSN, [CreditCardNumber], EmailAddress, PhoneNumber, TerritoryID)
VALUES (1, 'Anna', 'Ivanova', NULL, NULL, 'anna_i@gmail.com', 
N'111-555-1111', 1);

-- Запрос 6
BEGIN TRANSACTION
	UPDATE [Sales].[CustomerPII]
	SET [PhoneNumber] = N'616-666-6666'
	WHERE CustomerID = 19169;

-- Запрос 7
COMMIT