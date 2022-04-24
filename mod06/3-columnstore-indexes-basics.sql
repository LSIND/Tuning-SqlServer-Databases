-- 1. Пример агрегатов
-- rowstore clustered index [PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID]
-- database engine применяет leaf-level page scan для агрегирования значений для ProductID и OrderQty; 

SELECT ProductID
 ,SUM(OrderQty) AS ProductTotalQuantitySales
FROM [Sales].[SalesOrderDetail]
GROUP BY ProductID
ORDER BY ProductID;

-- 1.1. Создание некластерного индекса COLUMNSTORE
CREATE NONCLUSTERED COLUMNSTORE INDEX ncci ON [Sales].[SalesOrderDetail]
(ProductID, OrderQty);
GO

-- 1.2 План запроса с использованием индекса COLUMNSTORE и без него
SELECT ProductID
 ,SUM(OrderQty) AS ProductTotalQuantitySales
FROM [Sales].[SalesOrderDetail]
GROUP BY ProductID
ORDER BY ProductID;

ALTER INDEX ncci ON [Sales].[SalesOrderDetail]
DISABLE; 
 
 SELECT ProductID
 ,SUM(OrderQty) AS ProductTotalQuantitySales
FROM [Sales].[SalesOrderDetail]
GROUP BY ProductID
ORDER BY ProductID;
GO

-- 2. Внутреннее содержание индекса
ALTER INDEX ncci ON [Sales].[SalesOrderDetail]
REBUILD; 

select * from sys.indexes
where name = 'ncci';

-- Статистика возвращает NULL
DBCC SHOW_STATISTICS('[Sales].[SalesOrderDetail]','ncci');

-- сведения об индексах columnstore по группам строк
-- total_rows = Общее число строк, которые физически хранятся в группе строк

SELECT * FROM sys.column_store_row_groups;

-- Возвращает по одной строке для каждого сегмента столбца в индексе columnstore. 
-- Для каждого столбца группы строк имеется один сегмент столбца. 
-- таблица с 1 группой строк и 4 столбцами возвращает 4 строки
-- encoding_type: 2 = VALUE_HASH_BASED — нестроковый или двоичный столбец с общими значениями в словаре

SELECT * FROM sys.column_store_segments; 

SELECT * FROM sys.column_store_dictionaries; -- DELTA STORESELECT * FROM sys.column_store_row_groups WHERE delta_store_hobt_id IS NOT NULL; -- DELTASTORE После обновления данныхUPDATE[Sales].[SalesOrderDetail]SET [OrderQty] = [OrderQty] + 8WHERE [SalesOrderID] BETWEEN 43660 AND 43895;
SELECT * FROM sys.column_store_row_groups 
WHERE delta_store_hobt_id IS NOT NULL; 

-- UPDATE = DELETE после INSERT
-- Deleted Bitmap

SELECT * FROM sys.internal_partitions
WHERE internal_object_type_desc = 'COLUMN_STORE_DELETE_BITMAP';
GO