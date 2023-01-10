------------------VIEW------------------------------------------------------------
--"AS a CEO of this company I would like to know what are the basic statistics (average, sum, count, ranks) for our
--shops, to make further business decisions based on that"
--" I would also like to know which three shops have the highest total sales"
----------------------------------------------------------------------------------
--window functions used inside the view---

CREATE VIEW vSalesOfProductsByShops
AS
WITH Base AS 
(SELECT apc.Name AS Shop, 
	p.ProductName, 
	p.SellPrice AS Price, 
	SUM(dl.Quantity) AS QuantityOfProduct,
	SUM(dh.TotalAmount) AS TotalAmount
	FROM DocumentHeaders dh
	INNER JOIN DocumentLines dl
		ON dh.ID = dl.DocumentHeaderID
	INNER JOIN AssociatedPlaces apc
		ON apc.ID = dh.OriginalPlaceID
	INNER JOIN Products p
		On p.ID = dl.ProductID
WHERE DocumentType = 'Receipt' 
GROUP BY apc.Name, 
	p.ProductName, 
	p.SellPrice
) 
SELECT
	Shop, 
	ProductName, 
	Price, 
	QuantityOfProduct,
	TotalAmount,
	AVG(TotalAmount) OVER (Partition BY Shop  ORDER BY TotalAmount
	ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS AverageSales,
	COUNT(TotalAmount) OVER (Partition BY Shop  ORDER BY TotalAmount
	ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS CountSales,
	SUM(TotalAmount) OVER (Partition BY Shop  ORDER BY TotalAmount
	ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS SumSales,
	RANK() OVER (Partition BY Shop ORDER BY TotalAmount desc) AS RankNumber,
	DENSE_RANK() OVER (Partition BY Shop ORDER BY TotalAmount desc) AS DenseRankNumber 
FROM Base


ALTER VIEW vSumSalesTop3Shops
AS
SELECT TOP 3 Shop, SumSales 
FROM vSalesOfProductsByShops
GROUP BY Shop, SumSales
ORDER BY SumSales desc

---based on previous view I have create a ranking of 3 shops with highes sales sum

SELECT * FROM vSalesOfProductsByShops
SELECT * FROM vSumSalesTop3Shops





