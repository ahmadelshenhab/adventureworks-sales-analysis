-- =====================================================
-- AdventureWorks 2025 | E-Commerce Sales & Customer Analytics
-- File 2 of 3: Sales, Product & Category Analysis
-- Tool: SQL Server (T-SQL)
-- Overall KPIs, trends over time, category / subcategory / product performance and profitability
-- =====================================================

-- Overall Performance
WITH CTE_OverallPerformance AS
(
SELECT
	COUNT(DISTINCT s.SalesOrderID) TotalOrders,
	SUM(s.OrderQty) TotalUnitsSold,
	SUM(s.LineTotal) TotalRevenue,
	SUM(p.StandardCost * s.OrderQty) TotalCost
FROM SALES.SalesOrderDetail s
JOIN Production.Product p
	ON s.ProductID = p.ProductID
)
SELECT
	TotalOrders,
	TotalUnitsSold,
	ROUND(TotalRevenue, 2) TotalRevenue,
	ROUND(TotalCost, 2) TotalCost,
	ROUND(TotalRevenue - TotalCost, 2) TotalProfit,
	ROUND((TotalRevenue - TotalCost) * 100.0 / TotalRevenue, 2) ProfitMargin
FROM CTE_OverallPerformance;
-- Insight: Total revenue is $109.85M with $9.37M profit, an overall margin of 8.53%.

-- Over Time Performance
WITH CTE_OverTimePerformance AS
(
SELECT 
	DATEFROMPARTS(YEAR(h.OrderDate), MONTH(h.OrderDate), 1) OrderDate,
	COUNT(DISTINCT d.SalesOrderID) TotalOrders,
	SUM(d.OrderQty) TotalUnitsSold,
	SUM(d.LineTotal) TotalRevenue,
	SUM(p.StandardCost * d.OrderQty) TotalCost
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h
	ON d.SalesOrderID = h.SalesOrderID
JOIN Production.Product p
	ON d.ProductID = p.ProductID
GROUP BY YEAR(h.OrderDate), MONTH(h.OrderDate)
)
SELECT
	OrderDate,
	TotalOrders,
	TotalUnitsSold,
	ROUND(TotalRevenue, 2) TotalRevenue,
	ROUND(TotalCost, 2) TotalCost,
	ROUND(TotalRevenue - TotalCost, 2) TotalProfit,
	ROUND((TotalRevenue - TotalCost) * 100.0 / TotalRevenue, 2) ProfitMargin
FROM CTE_OverTimePerformance
ORDER BY OrderDate;
-- Insight: Monthly revenue peaks in April 2025 ($5.2M). See the Growth Over Time
-- query in file 03 for month-over-month growth.

-- Category Performance
WITH CTE_CategoryPerformance AS
(
SELECT
	pc.ProductCategoryID CategoryID,
	pc.Name CategoryName,
	COUNT(DISTINCT d.SalesOrderID) TotalOrders,
	SUM(d.OrderQty) TotalUnitsSold,
	SUM(d.LineTotal) TotalRevenue,
	SUM(d.OrderQty * p.StandardCost) TotalCost
FROM Sales.SalesOrderDetail d
JOIN Production.Product p
	ON d.ProductID = p.ProductID
JOIN Production.ProductSubcategory psc
	ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc
	ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.ProductCategoryID, pc.Name
)
SELECT
	CategoryID,
	CategoryName,
	TotalOrders,
	TotalUnitsSold,
	ROUND(TotalRevenue, 2) TotalRevenue,
	ROUND(TotalCost, 2) TotalCost,
	ROUND(TotalRevenue - TotalCost, 2) TotalProfit,
	ROUND((TotalRevenue - TotalCost) * 100.0 / TotalRevenue, 2) ProfitMargin
FROM CTE_CategoryPerformance
ORDER BY TotalRevenue DESC;
-- Insight: Bikes are the top category by revenue ($94.65M, about 86% of total)
-- and by profit ($7.94M, about 85% of total).

-- SubCategory Performance
WITH CTE_SubCategoryDetails AS
(
SELECT
	psc.ProductSubcategoryID SubcategoryID,
	psc.Name SubCategoryName,
	pc.ProductCategoryID CategoryID,
	pc.Name CategoryName,
	COUNT(DISTINCT d.SalesOrderID) TotalOrders,
	SUM(d.LineTotal) TotalRevenue,
	SUM(d.OrderQty) TotalUnitsSold,
	SUM(d.OrderQty * p.StandardCost) TotalCost
FROM Sales.SalesOrderDetail d
JOIN Production.Product p
	ON d.ProductID = p.ProductID
JOIN Production.ProductSubcategory psc
	ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc
	ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY psc.ProductSubcategoryID, psc.Name, pc.ProductCategoryID, pc.Name
)
SELECT
	SubcategoryID,
	SubCategoryName,
	CategoryID,
	CategoryName,
	TotalOrders,
	TotalUnitsSold,
	ROUND(TotalRevenue, 2) TotalRevenue,
	ROUND(TotalCost, 2) TotalCost,
	ROUND(TotalRevenue - TotalCost, 2) TotalProfit,
	ROUND((TotalRevenue - TotalCost) * 100.0 / TotalRevenue, 2) ProfitMargin
FROM CTE_SubCategoryDetails
ORDER BY TotalProfit DESC;
-- Insight : SubCategory (Mountain Bikes) generates more total profit than SubCategory (Road Bikes) despite SubCategory (Road Bikes) has much more total revenue.
-- SubCategory (Shorts) generates more total profit than SubCategory (Tires and Tubes) despite it's been sold less than SubCategory (Tires and Tubes) nearly half the amount.
-- SubCategory (Road Frames) generates high Total revenue but has a negative profit.

-- Product Performance (category)
WITH CTE_ProductPerformance AS
(
SELECT
	pc.ProductCategoryID CategoryID,
	pc.Name CategoryName,
	psc.ProductSubcategoryID SubCategoryID,
	psc.Name SubCategoryName,
	p.ProductID,
	p.Name ProductName,
	COUNT(DISTINCT d.SalesOrderID) TotalOrders,
	SUM(d.LineTotal) TotalRevenue,
	SUM(d.OrderQty) TotalUnitsSold,
	SUM(d.OrderQty * p.StandardCost) TotalCost
FROM Sales.SalesOrderDetail d
JOIN Production.Product p
	ON d.ProductID = p.ProductID
JOIN Production.ProductSubcategory psc
	ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc
	ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.ProductCategoryID, pc.Name, psc.ProductSubcategoryID, psc.Name, p.ProductID, p.Name
),
CTE_TopProducts AS
(
SELECT
	CategoryID,
	CategoryName,
	SubCategoryID,
	SubCategoryName,
	ProductID,
	ProductName,
	TotalOrders,
	TotalUnitsSold,
	ROUND(TotalRevenue, 2) TotalRevenue,
	ROUND(TotalCost, 2) TotalCost,
	ROUND(TotalRevenue - TotalCost, 2) TotalProfit,
	ROUND((TotalRevenue - TotalCost) * 100.0 / TotalRevenue, 2) ProfitMargin,
	ROW_NUMBER() OVER(PARTITION BY CategoryID ORDER BY TotalRevenue DESC) rn
FROM CTE_ProductPerformance
)
SELECT
	CategoryID,
	CategoryName,
	SubCategoryID,
	SubCategoryName,
	ProductID,
	ProductName,
	TotalOrders,
	TotalUnitsSold,
	TotalRevenue,
	TotalCost,
	TotalProfit,
	ProfitMargin
FROM CTE_TopProducts
WHERE rn <= 3;

-- Product Performance (SubCategory)
WITH CTE_ProductPerformance AS
(
SELECT
	pc.ProductCategoryID CategoryID,
	pc.Name CategoryName,
	psc.ProductSubcategoryID SubCategoryID,
	psc.Name SubCategoryName,
	p.ProductID,
	p.Name ProductName,
	COUNT(DISTINCT d.SalesOrderID) TotalOrders,
	SUM(d.LineTotal) TotalRevenue,
	SUM(d.OrderQty) TotalUnitsSold,
	SUM(d.OrderQty * p.StandardCost) TotalCost
FROM Sales.SalesOrderDetail d
JOIN Production.Product p
	ON d.ProductID = p.ProductID
JOIN Production.ProductSubcategory psc
	ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc
	ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.ProductCategoryID, pc.Name, psc.ProductSubcategoryID, psc.Name, p.ProductID, p.Name
),
CTE_TopProducts AS
(
SELECT
	CategoryID,
	CategoryName,
	SubCategoryID,
	SubCategoryName,
	ProductID,
	ProductName,
	TotalOrders,
	TotalUnitsSold,
	ROUND(TotalRevenue, 2) TotalRevenue,
	ROUND(TotalCost, 2) TotalCost,
	ROUND(TotalRevenue - TotalCost, 2) TotalProfit,
	ROUND((TotalRevenue - TotalCost) * 100.0 / TotalRevenue, 2) ProfitMargin,
	ROW_NUMBER() OVER(PARTITION BY CategoryID, SubCategoryID ORDER BY TotalRevenue DESC) rn
FROM CTE_ProductPerformance
)
SELECT
	CategoryID,
	CategoryName,
	SubCategoryID,
	SubCategoryName,
	ProductID,
	ProductName,
	TotalOrders,
	TotalUnitsSold,
	TotalRevenue,
	TotalCost,
	TotalProfit,
	ProfitMargin
FROM CTE_TopProducts
WHERE rn <= 3;

-- Product Profitability
WITH CTE_ProductDetails AS
(
SELECT
	p.ProductID,
	p.Name ProductName,
	psc.ProductSubcategoryID SubcategoryID,
	psc.Name SubCategoryName,
	pc.ProductCategoryID CategoryID,
	pc.Name CategoryName,
	COUNT(DISTINCT d.SalesOrderID) TotalOrders,
	SUM(d.LineTotal) TotalRevenue,
	SUM(d.OrderQty) TotalUnitsSold,
	SUM(d.OrderQty * p.StandardCost) TotalCost
FROM Sales.SalesOrderDetail d
JOIN Production.Product p
	ON d.ProductID = p.ProductID
JOIN Production.ProductSubcategory psc
	ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc
	ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY p.ProductID, p.Name, psc.ProductSubcategoryID, psc.Name, pc.ProductCategoryID, pc.Name
)
SELECT
	ProductID,
	ProductName,
	SubcategoryID,
	SubCategoryName,
	CategoryID,
	CategoryName,
	TotalOrders,
	TotalUnitsSold,
	ROUND(TotalRevenue, 2) TotalRevenue,
	ROUND(TotalCost, 2) TotalCost,
	ROUND(TotalRevenue - TotalCost, 2) TotalProfit,
	ROUND((TotalRevenue - TotalCost) * 100.0 / TotalRevenue, 2) ProfitMargin
FROM CTE_ProductDetails
ORDER BY TotalProfit DESC;
-- Insight: Mountain-200 Black, 38 is the top product by revenue ($4.40M).
-- Mountain-200 Black, 42 is the top product by profit ($674K).
-- Product (Road-250 Red, 58) generates nearly twice the revenue of Product (Touring-1000 Blue, 54) , 
-- yet Product (Touring-1000 Blue, 54) generates higher total profit, demonstrating that revenue alone does not indicate product profitability.

-- Negative Profit Products Performance
WITH CTE_ProductDetails AS
(
SELECT
	p.ProductID,
	p.Name ProductName,
	psc.ProductSubcategoryID SubcategoryID,
	psc.Name SubCategoryName,
	pc.ProductCategoryID CategoryID,
	pc.Name CategoryName,
	COUNT(DISTINCT d.SalesOrderID) TotalOrders,
	SUM(d.LineTotal) TotalRevenue,
	SUM(d.OrderQty) TotalUnitsSold,
	SUM(d.OrderQty * p.StandardCost) TotalCost
FROM Sales.SalesOrderDetail d
JOIN Production.Product p
	ON d.ProductID = p.ProductID
JOIN Production.ProductSubcategory psc
	ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc
	ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY p.ProductID, p.Name, psc.ProductSubcategoryID, psc.Name, pc.ProductCategoryID, pc.Name
),
CTE_ProductProfitability AS
(
SELECT
	ProductID,
	ProductName,
	SubcategoryID,
	SubCategoryName,
	CategoryID,
	CategoryName,
	TotalOrders,
	TotalUnitsSold,
	ROUND(TotalRevenue, 2) TotalRevenue,
	ROUND(TotalCost, 2) TotalCost,
	ROUND(TotalRevenue - TotalCost, 2) TotalProfit,
	ROUND((TotalRevenue - TotalCost) * 100.0 / TotalRevenue, 2) ProfitMargin
FROM CTE_ProductDetails
)
SELECT
	(SELECT COUNT(1) FROM CTE_ProductProfitability WHERE TotalProfit < 0) NegativeProfit,
	(SELECT COUNT(1) FROM CTE_ProductProfitability WHERE TotalProfit = 0) ZeroProfit,
	(SELECT COUNT(1) FROM CTE_ProductProfitability WHERE TotalProfit > 0) PositiveProfit,
	SUM(CASE WHEN TotalProfit < 0 THEN TotalRevenue END) NegProfitTotalRevenue,
	SUM(CASE WHEN TotalProfit < 0 THEN TotalProfit END) NegProfitTotalLoss,
	ROUND(SUM(CASE WHEN TotalProfit < 0 THEN TotalRevenue END) * 100.0/ SUM(TotalRevenue), 2)  NegProfitTotalRevenueOverTotalRevenue
FROM CTE_ProductProfitability;
