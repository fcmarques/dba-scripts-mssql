PRINT '---------------------------------------'
PRINT '---- SQL_Perf_Stats_Infrequent.sql'
PRINT '----   $Revision: 1 $'
PRINT '----   $Date: 2003/10/16 13:27:05 $'
PRINT '---------------------------------------'
PRINT ''
PRINT 'Start Time: ' + CONVERT (varchar(30), GETDATE(), 121)
GO

-- This script will only work on SQL 2000 and SQL 2005 because the fn_virtualfilestats
-- and fn_get_sql functions are only available on SQL2K and later. 

-- Removed 2007/2/7 by bartd in response to issue reported by cdawid
-- DBCC CACHEPROFILE (5) -- start proc cache profiling
SET QUOTED_IDENTIFIER ON
GO
WHILE (1=1)
BEGIN
  PRINT ''
  PRINT 'Start time: ' + CONVERT (varchar (50), GETDATE(), 121)

 --Commenting this because there are the same data in PFELATAM Monitor by rsouza
--  PRINT 'DBCC SQLPERF (WAITSTATS)'
--  DBCC SQLPERF (WAITSTATS)
--  PRINT 'DBCC SQLPERF (SPINLOCKSTATS)'
--  DBCC SQLPERF (SPINLOCKSTATS)

  -- Get "heavy hitter" plan summary from syscacheobjects
  PRINT '==== cacheprofile summary'
  SELECT TOP 10 bucketid, cacheobjtype, objtype, objid, dbid, dbidexec, uid, SUM(refcounts) AS refcounts, 
    SUM(usecounts) AS usecounts, SUM(pagesused) AS pagesused, MAX(lasttime) AS lasttime, 
    MAX(maxexectime) AS maxexectime, AVG(avgexectime) AS avgexectime, SUM(avgexectime * usecounts) AS totalexectime, 
    SUM(lastreads) AS lastreads, SUM(lastwrites) AS lastwrites, SUM (pagesused) AS pagesused, 
    setopts, langid, [dateformat], status, sqlbytes, 
    LEFT (REPLACE (REPLACE (LEFT (sql, 1500), CHAR(10), ' '), CHAR (13), ' '), 1500) AS sql, COUNT(*) AS num_objects
  FROM master.dbo.syscacheobjects
  GROUP BY bucketid, cacheobjtype, objtype, objid, dbid, dbidexec, uid, setopts, langid, [dateformat], 
    status, sqlbytes, 
    LEFT (REPLACE (REPLACE (LEFT (sql, 1500), CHAR(10), ' '), CHAR (13), ' '), 1500) 
  HAVING SUM(usecounts) >= 3
    OR SUM(pagesused) >= 200
    OR MAX(maxexectime) >= 15000
    OR AVG(avgexectime) >= 5000
    OR SUM(lastreads) >= 100000
    OR SUM(lastwrites) >= 1000
    OR SUM(avgexectime * usecounts) > 60000
  ORDER BY SUM(avgexectime * usecounts) DESC
  OPTION (MAXDOP 1)

-- Commenting this out for now to avoid risks of SQL 8.0 bug #358626 (::fn_virtualfilestats can
-- cause CREATE and RESTORE DATABASE to fail). Biggest problem is the S-DB lock held on model. 
--  -- fn_virtualfilestats
--  PRINT '==== fn_virtualfilestats'
--  SELECT LEFT (DB_NAME (vfs.DbId), 50) AS DbName, 
--    LEFT (saf.filename, 7)  + '..' + RIGHT (RTRIM (saf.filename), 4) AS FilePath, 
--    vfs.DbId, vfs.FileId, vfs.IOStallMS, vfs.NumberReads, vfs.NumberWrites, vfs.BytesRead, vfs.BytesWritten, 
--    saf.size, saf.maxsize, saf.growth
--  FROM ::fn_virtualfilestats (-1, -1) AS vfs
--  LEFT OUTER JOIN master.dbo.sysaltfiles saf ON vfs.DbId = saf.dbid AND vfs.FileId = saf.fileid
--  ORDER BY saf.filename, vfs.IOStallMS DESC

  -- sysperfinfo
  PRINT '==== sysperfinfo'
  SELECT LEFT (object_name, 40) AS object_name, LEFT (counter_name, 60) AS counter_name, 
    LEFT (instance_name, 60) AS instance_name, cntr_value, cntr_type 
  FROM master.dbo.sysperfinfo

  -- inputbuffers of spids that have exceeded CPU threshold 
  DECLARE @max_cpu_threshold int
  SET @max_cpu_threshold = 80000
  PRINT '==== inputbuffers of spids that have exceeded CPU threshold (' 
    + CONVERT (varchar, @max_cpu_threshold) + ')'
  IF EXISTS (
    SELECT * FROM sysprocesses 
    WHERE cpu > @max_cpu_threshold AND spid > 50 AND cmd <> 'AWAITING COMMAND'
    )
  BEGIN
    PRINT ''
    PRINT '======== ECIDs exceeding CPU threshold ' 
    SELECT spid, kpid, blocked, waittype, waittime, lastwaittype, waitresource, dbid, 
      uid, cpu, physical_io, memusage, login_time, last_batch, ecid, open_tran, 
      status, LEFT (hostname, 20) AS hostname, LEFT (program_name, 30) AS program_name,
      hostprocess, cmd, LEFT (nt_domain, 20) AS nt_domain, 
      LEFT (nt_username, 20) AS nt_username, net_address, net_library, 
      LEFT (loginame, 20) AS loginname, stmt_start, stmt_end
    FROM master.dbo.sysprocesses 
    WHERE cpu > @max_cpu_threshold AND spid > 50 AND cmd <> 'AWAITING COMMAND'
    OPTION (MAXDOP 1)

    DECLARE @sql_handle binary (20)
    DECLARE @spid int
    DECLARE @ecid int
    DECLARE c CURSOR FOR
      SELECT DISTINCT spid, sql_handle FROM master.dbo.sysprocesses 
      WHERE cpu > @max_cpu_threshold AND spid > 50 AND cmd <> 'AWAITING COMMAND'
    OPEN c
    FETCH NEXT FROM c INTO @spid, @sql_handle
    WHILE (@@FETCH_STATUS <> -1)
    BEGIN
      IF (@@FETCH_STATUS <> -2)
      BEGIN
        PRINT '======== DBCC INPUTBUFFER for SPID ' + CONVERT (varchar, @spid)
        DBCC INPUTBUFFER (@spid)
        IF (@sql_handle <> 0x0)
        BEGIN
          PRINT '======== ::fn_get_sql for SPID ' + CONVERT (varchar, @spid)
          SELECT dbid, objectid, number, "text" 
          FROM ::fn_get_sql (@sql_handle)
        END
        FETCH NEXT FROM c INTO @spid, @sql_handle
      END
    END
    CLOSE c
    DEALLOCATE c
  END
  ELSE
    PRINT 'No ECIDs have exceeded CPU threshold (' + CONVERT (varchar, @max_cpu_threshold) + ')'

  WAITFOR DELAY '0:01:00'
END
