USE [master]
GO
CREATE LOGIN [login_] WITH PASSWORD=N'1234', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

________________________
USE [master]

GO

CREATE SERVER ROLE [role1] AUTHORIZATION [login_]

GO

ALTER SERVER ROLE [dbcreator] ADD MEMBER [role1]

GO

_________________________

USE [AdventureWorks2012]
GO
CREATE USER [user_] FOR LOGIN [login_]
GO

__________________________

USE [AdventureWorks2012]
GO
ALTER ROLE [db_datareader] ADD MEMBER [user_]
GO
USE [AdventureWorks2012]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [user_]
GO
USE [AdventureWorks2012]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [user_]
GO
USE [AdventureWorks2012]
GO
ALTER ROLE [db_owner] ADD MEMBER [user_]
GO

___________________________

CREATE TABLE table_name 
(    
	new_column int,
);
INSERT INTO table_name (new_column) VALUES(1)
INSERT INTO table_name (new_column) VALUES(2)
INSERT INTO table_name (new_column) VALUES(3)

SELECT * FROM table_name


____________________________

USE [master]

GO

CREATE SERVER ROLE [role2] AUTHORIZATION [login_]

GO

ALTER SERVER ROLE [securityadmin] ADD MEMBER [role2]

GO




