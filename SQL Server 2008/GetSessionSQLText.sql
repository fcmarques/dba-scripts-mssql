--------------------------------------------------------------------------------------------------
--
-- Script Name: GetSessionSQLText.sql
--
-- Author: David B. Kranes
--
-- Description: This script will return each spid and it's corresponding SQL text. Supply 
-- desired SPID or ALL non-system SPID's will be returned.
--
-- Parameters:
-- 1) @desSPID - Limits results to just this SPID. Set below in the script.
--
-- Revision History"
-- 1) 1/26/2012 - [DBK] - Created.
--
--------------------------------------------------------------------------------------------------

SET NOCOUNT ON
GO

IF OBJECT_ID('tempdb..#curSQL') IS NOT NULL
 DROP TABLE #curSQL
GO

CREATE TABLE #curSQL
(spID SMALLINT,
blocked VARCHAR(3),
hostName VARCHAR(2000),
dbName VARCHAR(100),
cmd VARCHAR(100),
sqlText NTEXT,
phyIO BIGINT,
Status VARCHAR(100),
programName VARCHAR(1000),
loginTime DATETIME,
lastBatch DATETIME
)

DECLARE @spID smallint,
        @Blocked VARCHAR(3),
        @sqltext VARBINARY(128),
        @physIO BIGINT,
        @hostName VARCHAR(2000),
        @desSPID SMALLINT,
        @dbName VARCHAR(100),
        @Cmd VARCHAR(100),
        @status VARCHAR(100),
        @programName VARCHAR(1000),
        @loginTime DATETIME,
        @lastBatch DATETIME
        

-- Set desired SPID. If NULL, it will return all non-system SPID's.
--SET @desSPID = <Put desired SPID her to filter>


BEGIN TRY
    IF @desSPID IS NOT NULL
        DECLARE spID_cursor CURSOR
        FORWARD_ONLY READ_ONLY
        FOR SELECT spid, CASE blocked WHEN 0 THEN 'NO' ELSE 'YES' END blocked, hostname, db_name(dbid), cmd, physical_io, status, program_name, login_time, last_batch
            FROM sys.sysprocesses 
            WHERE spid = @desSPID
            GROUP BY spid, blocked, physical_io, hostname, db_name(dbid), cmd, physical_io, status, program_name, login_time, last_batch
            ORDER BY spid

    ELSE
        DECLARE spID_cursor CURSOR
        FORWARD_ONLY READ_ONLY
        FOR SELECT spid, CASE blocked WHEN 0 THEN 'NO' ELSE 'YES' END blocked, hostname, db_name(dbid), cmd, physical_io, status, program_name, login_time, last_batch
            FROM sys.sysprocesses 
            WHERE spid > 50
            GROUP BY spid, blocked, physical_io, hostname, db_name(dbid), cmd, physical_io, status, program_name, login_time, last_batch
            ORDER BY spid
        OPEN spID_cursor

        FETCH NEXT
        FROM spID_cursor
        INTO @spID, @Blocked, @hostName, @dbName, @cmd, @physIO, @status, @programName, @loginTime, @lastBatch

        WHILE @@FETCH_STATUS = 0
        BEGIN

         SELECT @sqltext = sql_handle
         FROM sys.sysprocesses
         WHERE spid = @spID

         INSERT INTO #curSQL
         SELECT @spID, @Blocked, @hostName, @dbName, @cmd, TEXT, @physIO, @status, @programName, @loginTime, @lastBatch
         FROM ::fn_get_sql(@sqltext)
         
         FETCH NEXT
         FROM spID_cursor
         INTO @spID, @Blocked, @hostName, @dbName, @cmd, @physIO, @status, @programName, @loginTime, @lastBatch
         
         END
         
         CLOSE spID_cursor
         DEALLOCATE spID_cursor
     
    SELECT * FROM #curSQL ORDER BY blocked asc, spid
END TRY

BEGIN CATCH
    CLOSE spID_cursor
    DEALLOCATE spID_cursor
    
    SELECT ERROR_NUMBER() ErrorNBR, ERROR_SEVERITY() Severity, ERROR_LINE() ErrorLine, ERROR_MESSAGE() Msg
    
    PRINT 'There was an error in the script.'
    
END CATCH    

