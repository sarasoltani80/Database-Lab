--q1--
select *
from [AdventureWorks2012].[Sales].[SalesTerritory] as t INNER JOIN [AdventureWorks2012].[Sales].[SalesOrderHeader] as soh
ON t.TerritoryID =  soh.TerritoryID 
WHERE ((t.[Name] = 'France') or (t.[Group] = 'North America')) and soh.TotalDue between 100000 and 500000 ;

--q2--
select soh.SalesOrderID, soh.CustomerID, soh.SubTotal, soh.OrderDate, t.[Name]
from [AdventureWorks2012].[Sales].[SalesTerritory] as t INNER JOIN [AdventureWorks2012].[Sales].[SalesOrderHeader] as soh
ON t.TerritoryID =  soh.TerritoryID ;

--q3--
WITH NA2
AS
((select *
from [AdventureWorks2012].[Sales].[SalesOrderHeader] as soh
where (soh.TotalDue between 100000 and 500000) and soh.TerritoryID in (
select t.TerritoryID
from [AdventureWorks2012].[Sales].[SalesTerritory] as t
where t."Group" = 'North America'))
) 

select * into NAmerica_Sales from NA2;

select * from NAmerica_Sales

alter table NAmerica_Sales
add newcolumn char(4) check (newcolumn in ('Low','Mid','High'));

WITH w1
AS
((select avg(n.TotalDue) as avgg
from NAmerica_Sales as n)) 


Update NAmerica_Sales 
set NAmerica_Sales.newcolumn = case
when NAmerica_Sales.TotalDue < w1.avgg then  'Low'
when NAmerica_Sales.TotalDue = w1.avgg then  'Mid'
when NAmerica_Sales.TotalDue > w1.avgg then  'High'
end
from NAmerica_Sales , w1;

--q4--

SELECT hr.BusinessEntityID ,max(Rate)
FROM  [AdventureWorks2012].[HumanResources].[EmployeePayHistory] AS hr
GROUP BY BusinessEntityID
ORDER BY BusinessEntityID

WITH c2
AS
(SELECT ep.BusinessEntityID, max(Rate) as max_rate ,NTILE (4) OVER (ORDER BY max(rate) asc) as temp2
from [AdventureWorks2012].[HumanResources].[EmployeePayHistory] AS ep
group by BusinessEntityID
)


select BusinessEntityID,
	CASE
		WHEN c2.temp2 = 1 THEN c2.max_rate *1.2
		WHEN c2.temp2 = 2 THEN c2.max_rate *1.15
		WHEN c2.temp2 = 3 THEN c2.max_rate *1.1
		WHEN c2.temp2 = 4 THEN c2.max_rate *1.05
	END as new_salary,
	CASE
		WHEN c2.max_rate < 29 THEN 3
		WHEN c2.max_rate >= 29 AND c2.max_rate < 50 THEN 2
		ELSE 1
	END as level
from c2
ORDER BY c2.BusinessEntityID





