-- цикл на 3 минуты

DROP TABLE IF EXISTS tempdb..##stopload2;
GO
USE AdventureWorks;
GO

DECLARE @start datetime2 = GETDATE();
declare @low int;
declare @high int;; 
declare @rand int;

		WHILE DATEDIFF(ss,@start,GETDATE()) < 180
		BEGIN
				select @low = MIN(SalesOrderDetailID), @high = MAX(SalesOrderDetailID) from sales.SalesOrderDetail
				select @rand = round((((@high-@low)-1) * RAND() - @low),0);

				select @low = MIN(SalesOrderDetailID), @high = MAX(SalesOrderDetailID) from sales.SalesOrderDetail;
				select @rand = round((((@high-@low)-1) * RAND() - @low),0);

				SELECT p.ProductID, pc.Name ProductCategory, p.Name ProductName, coalesce(pr.Comments, 'No Reviews for prodct '+p.Name) Reviews, 
				p.ModifiedDate, count(*) ACount, sum(od.LineTotal) ATotal
				FROM Sales.SalesOrderDetail od
				JOIN Production.Product p ON od.ProductID = p.ProductID
				JOIN Production.ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID
				JOIN Production.ProductCategory pc on psc.ProductCategoryID = pc.ProductCategoryID
				left JOIN Production.ProductReview pr on od.ProductID = pr.ProductID
				WHERE od.SalesOrderDetailID <> @rand and p.ModifiedDate <> getDate()
				GROUP BY  pc.Name, p.Name, p.ProductID, pr.Comments, p.ModifiedDate
				HAVING SUM(od.LineTotal) > 20 
				ORDER BY NEWID() desc, pc.Name asc, p.Name desc, pr.Comments, p.ModifiedDate
				for xml auto,root('XML OUTPUT DATA') 
				OPTION (RECOMPILE);

				WAITFOR DELAY '00:00:01'
		END