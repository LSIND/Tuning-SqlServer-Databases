USE AdventureWorks;
GO

-------------------------------------
-- 1. �������� ������������ ���������� ������ (Columnstore Index) �� ������� Proseware.WebResponse
-- ��� ������� IX_NCI_WebResponse
-- ������ ��������� ��������� �������: log_date, page_url, browser_name, page_visit_time_seconds
-------------------------------------

CREATE COLUMNSTORE INDEX IX_NCI_WebResponse
ON Proseware.WebResponse (log_date, page_url, browser_name, page_visit_time_seconds);
GO

-------------------------------------
-- 2. �������� ������� Proseware.Demographic � ���������� ���������� �������� (Columnstore)
-- ��� ������� PK_Proseware_Weblog

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

-- 3. ��������� ������ �� ������� ������ �������� � Proseware.Demographic
INSERT INTO Proseware.Demographic (DemographicID)
VALUES (1);

-- 4. ���������, ��� � Proseware.Demographic ���������� ���� ������
-------------------------------------

SELECT * FROM Proseware.Demographic;

-------------------------------------
-- 5. �������� ������������ ���������� ������ � ������� Proseware.Demographic � ���������� ���������� ��������
-- ��� ������� - IX_Demographic_DemographicID, ������� - DemographicID
-------------------------------------

CREATE UNIQUE NONCLUSTERED INDEX IX_Demographic_DemographicID
ON Proseware.Demographic (DemographicID);


-- 6. ��������� ������� ������. ����� ���������?
INSERT INTO Proseware.Demographic (DemographicID)
VALUES (1);

-- 7. ������� ������� Proseware.Demographic

DROP TABLE IF EXISTS Proseware.Demographic;