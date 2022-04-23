-- 1. ��������������� �������� ������ � ���������� ������ ����� Demo
DROP TABLE IF EXISTS Proseware.Weblog;
GO

CREATE TABLE Proseware.Weblog
(	WeblogID bigint IDENTITY NOT NULL,
	log_date datetime2 NOT NULL,
	page_url varchar(200) NOT NULL,
	client_ip binary(16) NOT NULL,
	browser_name varchar(50) NOT NULL,
	page_visit_time_seconds int NOT NULL,
	INDEX PK_Proseware_Weblog CLUSTERED COLUMNSTORE -- ���������� ���������� ������ �� �������
);
GO

CREATE TABLE Demo.Webpage
(pagename varchar(20));
GO

CREATE TABLE Demo.Weburl
(urlname varchar(50));
GO

CREATE TABLE Demo.Websuffix
(suffix varchar(20));
GO

CREATE TABLE Demo.Browser
(browser varchar(30));
GO

INSERT Demo.Webpage (pagename)
VALUES
('index'),('default'),('home'),('store'),('index'),('default'),('home'),
('store'),('index'),('default'),('home'),('store'),('checkout'),('checkout'),
('checkout'),('product'),('product'),('product'),('product'),('product'),('about'),
('jobs'),('login'),('account'),('account'),('account'),('account'),('account'),('orders'),
('order'),('orders'),('order'),('orders'),('order'),('shipping'),('returns'),('contest'),
('contact');
GO

INSERT Demo.Weburl (urlname)
VALUES
('http://adventure-works.com'),('https://adventure-works.com'),('http://www.adventure-works.com'),('https://www.adventure-works.com');
GO

INSERT Demo.Websuffix (suffix)
VALUES 
('.html'),('.html'),('.htm'),('.htm'),('.htm'),
('.html'),('.html'),('.htm'),('.htm'),('.htm'),
('.aspx'),('.aspx'),('.png'),('.jpg');
GO

INSERT Demo.Browser (browser)
VALUES 
('Firefox'),('Chrome'),('Internet Explorer'),('Safari'),('Chromium'),('Edge'),('Opera'),('Webkit');
GO


-- 2. ���������� 10 ����� � ������� Proseware.Weblog
INSERT Proseware.Weblog (log_date, page_url,client_ip,browser_name, page_visit_time_seconds)
SELECT TOP (1) '2015-01-01', CONCAT(w.urlname,'/',p.pagename,s.suffix),
CAST(RAND()*4294967295 + 4294967295 AS bigint) , b.browser,
CAST(RAND()*60 AS int)
FROM Demo.Weburl AS w
CROSS JOIN Demo.Webpage AS p
CROSS JOIN Demo.Websuffix AS s
CROSS JOIN Demo.Browser AS b
ORDER BY NEWID();
GO 10


-- 3. ������ ����� (10), �� ������� ������� ������
-- delta_store_hobt_id != NULL
SELECT * FROM Proseware.Weblog;

SELECT * FROM sys.column_store_row_groups 
WHERE object_id = OBJECT_ID('Proseware.Weblog');

-- 4. ������� 1 100 000 ����� (���� �� 1000 �����) 
-- This will trigger the closure of the deltastore

INSERT Proseware.Weblog (log_date, page_url,client_ip,browser_name, page_visit_time_seconds)
SELECT TOP (1000) 
'2015-01-01', CONCAT(w.urlname,'/',p.pagename,s.suffix),
CAST(RAND()*4294967295 + 4294967295 AS bigint) , b.browser,
CAST(RAND()*60 AS int)
FROM Demo.Weburl AS w
CROSS JOIN Demo.Webpage AS p
CROSS JOIN Demo.Websuffix AS s
CROSS JOIN Demo.Browser AS b
ORDER BY NEWID();
GO 1100

-- 5. ������ ����� (1 100 010), �� ������� ������� ������ - 2 ������ � state_description OPEN �  CLOSED.
-- CLOSED: total_rows = 1048576 - ������������ �������� ��� ������ �����
SELECT * FROM sys.column_store_row_groups 
WHERE object_id = OBJECT_ID('Proseware.Weblog');

-- 6. ������� 2 000 000 �� 1 ����
INSERT Proseware.Weblog (log_date, page_url,client_ip,browser_name, page_visit_time_seconds)
SELECT TOP (2000000) 
DATEADD(ms,ROW_NUMBER() OVER (ORDER BY a.name) ,'2015-01-01'),
CONCAT(w.urlname,'/',p.pagename,s.suffix),
CAST(ROW_NUMBER() OVER (ORDER BY a.name)  + 4294967295 AS bigint) , b.browser,
CAST(ROW_NUMBER() OVER (ORDER BY a.name) % 180 AS int)
FROM Demo.Weburl AS w
CROSS JOIN Demo.Webpage AS p
CROSS JOIN Demo.Websuffix AS s
CROSS JOIN Demo.Browser AS b
CROSS JOIN master.dbo.spt_values AS a;
GO

-- 6. ������ ����� (3 100 010), �� ������� ������� ������ - 4 ������ � state_description OPEN � COMPRESSED.
-- CLOSED: total_rows = 1048576 - ������������ �������� ��� ������ �����

SELECT * FROM sys.column_store_row_groups 
WHERE object_id = OBJECT_ID('Proseware.Weblog');

-- 7. �������� ��� ������ ������ �����: 2 ��� 3 ��� column_id
SELECT * FROM sys.column_store_segments;

-- 8. ������� 10 ����� �� �������
SET NOCOUNT OFF
DELETE Proseware.Weblog WHERE WeblogID > 3100000;

-- 9. deleted bitmap �������� 10 �����
SELECT * FROM sys.internal_partitions
WHERE object_id = OBJECT_ID('Proseware.Weblog');
GO

-- 10. ������� �������
DROP TABLE IF EXISTS Proseware.Weblog;
DROP TABLE IF EXISTS Demo.Webpage
DROP TABLE IF EXISTS  Demo.Weburl
DROP TABLE IF EXISTS  Demo.Websuffix
DROP TABLE IF EXISTS  Demo.Browser
GO
