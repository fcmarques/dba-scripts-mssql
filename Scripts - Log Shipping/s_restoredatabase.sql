--s_RestoreDatabase - restore all the databases from a full backup
--and then apply logs

ALTER PROC s_restoredatabase
   @SourcePath  VARCHAR(200), --the location of the backup files
   @archivePath VARCHAR(200), --where to archive the backup files
   @DataPath    VARCHAR(200), --location to restore the data file(s)
   @LogPath     VARCHAR(200), --location to restore the log file(s)
   @recover     VARCHAR(10),  -- recover, norecovery, standby
   @recipients  VARCHAR(128)  = NULL,     
   @Database    VARCHAR(128)  = NULL /* -- only restore
                                           this database */ 
AS
  /*
  For this to work, your backup files should be of the
  .BAK file type, and the files must have the word
  _FULL_ for a full backup or _LOG_ for a log file
  Example of use:    
   exec s_RestoreDatabase
      @SourcePath = 'c:\atest' , 
      @archivePath = 'c:\atest\archive' , 
      @DataPath = 'c:\atest' , 
      @LogPath = 'c:\atest' , 
      @recover = 'norecovery' , 
      @recipients = '' */

  /*
    Get all files from directory (they will be *.bak).
    The process is controlled by the files in the directory.
    If there is a full backup then restore it. 
    If there is a diff then restore it next.
    Restore any logs
    Recover database if necessary
  */

DECLARE  @dbname   VARCHAR(128), 
   @cmd      VARCHAR(2000), 
   @filename VARCHAR(128), 
   @s        VARCHAR(128), 
   @t        VARCHAR(128), 
   @sql      NVARCHAR(2000) 

CREATE TABLE #files (
   lname   VARCHAR(128), 
   pname   VARCHAR(128), 
   TYPE    VARCHAR(10), 
   fgroup  VARCHAR(128), 
   size    VARCHAR(50), 
   maxsize VARCHAR(50)) 

CREATE TABLE #dir (
   s VARCHAR(2000)) 

/* -- get list of files in directory */
SELECT @cmd = 'dir /B ' + @SourcePath + '*.bak'
INSERT #dir     
   EXEC master..xp_cmdshell  @cmd
DELETE #dir --delete anything which is not a backup
WHERE  s IS NULL
   OR s NOT LIKE '%.bak'
   OR (s NOT LIKE '%^_Full^_%' ESCAPE '^'
   AND s NOT LIKE '%^_Log^_%' ESCAPE '^') 
IF @Database IS NOT NULL --if he has specified a database
   DELETE #dir
      WHERE  s NOT LIKE @Database + '^_%' ESCAPE '^'

  /* -- deal with each database in turn */
  WHILE EXISTS (SELECT * FROM   #dir) 
    BEGIN     
    /* -- any with a full first */ 
      SELECT @dbname = NULL
      SELECT   TOP 1  @dbname = LEFT(s,CHARINDEX('_Full_',s) - 1)
             FROM     #dir
             WHERE    CHARINDEX('_Full_',s) <> 0
             ORDER BY s     
    /* -- no full - get log */
      IF @dbname IS NULL
        BEGIN     
          SELECT @dbname = NULL
          SELECT   TOP 1  @dbname = LEFT(s,CHARINDEX('_Log_',s) - 1) 
                 FROM     #dir     
                 WHERE    CHARINDEX('_Log_',s) <> 0
          ORDER BY s
        END
    /* -- find the last full backup for this db */
      SELECT @filename = NULL
      SELECT @filename = MAX(s)FROM #dir
       WHERE s LIKE @dbname + '_Full_%.bak'
    /* -- archive everything for this db that appears
                                   before this file */
      SELECT @s = ''     
      WHILE @s IS NOT NULL AND @filename IS NOT NULL
        BEGIN     
          SELECT   TOP 1  @s = s
          FROM #dir
              WHERE s LIKE @dbname + '%'
          ORDER BY RIGHT(s,20)     
          IF @s = @filename
            BEGIN
              SELECT @s = NULL
            END
          ELSE
            BEGIN
            /* -- move to archive */
              SELECT @cmd = 'move ' + @SourcePath
                       + @s + ' ' + @archivePath + @s
              EXEC master..xp_cmdshell  @cmd
              DELETE #dir WHERE  s = @s
            END
        END
 /* -- now we can go through each file in turn for this 
                               database and restore it */
      WHILE EXISTS
       (SELECT * FROM   #dir
                WHERE  s LIKE @dbname + '^_%' ESCAPE '^') 
        BEGIN     
          SELECT   TOP 1  @filename = s
               FROM #dir
               WHERE s LIKE @dbname + '^_%' ESCAPE '^'
          ORDER BY RIGHT(s,20) 
          IF @filename LIKE '%^_Full^_%' ESCAPE '^'
            BEGIN
            /* -- restore a full backup */
              IF EXISTS (SELECT *
                         FROM master..sysdatabases
                         WHERE name = @dbname) 
                BEGIN
            /* -- Drop the database before starting the restore */
                  SELECT @cmd = 'drop database ' + @dbname
                  EXEC( @cmd) 
                END
              SELECT @cmd = 'restore filelistonly  from disk = '''
                       + @SourcePath + @filename + ''''
              DELETE #files
              INSERT #files
              EXEC( @cmd) 
              /* -- now build the restore */
              SELECT @cmd = NULL, @s = ''
               WHILE @s <
                 (SELECT MAX(lname) FROM #files) 
                BEGIN
                  SELECT TOP 1 @s = lname, @t = TYPE
                  FROM #files
                         WHERE lname > @s
                         ORDER BY lname
                  SELECT @cmd = COALESCE(@cmd + ',move ','') 
                       + '''' + @s + ''' to '''
                       + CASE WHEN @t = 'D' THEN @DataPath
                                             ELSE @LogPath END
                       + @s + ''''
               END 

 /*The MOVE is used to relocate the database files
   and to avoid collisions with existing files. */

              SELECT @cmd = 'restore database '
                               + @dbname
                               + ' from disk = '''
                               + @SourcePath
                               + @filename
                               + ''' with move '
                               + @cmd     
                               + ', NORECOVERY'
    /* -- + ', standby = ''' + @localpath + 'standby.fil''' */
              EXEC( @cmd)     
            END     
          ELSE     
            IF @filename LIKE '%^Log^_%' ESCAPE '^'
              BEGIN 
              /* -- restore a log backup */
                SELECT @cmd = 'restore log '
                                 + @dbname
                                 + ' from disk = '''
                                 + @SourcePath
                                 + @filename
                                 + ''' with NORECOVERY'
                EXEC( @cmd)     
              END     
              /* -- move to archive */ 
          SELECT @cmd = 'move '
                          + @SourcePath
                          + @filename
                          + ' '
                          + @archivePath
                          + @filename
          EXEC master..xp_cmdshell  @cmd 
          DELETE #dir WHERE  s = @filename
        END     
        /* -- now set to correct recovey mode */ 
      IF @recover = 'recover'
        BEGIN
          SELECT @cmd = 'restore database '
                           + @dbname
                           + ' with recovery'
          EXEC( @cmd)
        END
    END
GO

