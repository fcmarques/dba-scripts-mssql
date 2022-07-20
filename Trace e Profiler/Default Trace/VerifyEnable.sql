-- How do we know that the default trace is running?
SELECT* FROM sys.configurations WHERE configuration_id = 1568

--If it is not enabled, how do we enable it?
sp_configure 'show advanced options', 1;
GO
RECONFIGURE; 
GO
sp_configure 'default trace enabled', 1;
GO
RECONFIGURE;
GO