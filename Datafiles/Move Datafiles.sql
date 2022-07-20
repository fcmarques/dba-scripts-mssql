<<<<<<< HEAD
USE master;
GO
-- Return the logical file name.
SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'NetshoesDBA')
    AND type_desc = N'LOG';
GO

ALTER DATABASE NetshoesDBA SET OFFLINE WITH ROLLBACK IMMEDIATE;
GO

-- Physically move the file to a new location.
-- In the following statement, modify the path specified in FILENAME to
-- the new location of the file on your server.
ALTER DATABASE NetshoesDBA 
    MODIFY FILE ( NAME = NetshoesDBA_log, 
                  FILENAME = 'U:\LOGS\NetshoesDBA_log.ldf');
GO

ALTER DATABASE NetshoesDBA SET ONLINE;
GO

--Verify the new location.
SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'NetshoesDBA')
=======
USE master;
GO
-- Return the logical file name.
SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'NetshoesDBA')
    AND type_desc = N'LOG';
GO

ALTER DATABASE NetshoesDBA SET OFFLINE WITH ROLLBACK IMMEDIATE;
GO

-- Physically move the file to a new location.
-- In the following statement, modify the path specified in FILENAME to
-- the new location of the file on your server.
ALTER DATABASE NetshoesDBA 
    MODIFY FILE ( NAME = NetshoesDBA_log, 
                  FILENAME = 'U:\LOGS\NetshoesDBA_log.ldf');
GO

ALTER DATABASE NetshoesDBA SET ONLINE;
GO

--Verify the new location.
SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'NetshoesDBA')
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
    AND type_desc = N'LOG';