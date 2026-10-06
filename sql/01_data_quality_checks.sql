-- =====================================================
-- AdventureWorks 2025 | E-Commerce Sales & Customer Analytics
-- File 1 of 3: Data Exploration & Quality Checks
-- Tool: SQL Server (T-SQL)
-- Row counts, duplicates, nulls, valid ranges and referential integrity checks
-- =====================================================

-- =====================================================
-- DATA EXPLORATION & QUALITY CHECKS
-- =====================================================

-- Number Of Rows

SELECT 
	COUNT(*) TotalRows
FROM Sales.Customer;

SELECT 
	COUNT(*) TotalRows
FROM Sales.SalesOrderHeader;

SELECT 
	COUNT(*) TotalRows
FROM Sales.SalesOrderDetail;

SELECT 
	COUNT(*) TotalRows
FROM Sales.SalesTerritory;

SELECT 
	COUNT(*) TotalRows
FROM Sales.SpecialOffer;

SELECT 
	COUNT(*) TotalRows
FROM Production.Product;

SELECT 
	COUNT(*) TotalRows
FROM Production.ProductSubcategory;

SELECT 
	COUNT(*) TotalRows
FROM Production.ProductCategory;

-- Duplicates

SELECT
	CustomerID,
	COUNT(*) DuplicatesCount
FROM Sales.Customer
GROUP BY CustomerID
HAVING COUNT(*) > 1;

SELECT
	SalesOrderID,
	COUNT(*) DuplicatesCount
FROM Sales.SalesOrderHeader
GROUP BY SalesOrderID
HAVING COUNT(*) > 1;

SELECT
	SalesOrderDetailID,
	COUNT(*) DuplicatesCount
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderDetailID
HAVING COUNT(*) > 1;

SELECT
	TerritoryID,
	COUNT(*) DuplicatesCount
FROM Sales.SalesTerritory
GROUP BY TerritoryID
HAVING COUNT(*) > 1;

SELECT
	SpecialOfferID,
	COUNT(*) DuplicatesCount
FROM Sales.SpecialOffer
GROUP BY SpecialOfferID
HAVING COUNT(*) > 1;

SELECT
	ProductID,
	COUNT(*) DuplicatesCount
FROM Production.Product
GROUP BY ProductID
HAVING COUNT(*) > 1;

SELECT
	ProductCategoryID,
	COUNT(*) DuplicatesCount
FROM Production.ProductCategory
GROUP BY ProductCategoryID
HAVING COUNT(*) > 1;

SELECT
	ProductSubcategoryID,
	COUNT(*) DuplicatesCount
FROM Production.ProductSubcategory
GROUP BY ProductSubcategoryID
HAVING COUNT(*) > 1;

-- Nulls

SELECT 
	COUNT(*) TotalRows,
	COUNT(SalesOrderID) OrderID,
	COUNT(CustomerID) CustomerID,
	COUNT(TerritoryID) TerritoryID,
	COUNT(OrderDate) OrderDate
FROM Sales.SalesOrderHeader;

SELECT 
	COUNT(*) TotalRows,
	COUNT(SalesOrderID) OrderID,
	COUNT(SalesOrderDetailID) DetailID,
	COUNT(OrderQty) Quantity,
	COUNT(ProductID) ProductID,
	COUNT(UnitPrice) UnitPrice,
	COUNT(SpecialOfferID) SpecialOfferID
FROM Sales.SalesOrderDetail;

SELECT
	COUNT(*) TotalRows,
	COUNT(ProductID) ProductID,
	COUNT(StandardCost) StandardCost,
	COUNT(ListPrice) ListPrice,
	COUNT(ProductSubcategoryID) SubCategoryID
FROM Production.Product;
-- Data Quality Finding:
-- 209 products have no assigned ProductSubcategoryID.
-- None of these products appear in SalesOrderDetail,
-- therefore they are not relevant to the sales analysis.

-- Data Validity/Ranges

SELECT
	MIN(OrderDate) FirstOrderDate,
	MAX(OrderDate) LastOrderDate
FROM Sales.SalesOrderHeader;

SELECT
	MIN(UnitPriceDiscount) MinDiscount,
	MAX(UnitPriceDiscount) MaxDiscount
FROM Sales.SalesOrderDetail;

SELECT
	*
FROM Sales.SalesOrderDetail
WHERE OrderQty <= 0
OR UnitPrice <=0;

-- referential integrity
SELECT
	s.CustomerID
FROM Sales.SalesOrderHeader s
LEFT JOIN Sales.Customer c
	ON s.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

SELECT
	s.TerritoryID
FROM Sales.SalesOrderHeader s
LEFT JOIN Sales.SalesTerritory t
	ON s.TerritoryID = t.TerritoryID
WHERE t.TerritoryID IS NULL;

SELECT
	s.ProductID
FROM Sales.SalesOrderDetail s
LEFT JOIN Production.Product p
	ON s.ProductID = p.ProductID
WHERE p.ProductID IS NULL;

SELECT
	s.SpecialOfferID
FROM Sales.SalesOrderDetail s
LEFT JOIN Sales.SpecialOffer o
	ON s.SpecialOfferID = o.SpecialOfferID
WHERE o.SpecialOfferID IS NULL;

SELECT
	sd.SalesOrderID
FROM Sales.SalesOrderDetail sd
LEFT JOIN Sales.SalesOrderHeader sh
	ON sd.SalesOrderID = sh.SalesOrderID
WHERE sh.SalesOrderID IS NULL;

SELECT
	p.ProductSubcategoryID
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory ps
	ON p.ProductSubcategoryID = ps.ProductSubCategoryID
WHERE ps.ProductSubcategoryID IS NULL;

SELECT
	ps.ProductCategoryID
FROM Production.ProductSubcategory ps
LEFT JOIN Production.ProductCategory p
	ON ps.ProductCategoryID = p.ProductCategoryID
WHERE p.ProductCategoryID IS NULL;

SELECT
	c.TerritoryID
FROM Sales.Customer c
LEFT JOIN Sales.SalesTerritory t
	ON c.TerritoryID = t.TerritoryID
WHERE t.TerritoryID IS NULL;

