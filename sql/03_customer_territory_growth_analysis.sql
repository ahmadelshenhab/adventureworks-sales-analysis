-- =====================================================
-- AdventureWorks 2025 | E-Commerce Sales & Customer Analytics
-- File 3 of 3: Customer, Territory, Discount & Growth Analysis
-- Tool: SQL Server (T-SQL)
-- Top customers, purchase behavior, regional performance, discount impact and month-over-month growth
-- =====================================================

-- Customer Performance
WITH CTE_CustomerDetails AS
(
SELECT 
	 c.CustomerID,
	 COUNT(DISTINCT d.SalesOrderID) TotalOrders,
	 SUM(d.OrderQty) TotalUnitsSold,
	 SUM(d.LineTotal) TotalRevenue,
	 SUM(d.OrderQty * P.StandardCost) TotalCost
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h
	ON d.SalesOrderID = h.SalesOrderID
JOIN Sales.Customer c
	ON h.CustomerID = c.CustomerID
JOIN Production.Product p
	ON d.ProductID = p.ProductID
GROUP BY c.CustomerID
)
SELECT
	CustomerID,
	TotalOrders,
	TotalUnitsSold,
	ROUND(TotalRevenue, 2) TotalRevenue,
	ROUND(TotalCost, 2) TotalCost,
	ROUND(TotalRevenue - TotalCost, 2) TotalProfit,
	ROUND((TotalRevenue - TotalCost) * 100.0 / TotalRevenue, 2) ProfitMargin 
FROM CTE_CustomerDetails
ORDER BY TotalRevenue DESC;

-- Customer Rank
WITH CTE_CustomerDetails AS
(
SELECT
	c.CustomerID,
	SUM(d.LineTotal) TotalRevenue,
	SUM(d.OrderQty * p.StandardCost) TotalCost
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h
	ON d.SalesOrderID = h.SalesOrderID
JOIN Sales.Customer c
	ON h.CustomerID = c.CustomerID
JOIN Production.Product p
	ON d.ProductID = p.ProductID
GROUP BY c.CustomerID
),
CTE_CustomerRank AS
(
SELECT
	CustomerID,
	ROUND(TotalRevenue, 2) TotalRevenue,
	ROUND(TotalRevenue - TotalCost, 2) TotalProfit,
	ROUND((TotalRevenue - TotalCost) * 100.0 / TotalRevenue, 2) ProfitMargin,
	DENSE_RANK() OVER(ORDER BY TotalRevenue DESC) RevenueRank,
	TotalRevenue * 100.0/ (SELECT SUM(TotalRevenue) FROM CTE_CustomerDetails) PercentageOfTotalRevenue
FROM CTE_CustomerDetails
)
SELECT
	CustomerID,
	TotalRevenue,
	TotalProfit,
	ProfitMargin,
	RevenueRank,
	PercentageOfTotalRevenue,
	SUM(PercentageOfTotalRevenue) OVER(ORDER BY TotalRevenue DESC) CumPercentage
FROM CTE_CustomerRank
WHERE RevenueRank <= 10;
-- Insight: The top 10 customers account for only 7.2% of total revenue,
-- so the business does not depend on a few large accounts.

-- Customer Purchase Behavior
WITH CTE_OrderDetails AS
(
SELECT
	d.SalesOrderID,
	SUM(d.OrderQty) UnitsSold,
	SUM(d.LineTotal) OrderValue,
	SUM(d.OrderQty * p.StandardCost) OrderCost
FROM Sales.SalesOrderDetail d
JOIN Production.Product p
	ON d.ProductID = p.ProductID
GROUP BY d.SalesOrderID
),
CTE_CustomerPerformance AS
(
SELECT
	h.CustomerID,
	COUNT(cod.SalesOrderID) TotalOrders,
	SUM(cod.UnitsSold) TotalUnitsSold,
	SUM(cod.OrderValue) TotalRevenue,
	AVG(cod.OrderValue) AvgOrderValue,
	SUM(cod.OrderValue - cod.OrderCost) TotalProfit,
	ROW_NUMBER() OVER(ORDER BY COUNT(cod.SalesOrderID) DESC) CustomerRank
FROM CTE_OrderDetails cod
JOIN Sales.SalesOrderHeader h
	ON cod.SalesOrderID = h.SalesOrderID
GROUP BY h.CustomerID
)
SELECT
	CustomerID,
	TotalOrders,
	TotalUnitsSold,
	TotalRevenue,
	AvgOrderValue,
	TotalProfit,
	CustomerRank
FROM CTE_CustomerPerformance
WHERE CustomerRank <= 10;

-- Territory Performance
WITH CTE_TerritoryDetails AS
(
SELECT
	t.TerritoryID,
	COUNT(DISTINCT d.SalesOrderID) TotalOrders,
	SUM(d.OrderQty) TotalUnitsSold,
	SUM(d.LineTotal) TotalRevenue,
	SUM(d.OrderQty * p.StandardCost) TotalCost
FROM Sales.SalesTerritory t
JOIN Sales.SalesOrderHeader h
	ON t.TerritoryID = h.TerritoryID
JOIN Sales.SalesOrderDetail d
	ON d.SalesOrderID = h.SalesOrderID
JOIN Production.Product p
	ON d.ProductID = p.ProductID
GROUP BY t.TerritoryID
)
SELECT
	TerritoryID,
	TotalOrders,
	TotalUnitsSold,
	TotalRevenue,
	TotalCost,
	TotalRevenue - TotalCost TotalProfit,
	(TotalRevenue - TotalCost) * 100.0 / TotalRevenue ProfitMargin
FROM CTE_TerritoryDetails
ORDER BY TotalRevenue DESC;
-- Insight: Territory 4 (Southwest) has the highest revenue ($24.18M), but Territory 9 (Australia)
-- has the highest profit ($3.43M). The biggest market is not the most profitable one.

-- Territory Trends
WITH CTE_TerritoryPerformance AS
(
SELECT
	t.TerritoryID,
	DATEFROMPARTS(YEAR(h.OrderDate), MONTH(h.OrderDate), 1) Month,
	COUNT(DISTINCT d.SalesOrderID) TotalOrders,
	SUM(d.OrderQty) TotalUnitsSold,
	SUM(d.LineTotal) TotalRevenue,
	SUM(d.OrderQty * p.StandardCost) TotalCost
FROM Sales.SalesTerritory t
JOIN Sales.SalesOrderHeader h
	ON t.TerritoryID = h.TerritoryID
JOIN Sales.SalesOrderDetail d
	ON d.SalesOrderID = h.SalesOrderID
JOIN Production.Product p
	ON p.ProductID = d.ProductID
GROUP BY t.TerritoryID, DATEFROMPARTS(YEAR(h.OrderDate), MONTH(h.OrderDate), 1)
)
SELECT
	TerritoryID,
	Month,
	TotalOrders,
	TotalUnitsSold,
	TotalRevenue,
	TotalRevenue - TotalCost TotalProfit,
	(TotalRevenue - TotalCost) * 100.0 / TotalRevenue ProfitMargin
FROM CTE_TerritoryPerformance
ORDER BY TotalRevenue DESC;

-- Discount Performance
WITH CTE_DiscountDetails AS
(
SELECT
	s.SpecialOfferID,
	d.UnitPriceDiscount DiscountValue,
	COUNT(DISTINCT SalesOrderID) TotalOrders,
	SUM(d.OrderQty) TotalUnitsSold,
	SUM(d.LineTotal) TotalRevenue,
	SUM(d.OrderQty * p.StandardCost) TotalCost
FROM Sales.SpecialOffer s
JOIN Sales.SalesOrderDetail d
	ON s.SpecialOfferID = d.SpecialOfferID
JOIN Production.Product p
	ON p.ProductID = d.ProductID
GROUP BY s.SpecialOfferID, d.UnitPriceDiscount
)
SELECT
	SpecialOfferID,
	DiscountValue,
	TotalOrders,
	TotalUnitsSold,
	TotalRevenue,
	TotalRevenue - TotalCost TotalProfit,
	(TotalRevenue - TotalCost) * 100.0 / TotalRevenue ProfitMargin
FROM CTE_DiscountDetails
ORDER BY TotalRevenue DESC;
-- Insight: Full-price sales (SpecialOffer 1, no discount) earn $102.37M revenue and $10.42M profit,
-- more than the company's $9.37M total profit, so discounted sales combined lost about $1.05M.

-- Growth Over Time
WITH CTE_PerformanceOverTime AS
(
SELECT
	DATEFROMPARTS(YEAR(h.OrderDate), MONTH(h.OrderDate), 1) Month,
	SUM(d.LineTotal) TotalRevenue,
	SUM(d.OrderQty * p.StandardCost) TotalCost
FROM Sales.SalesOrderHeader h
JOIN Sales.SalesOrderDetail d
	ON h.SalesOrderID = d.SalesOrderID 
JOIN Production.Product p
	ON p.ProductID = d.ProductID
GROUP BY DATEFROMPARTS(YEAR(h.OrderDate), MONTH(h.OrderDate), 1)
),
CTE_BusinessGrowth AS
(
SELECT
	Month,
	TotalRevenue,
	LAG(TotalRevenue) OVER(ORDER BY Month) PreviousRevenue,
	TotalRevenue - TotalCost TotalProfit,
	LAG(TotalRevenue - TotalCost) OVER(ORDER BY Month) PreviousProfit
FROM CTE_PerformanceOverTime
)
SELECT
	Month,
	TotalRevenue,
	ROUND((TotalRevenue - PreviousRevenue) * 100.0 / PreviousRevenue, 2) RevenueGrowthPercentage,
	TotalProfit,
	ROUND((TotalProfit - PreviousProfit) * 100.0 / PreviousProfit, 2) ProfitGrowthPercentage
FROM CTE_BusinessGrowth
ORDER BY Month;
-- Insight: June 2022 has the highest month-over-month revenue growth percentage,
-- because the previous month's revenue was low.
