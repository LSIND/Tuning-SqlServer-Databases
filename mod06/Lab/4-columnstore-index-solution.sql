USE AdventureWorks;
GO

-------------------------------------
-- 1. Создайте некластерный колоночный индекс (Columnstore Index) на таблицу Proseware.WebResponse
-- Имя индекса IX_NCI_WebResponse
-- Индекс покрывает следующие столбцы: log_date, page_url, browser_name, page_visit_time_seconds
-------------------------------------

CREATE COLUMNSTORE INDEX IX_NCI_WebResponse
ON Proseware.WebResponse (log_date, page_url, browser_name, page_visit_time_seconds);
GO

-------------------------------------
-- 2. Создайте таблицу Proseware.Demographic с кластерным колоночным индексом (Columnstore)
-- Имя индекса PK_Proseware_Weblog

CREATE TABLE Proseware.Demographic
   (	DemographicID bigint NOT NULL,
		DemoCode varchar(50),
		Code01 int, 
		Code02 int,
		Code03 tinyint,
		Income decimal(18,3),
		MaritalStatus char(1),
		Gender char(1),
		INDEX PK_Proseware_Weblog CLUSTERED COLUMNSTORE
	);

-- 3. Выполните запрос ан вставку одного значения в Proseware.Demographic
INSERT INTO Proseware.Demographic (DemographicID)
VALUES (1);

-- 4. Убедитесь, что в Proseware.Demographic добавилась одна строка
-------------------------------------

SELECT * FROM Proseware.Demographic;

-------------------------------------
-- 5. Добавьте некластерный уникальный индекс в таблицу Proseware.Demographic с кластерным колоночным индексом
-- Имя индекса - IX_Demographic_DemographicID, столбец - DemographicID
-------------------------------------

CREATE UNIQUE NONCLUSTERED INDEX IX_Demographic_DemographicID
ON Proseware.Demographic (DemographicID);


-- 6. Запустите вставку данных. Каков результат?
INSERT INTO Proseware.Demographic (DemographicID)
VALUES (1);

-- 7. Удалите таблицу Proseware.Demographic

DROP TABLE IF EXISTS Proseware.Demographic;