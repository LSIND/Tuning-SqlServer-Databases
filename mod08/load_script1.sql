-- load generation script 1
-- loops for up to 60 minutes, or until the ##stopload shared temp table is created
DROP TABLE IF EXISTS ##stopload;
DROP TABLE IF EXISTS ##wideplan;

USE TSQL;
GO

DECLARE @start datetime2 = GETDATE();
IF @@SPID % 5 = 0
	BEGIN --update
		WHILE DATEDIFF(ss,@start,GETDATE()) < 3600 AND OBJECT_ID('tempdb..##stopload') IS NULL
		BEGIN
											
			UPDATE TOP (10) Sales.Orders SET shippeddate = GETDATE();
				
			WAITFOR DELAY '00:00:03';
		END
	END
ELSE
	BEGIN --select
		WHILE DATEDIFF(ss,@start,GETDATE()) < 3600 AND OBJECT_ID('tempdb..##stopload') IS NULL
		BEGIN
				DECLARE @sid1 int, @sid2 int ;

				SET  @sid1 = (SELECT TOP 1 orderid FROM Sales.Orders ORDER BY NEWID());
				IF OBJECT_ID('tempdb..##wideplan') IS NOT NULL
					SET  @sid2 = (SELECT TOP 1 orderid FROM Sales.Orders ORDER BY orderid DESC);
				ELSE
					SET @sid2 = @sid1;

				EXEC sp_executesql N'SELECT	so.custid, so.orderdate, so.orderid, so.shipaddress, so.shipcity, so.shipcountry,
						od.productid, od.qty, od.unitprice, od.discount
				FROM Sales.Orders as so
				JOIN Sales.OrderDetails as od
				ON od.orderid = so.orderid
				WHERE so.orderid BETWEEN @sid1 AND @sid2
				ORDER BY od.qty;', N'@sid1 int, @sid2 int', @sid1 = @sid1, @sid2 = @sid2;

				WAITFOR DELAY '00:00:01';
		END

	END
	