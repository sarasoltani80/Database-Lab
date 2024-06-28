--q1--
USE AdventureWorks2012
GO
SELECT Sales.SalesOrderHeader.OrderDate, Sales.SalesOrderDetail.LineTotal,
AVG(Sales.SalesOrderDetail.LineTotal)OVER (PARTITION BY Sales.SalesOrderHeader.CustomerID
ORDER BY Sales.SalesOrderHeader.OrderDate, Sales.SalesOrderHeader.SalesOrderID
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail ON
(SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID)
--baraye har moshtari avg 3 sefaresh akhaarsh ra migirad

--q2--
select 
CASE GROUPING(t.name)
WHEN 0 THEN t.name
WHEN 1 THEN'All Terrirories'
END AS TerritoryName,
CASE GROUPING(t.[Group])
WHEN 0 THEN t.[Group]
WHEN 1 THEN'All Regions'
END AS Region, sum(so.SubTotal) as sum_total,count(so.SalesOrderID) as order_count
from Sales.SalesTerritory as t inner join Sales.SalesOrderHeader as so on t.TerritoryID = so.TerritoryID
group by rollup(t.[group], t.name);

--q3--
select 
CASE GROUPING(c.Name)
WHEN 0 THEN c.Name
WHEN 1 THEN'All Categories'
end AS Category,
CASE GROUPING(sc.Name)
WHEN 0 THEN sc.Name
WHEN 1 THEN 
	(CASE GROUPING(c.Name)
	WHEN 0 THEN c.Name
	WHEN 1 THEN'All Subcategories'
	end)
END AS Subcategory,
sum(sod.LineTotal) as sum_total,count(sod.SalesOrderID) as order_count
from (Production.ProductCategory as c inner join Production.ProductSubcategory as sc on c.ProductCategoryID = sc.ProductCategoryID) inner join 
(Production.Product as p inner join  Sales.SalesOrderDetail as sod on p.ProductID = sod.ProductID) on p.ProductSubcategoryID = sc.ProductSubcategoryID
group by rollup( c.Name, sc.Name)
---------------------------------------------
--q4--
with c as
(
select  e.JobTitle as jt, count(e.BusinessEntityID) as ccount 
from HumanResources.Employee as e
group by e.JobTitle
)

select e.NationalIDNumber as national_id, e.Gender as gender, e.MaritalStatus as marital_status, e.JobTitle as job_title, c.ccount
from HumanResources.Employee as e inner join c on e.JobTitle = c.jt
where c.ccount>3;

