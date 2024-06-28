--q1--

create TABLE [Production].[log](
	[ProductID] [int]  NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ProductNumber] [nvarchar](25) NOT NULL,
	[MakeFlag] [dbo].[Flag] NOT NULL,
	[FinishedGoodsFlag] [dbo].[Flag] NOT NULL,
	[Color] [nvarchar](15) NULL,
	[SafetyStockLevel] [smallint] NOT NULL,
	[ReorderPoint] [smallint] NOT NULL,
	[StandardCost] [money] NOT NULL,
	[ListPrice] [money] NOT NULL,
	[Size] [nvarchar](5) NULL,
	[SizeUnitMeasureCode] [nchar](3) NULL,
	[WeightUnitMeasureCode] [nchar](3) NULL,
	[Weight] [decimal](8, 2) NULL,
	[DaysToManufacture] [int] NOT NULL,
	[ProductLine] [nchar](2) NULL,
	[Class] [nchar](2) NULL,
	[Style] [nchar](2) NULL,
	[ProductSubcategoryID] [int] NULL,
	[ProductModelID] [int] NULL,
	[SellStartDate] [datetime] NOT NULL,
	[SellEndDate] [datetime] NULL,
	[DiscontinuedDate] [datetime] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[change] [varchar](50) null,
	)


alter TRIGGER [Production].trig11
ON [Production].[Product]
instead of INSERT
AS
begin
if exists (select * from inserted)
begin 
insert into [Log] select * ,'insert' from inserted
end
end

alter TRIGGER [Production].trig12
ON [Production].[Product]
instead of delete
AS
begin
if exists (select * from deleted)
begin 
insert into [Log] select * ,'deleted' from deleted
end
end

alter TRIGGER [Production].trig13
ON [Production].[Product]
instead of update
AS
begin
if exists (select * from deleted)
begin 
insert into [Log] select * ,'updated' from deleted
end
end




delete from  Production.Product
where  Production.Product.Name =  N'CityBike'


INSERT INTO Production.Product
(
 Name, ProductNumber, MakeFlag, FinishedGoodsFlag, SafetyStockLevel,
 ReorderPoint, StandardCost, ListPrice, DaysToManufacture,
 SellStartDate, RowGUID, ModifiedDate
)
VALUES
(
 N'CityBike1', N'CB-238', 0, 0, 1000, 750, 0.0000, 0.0000, 0,
 GETDATE(), NEWID(), GETDATE()
);

update Production.Product
set Production.Product.name =  N'CioyBike'
where  Production.Product.name =  N'CityBike'

select *
from Production.[log];

--q2--
create TABLE [Production].[log2](
	[ProductID] [int]  NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ProductNumber] [nvarchar](25) NOT NULL,
	[MakeFlag] [dbo].[Flag] NOT NULL,
	[FinishedGoodsFlag] [dbo].[Flag] NOT NULL,
	[Color] [nvarchar](15) NULL,
	[SafetyStockLevel] [smallint] NOT NULL,
	[ReorderPoint] [smallint] NOT NULL,
	[StandardCost] [money] NOT NULL,
	[ListPrice] [money] NOT NULL,
	[Size] [nvarchar](5) NULL,
	[SizeUnitMeasureCode] [nchar](3) NULL,
	[WeightUnitMeasureCode] [nchar](3) NULL,
	[Weight] [decimal](8, 2) NULL,
	[DaysToManufacture] [int] NOT NULL,
	[ProductLine] [nchar](2) NULL,
	[Class] [nchar](2) NULL,
	[Style] [nchar](2) NULL,
	[ProductSubcategoryID] [int] NULL,
	[ProductModelID] [int] NULL,
	[SellStartDate] [datetime] NOT NULL,
	[SellEndDate] [datetime] NULL,
	[DiscontinuedDate] [datetime] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[change] [varchar](50) null,
	)

insert into production.[log2] select * from Production.[log];

update production.[log2]
set production.[log2].name =  N'CioyBike'
where  production.[log2].name =  N'CityBike'

select *
from Production.[log2];

--q3--
go
create PROCEDURE pro2
AS
select * INTO Production.[diffs] 
from(
SELECT * from Production.[log]
except
SELECT * from Production.[log2]
) AS diff
GO

execute pro2;

select * from Production.[diffs]