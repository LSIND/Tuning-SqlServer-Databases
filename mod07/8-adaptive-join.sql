use master;
GO

ALTER DATABASE AdventureWorks
SET COMPATIBILITY_LEVEL = 120; -- 2014
GO

USE AdventureWorks;
GO


-- Создание таблицы Orders
CREATE TABLE dbo.Orders (
    OrderID BIGINT IDENTITY(1,1),
    CustomerID INT,
    OrderDate DATE
);

-- Добавление индекса Columnstore
CREATE CLUSTERED COLUMNSTORE INDEX CCI_Orders ON Orders;

-- Создание таблицы OrderDetails
CREATE TABLE dbo.OrderDetails (
    OrderDetailID BIGINT IDENTITY(1,1),
    OrderID BIGINT,
    ProductID INT,
    Quantity INT
);

-- Добавление индекса Columnstore
CREATE CLUSTERED COLUMNSTORE INDEX CCI_OrderDetails ON OrderDetails;


SET NOCOUNT ON;
-- Заполнение таблицы Orders
DECLARE @i INT = 1;
WHILE @i <= 200000 -- 100,000 заказов
BEGIN
    INSERT INTO dbo.Orders (CustomerID, OrderDate)
    VALUES 
    (CAST(RAND() * 1000 AS INT), DATEADD(DAY, CAST(RAND() * 365 AS INT), '2022-01-01'));

    SET @i = @i + 1;
END;

-- Заполнение таблицы OrderDetails
DECLARE @j INT = 1; -- 3min
WHILE @j <= 1000000 -- 1,000,000 позиций в заказах
BEGIN
    INSERT INTO dbo.OrderDetails (OrderID, ProductID, Quantity)
    VALUES 
    (CAST(RAND() * 100000 AS INT) + 1, CAST(RAND() * 100 AS INT), CAST(RAND() * 10 AS INT));

    SET @j = @j + 1;
END;





-- Запрос с соединением
-- Выбран Hash Match Parallell
SELECT 
    o.OrderID,
    o.CustomerID,
    od.ProductID,
    od.Quantity
FROM dbo.Orders o
JOIN dbo.OrderDetails od
    ON o.OrderID = od.OrderID
WHERE o.OrderDate >= '2022-01-01' AND o.OrderDate < '2022-06-30';


use master;
GO
ALTER DATABASE AdventureWorks
SET COMPATIBILITY_LEVEL = 140; -- 2017
GO

USE AdventureWorks;
GO


-- Запрос с соединением
-- Выбран Hash Match -- Adaptive Join
SELECT 
    o.OrderID,
    o.CustomerID,
    od.ProductID,
    od.Quantity
FROM dbo.Orders o
JOIN dbo.OrderDetails od
    ON o.OrderID = od.OrderID
WHERE o.OrderDate >= '2022-01-01' AND o.OrderDate < '2022-06-30';







DROP TABLE dbo.OrderDetails;
DROP TABLE dbo.Orders;