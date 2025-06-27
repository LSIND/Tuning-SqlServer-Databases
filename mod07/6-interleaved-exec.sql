
use master;
GO

ALTER DATABASE AdventureWorks
SET COMPATIBILITY_LEVEL = 120; -- 2014
GO


USE AdventureWorks;
GO

-- Создание тестовой таблицы SalesData

CREATE TABLE dbo.Sales (
    SaleID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ProductCategory NVARCHAR(50),
    SaleAmount DECIMAL(18,2),
    SaleDate DATE
);

-- Генерация большого количества данных ~ 5мин
SET NOCOUNT ON;

DECLARE @i INT = 1;
WHILE @i <= 500000 -- 500k строк
BEGIN
    INSERT INTO dbo.Sales (ProductCategory, SaleAmount, SaleDate)
    VALUES 
    (CASE WHEN @i % 3 = 0 THEN 'Electronics'
          WHEN @i % 3 = 1 THEN 'Clothing'
          ELSE 'Home Appliances' END,
     CAST((RAND() * 1000) AS DECIMAL(18,2)),
     DATEADD(DAY, CAST(RAND() * 365 AS INT), '2022-01-01'));

    SET @i = @i + 1;
END;
GO



-- Функция для агрегации продаж по категориям
CREATE FUNCTION dbo.GetSalesByCategoryAndDateRange (@StartDate DATE, @EndDate DATE)
RETURNS @SalesSummary TABLE (
    ProductCategory NVARCHAR(50),
    TotalSales DECIMAL(18,2),
    AverageSale DECIMAL(18,2)
)
AS
BEGIN
    INSERT INTO @SalesSummary
    SELECT 
        ProductCategory,
        SUM(SaleAmount) AS TotalSales,
        AVG(SaleAmount) AS AverageSale
    FROM dbo.Sales
    WHERE SaleDate >= @StartDate AND SaleDate < @EndDate
    GROUP BY ProductCategory;

    RETURN;
END;
GO

-- est plan - TVF: exec: 1, number of rows: 100
-- clustered index scan (500 000)
-- act plan: 
SELECT * FROM dbo.GetSalesByCategoryAndDateRange('2022-01-01', '2022-12-31');


-- Запрос с использованием MSTVF
-- категории товаров, общая сумма продаж которых превышает 100,000.
-- TVF и Table Scan: est number of rows to be read / exec = 100
-- но функция возвращает 3 строки (у нас три категории)
SELECT 
    s.ProductCategory,
    s.TotalSales,
    s.AverageSale
FROM dbo.GetSalesByCategoryAndDateRange('2022-01-01', '2022-12-31') AS s
WHERE s.TotalSales > 100000;

use master;
GO

ALTER DATABASE AdventureWorks
SET COMPATIBILITY_LEVEL = 140; -- 2017
GO

-- Запрос с использованием MSTVF
-- TVF и Table Scan: est number of rows to be read / exec = 3 !

USE AdventureWorks;
GO

SELECT 
    s.ProductCategory,
    s.TotalSales,
    s.AverageSale
FROM dbo.GetSalesByCategoryAndDateRange('2022-01-01', '2022-12-31') AS s
WHERE s.TotalSales > 100000;



DROP TABLE dbo.Sales;
DROP FUNCTION dbo.GetSalesByCategoryAndDateRange;