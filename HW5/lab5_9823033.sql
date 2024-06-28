--q1--
select  Name,Europe,[North America],Pacific
from 
(
select p.Name,[Group],OrderQty
from Sales.SalesOrderDetail as d
inner join  Sales.SalesOrderHeader as h
on d.SalesOrderID = h.SalesOrderID
inner join Sales.SalesTerritory as t
on h.TerritoryID = t.TerritoryID
inner join Production.Product as p
on d.ProductID = p.ProductID
)as srcTable
pivot(
count(OrderQty)
for [Group] in (Europe,[North America],Pacific)
)as pvt


--q2--

select PersonType,M,F
from 
(
select Person.BusinessEntityID, PersonType, Gender
from Person.Person join HumanResources.Employee
on
(
Person.BusinessEntityID =Employee.BusinessEntityID)
)as srcTable
pivot(
count(BusinessEntityID)
for Gender  in (F,M)
)as pvt

--q3--
select p.Name
from Production.Product AS p
where LEN(p.Name) < 15 and PATINDEX('%e_',p.Name) =LEN(p.Name) - 1;

--q4--
IF OBJECT_ID (N'dbo.checkDate', N'FN') IS NOT NULL
DROP FUNCTION dbo.checkDate;
GO
CREATE FUNCTION dbo.checkDate(@dateformat nvarchar(10))
RETURNS nvarchar(120)
AS
BEGIN
DECLARE @ans smallint;
DECLARE @day nvarchar(2);
DECLARE @month nvarchar(2);
DECLARE @persion_month nvarchar(20);
DECLARE @year nvarchar(4);
select @day = SUBSTRING(@dateformat,9,10)
select @month = SUBSTRING(@dateformat,6,7)
select @year = SUBSTRING(@dateformat,1,4)
SELECT  @ans =  CASE
WHEN @dateformat LIKE '[1-9][0-9][0-9][0-9]/[0-1][0-9]/[0-3][0-9]'
and @day <32 
and @month<13
and @day > 0
and @month > 0
and @year > 0
  THEN 1
  ELSE 0
  END;
if (@ans=1)
BEGIN
if (@month ='01')
	set @persion_month = N'فروردین '
else if(@month ='02')	 
	set @persion_month = N'اردیبهشت'
else if(@month ='03')	 
	set @persion_month = N'خرداد'
else if(@month ='04')	 
	set @persion_month = N'تیر '
else if(@month ='05')	 
	set @persion_month = N'مرداد '
else if(@month ='06')	 
	set @persion_month = N'شهریور'
else if(@month ='07')	 
	set @persion_month = N'مهر'
else if(@month ='08')	 
	set @persion_month = N'آبان '
else if(@month ='09')	 
	set @persion_month = N'آذر '
else if(@month ='10')	 
	set @persion_month = N'دی '
else if(@month ='11')	 
	set @persion_month = N'بهمن '
else if(@month ='12')	 
	set @persion_month = N'اسفند '

return N'شمسی '+@year+N'ماه '+@persion_month+@day;
END
ELSE
return N'فرمت تاریخ ناصحیح است';
return '';
END;
GO
--select dbo.checkDate('1390/12/31');
--select dbo.checkDate('1320/12/1sd1');
--select dbo.checkDate('13901231');
select dbo.checkDate('13sdf90/1sdf2/31');
--select dbo.checkDate('1390/14/54');
--select dbo.checkDate('1400/03/13');

--q5--
IF OBJECT_ID (N'find_sales_places', N'IF') IS NOT NULL
DROP FUNCTION find_sales_places;
GO
CREATE FUNCTION find_sales_places (@entered_year int,@entered_month int,@product_name varchar(60))
RETURNS TABLE
AS
RETURN
(
select distinct t.[Group]
from Production.Product as p
inner join Sales.SalesOrderDetail as d on (p.ProductID = d.ProductID)
inner join Sales.SalesOrderHeader as h on (d.SalesOrderID = h.SalesOrderID)
inner join Sales.SalesTerritory as t on (t.TerritoryID = h.TerritoryID)
where p.Name = @product_name and month(h.orderDate) =@entered_month and year(h.orderDate) = @entered_year
);
GO

select * from find_sales_places(2005,8,'Sport-100 Helmet, Red');