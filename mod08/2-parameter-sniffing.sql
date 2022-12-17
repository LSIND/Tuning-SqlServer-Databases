USE [AdventureWorks]
GO


-- 1. Новая таблица с нечетким распределением
SELECT * INTO dbo.Orders
FROM [Sales].[SalesOrderHeader];


-- Дополнить разными статусами примерно по 30000 строк: 3, 4, 6
-- Добавить 5 записей статуса 2

INSERT INTO dbo.Orders
           ([RevisionNumber]
      ,[OrderDate]  ,[DueDate]  ,[ShipDate]   ,[Status]
      ,[OnlineOrderFlag]   ,[SalesOrderNumber]  ,[PurchaseOrderNumber]  ,[AccountNumber]
      ,[CustomerID]   ,[SalesPersonID]   ,[TerritoryID]
      ,[BillToAddressID]   ,[ShipToAddressID]   ,[ShipMethodID]
      ,[CreditCardID]  ,[CreditCardApprovalCode]   ,[CurrencyRateID]
      ,[SubTotal]   ,[TaxAmt]   ,[Freight]  ,[TotalDue]
      ,[Comment]  ,[rowguid]  ,[ModifiedDate])
     SELECT TOP 5 [RevisionNumber] -- Кол-во
      ,[OrderDate]  ,[DueDate]  ,[ShipDate] ,2 -- STATUS
      ,[OnlineOrderFlag]  ,[SalesOrderNumber]  ,[PurchaseOrderNumber]
      ,[AccountNumber]  ,[CustomerID]  ,[SalesPersonID]  ,[TerritoryID]
      ,[BillToAddressID]  ,[ShipToAddressID]  ,[ShipMethodID]
      ,[CreditCardID]  ,[CreditCardApprovalCode]  ,[CurrencyRateID]
      ,[SubTotal]   ,[TaxAmt] ,[Freight]
      ,[TotalDue]  ,[Comment]  ,NEWID() ,[ModifiedDate]
	 FROM [Sales].[SalesOrderHeader]
          ORDER BY [SalesOrderID]
GO

-- Дополнительно обновить некоторые записи
UPDATE dbo.Orders
SET Status = 1
WHERE TerritoryID IN (4,6)

-- Проверить количество строк с разными статусами
SELECT Status, COUNT( Status)
  FROM dbo.Orders
  GROUP BY Status;

-- 2. Создание индекса PK
  ALTER TABLE dbo.Orders
ADD CONSTRAINT PK_OrderId
PRIMARY KEY CLUSTERED (SalesOrderID);
GO

-- Создание индекса по полю статус

CREATE NONCLUSTERED INDEX StInd
ON dbo.Orders([Status]);

DBCC SHOW_STATISTICS('dbo.Orders','StInd')
GO


--DROP PROCEDURE dbo.Total

-- 4. ХП с параметром
CREATE OR ALTER PROCEDURE dbo.Total(@s tinyint)
AS
SELECT SUM([SubTotal]) 
FROM dbo.Orders
WHERE Status = @s;
GO


SET STATISTICS IO ON

EXEC dbo.Total @s = 4; -- частое значение
EXEC dbo.Total @s = 2;

SET STATISTICS IO OFF


DBCC FREEPROCCACHE; -- очитска кэша планов
GO

SET STATISTICS IO ON

EXEC dbo.Total @s = 2;  -- logical reads 18 w Key Lookup  -- нечастое значение
EXEC dbo.Total @s = 4; -- тот же план

SET STATISTICS IO OFF
GO

-- решение 1
CREATE OR ALTER PROCEDURE dbo.Total(@s tinyint)
AS
SELECT SUM([SubTotal]) 
FROM dbo.Orders
WHERE Status = @s
OPTION (RECOMPILE);    -- решение для редких запросов, где стоимость компиляции ниже, чем стоимость времени выполнения запроса
GO

-- решение 2
CREATE OR ALTER PROCEDURE dbo.Total(@s tinyint)
AS
SELECT SUM([SubTotal]) 
FROM dbo.Orders
WHERE Status = @s
OPTION (OPTIMIZE FOR (@s = 4));    -- общее решение, которое перестает работать. когда в таблице больше нет статуса 4
GO

UPDATE dbo.Orders
SET Status = 7
WHERE Status = 4;


DBCC FREEPROCCACHE; -- очитска кэша планов
GO

SET STATISTICS IO ON

EXEC dbo.Total @s = 2;  -- logical reads 18 w Key Lookup  -- нечастое значение
EXEC dbo.Total @s = 3; -- ???

SET STATISTICS IO OFF
GO