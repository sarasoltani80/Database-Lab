--q1--shared & exclucive deadlocks
--1--
select *
from Sales.SalesOrderHeaderSalesReason
where Sales.SalesOrderHeaderSalesReason.SalesReasonID  = 5

---2---
BEGIN TRANSACTION
update  Sales.SalesOrderHeaderSalesReason 
set Sales.SalesOrderHeaderSalesReason.SalesReasonID  = 6
where Sales.SalesOrderHeaderSalesReason .SalesReasonID = 5
waitfor delay '00:00:10'
ROLLBACK

update  HumanResources.Employee 
set HumanResources.Employee .Gender  = 'M'
where  HumanResources.Employee.BusinessEntityID  = 1


select *
from  HumanResources.Employee 
where HumanResources.Employee .BusinessEntityID  = 1




--q2--dirty reads---
--1--
BEGIN TRANSACTION
update Person.ContactType
set Name = 'Manager'
where Name = 'Owner'
go
waitfor delay '00:00:10'
ROLLBACK
select * from Person.ContactType

--2--
select * from Person.ContactType
where Name = 'Manager'

--q2--Non repeatable Read---
--1--
BEGIN TRANSACTION
select * from Person.ContactType
where Name = 'Sales Agent'

go
waitfor delay '00:00:05'

select * from Person.ContactType
where Name = 'Sales Agent'

commit

--2--
BEGIN TRANSACTION
update Person.ContactType
set Name = 'Secondary Sales Agent'
where Name = 'Sales Agent'
commit
select * from Person.ContactType;

