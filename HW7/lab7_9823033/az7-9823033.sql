--q1--
exec xp_cmdshell 'bcp AdventureWorks2012.Sales.SalesTerritory out "D:\dblab\db7\salesTerritory.txt" -T -c -t"|"';

bulk insert SalesTerritoryNew
from 'D:\dblab\db7\salesTerritory.txt'
with 
(
	fieldterminator = '|'
)

select * from SalesTerritoryNew;

--q2--
EXEC xp_cmdshell 'bcp "select Name, TerritoryID from [AdventureWorks2012].[sales].[SalesTerritory]"  queryout "D:\dblab\db7\OUTPUT_FILE.txt" -T -c -t,'

--select Name, TerritoryID 
--from AdventureWorks2012.sales.SalesTerritory

--q3--
select * from Production.Location;
exec xp_cmdshell 'bcp "AdventureWorks2012.Production.Location" out "D:\dblab\db7\location.dat" -T -c';

--q4--
--select name,  AnnualSales,  YearOpened from  [AdventureWorks2012].[Sales].[Store]

CREATE TABLE xmlTable2(
Name [nvarchar](250) NULL,
AnnualSales [xml] NULL,
YearOpened [xml] NULL,
NumberEmployees [xml] NULL
)

insert into xmlTable2 SELECT Name , Demographics.query('
declare default element namespace
"http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";
for $P in /StoreSurvey
return
<AnnualSales>
{ $P/AnnualSales }
</AnnualSales>
') as AnnualSales , Demographics.query('
declare default element namespace
"http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";
for $P in /StoreSurvey
return
<YearOpened>
{ $P/YearOpened }
</YearOpened>
') as YearOpened, Demographics.query('
declare default element namespace
"http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";
for $P in /StoreSurvey
return
<NumberEmployees>
{ $P/NumberEmployees }
</NumberEmployees>
') as NumberEmployees
FROM [AdventureWorks2012].[Sales].[Store]--;


EXEC xp_cmdshell 'bcp "AdventureWorks2012.dbo.xmlTable2 " out "D:\dblab\db7\OUTPUT_FILE3.txt" -T -c -q -t,'
