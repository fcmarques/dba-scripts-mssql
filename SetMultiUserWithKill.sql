USE master;
GO
DECLARE @sql AS VARCHAR(20), @spid AS INT;
SELECT @spid = MIN(spid)
  FROM
       master..sysprocesses
 WHERE dbid = DB_ID('sicc')
       AND spid != @@spid;
WHILE(@spid IS NOT NULL)
    BEGIN
        PRINT 'Killing process '+CAST(@spid AS VARCHAR)+' ...';
        SET @sql = 'kill '+CAST(@spid AS VARCHAR);
        EXEC (@sql);
        SELECT @spid = MIN(spid)
          FROM
               master..sysprocesses
         WHERE dbid = DB_ID('sicc')
               AND spid != @@spid;
    END;
ALTER DATABASE [sicc] SET MULTI_USER WITH NO_WAIT;