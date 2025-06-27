
use master;
GO

ALTER DATABASE AdventureWorks
SET COMPATIBILITY_LEVEL = 120; -- 2014
GO

use AdventureWorks;
go

-- Создание таблицы SalesData
CREATE TABLE dbo.SalesData (
    SaleID BIGINT IDENTITY(1,1),
    ProductCategory NVARCHAR(50),
    SaleAmount DECIMAL(18,2),
    SaleDate DATE
);

-- Добавление индекса Columnstore
CREATE CLUSTERED COLUMNSTORE INDEX CCI_SalesData ON dbo.SalesData;


SET NOCOUNT ON;
DECLARE @i INT = 1;
WHILE @i <= 1000000 -- 1 миллион строк  -- 10min
BEGIN
    INSERT INTO dbo.SalesData (ProductCategory, SaleAmount, SaleDate)
    VALUES 
    (CASE WHEN @i % 3 = 0 THEN 'Electronics'
          WHEN @i % 3 = 1 THEN 'Clothing'
          ELSE 'Home Appliances' END,
     CAST((RAND() * 1000) AS DECIMAL(18,2)),
     DATEADD(DAY, CAST(RAND() * 365 AS INT), '2022-01-01'));

    SET @i = @i + 1;
END;



-- Запрос с агрегацией
-- Columnstore Index Scan (Batch mode)
-- SELECT: Memory Grant 18 Mb - сколько раз бы не выполнялся запрос
SELECT 
    ProductCategory,
    SUM(SaleAmount) AS TotalSales,
    AVG(SaleAmount) AS AverageSale
FROM dbo.SalesData
WHERE SaleDate >= '20220101' AND SaleDate < '20220701'
GROUP BY ProductCategory;



use master;
GO

ALTER DATABASE AdventureWorks
SET COMPATIBILITY_LEVEL = 140; -- 2017
GO


USE AdventureWorks;
GO


-- Запрос с агрегацией
-- Columnstore Index Scan (Batch mode)
-- Memory Grant 3 Mb
SELECT 
    ProductCategory,
    SUM(SaleAmount) AS TotalSales,
    AVG(SaleAmount) AS AverageSale
FROM dbo.SalesData
WHERE SaleDate >= '20220101' AND SaleDate < '20220701'
GROUP BY ProductCategory;



--
DROP TABLE dbo.SalesData;