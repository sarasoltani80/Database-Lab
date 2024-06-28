-- Create login with all permissions
USE [master]
GO
CREATE LOGIN [login_mrmim] WITH PASSWORD=N'admin123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

-- Grant server-wide permissions
ALTER SERVER ROLE [sysadmin] ADD MEMBER [login_mrmim];
GO


USE [carwash]
GO
CREATE USER [user_mrmim] FOR LOGIN [login_mrmim]
GO

-- Grant database-level permissions
USE [carwash];
ALTER ROLE [db_datareader] ADD MEMBER [user_mrmim];
GO
ALTER ROLE db_owner ADD MEMBER [user_mrmim];
GO
ALTER ROLE [db_datareader] ADD MEMBER [user_mrmim];
GO
ALTER ROLE [db_datareader] ADD MEMBER [user_mrmim];
GO

