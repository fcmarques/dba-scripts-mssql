CREATE PROCEDURE [dbo].[List_dbroles] (@database   NVARCHAR(128)=NULL, 
                                       @user       VARCHAR(20)=NULL, 
                                       @dbo        CHAR(1)=NULL, 
                                       @access     CHAR(1)=NULL, 
                                       @security   CHAR(1)=NULL, 
                                       @ddl        CHAR(1)=NULL, 
                                       @datareader CHAR(1)=NULL, 
                                       @datawriter CHAR(1)=NULL, 
                                       @denyread   CHAR(1)=NULL, 
                                       @denywrite  CHAR(1)=NULL) 
AS 
    DECLARE @dbname VARCHAR(200) 
    DECLARE @mSql1 VARCHAR(8000) 

    CREATE TABLE #dbroles 
      ( 
         dbname            SYSNAME NOT NULL, 
         username          SYSNAME NOT NULL, 
         db_owner          VARCHAR(3) NOT NULL, 
         db_accessadmin    VARCHAR(3) NOT NULL, 
         db_securityadmin  VARCHAR(3) NOT NULL, 
         db_ddladmin       VARCHAR(3) NOT NULL, 
         db_datareader     VARCHAR(3) NOT NULL, 
         db_datawriter     VARCHAR(3) NOT NULL, 
         db_denydatareader VARCHAR(3) NOT NULL, 
         db_denydatawriter VARCHAR(3) NOT NULL, 
         cur_date          DATETIME NOT NULL DEFAULT Getdate() 
      ) 

    DECLARE dbname_cursor CURSOR FOR 
      SELECT name 
      FROM   master.dbo.sysdatabases 
      WHERE  name NOT IN ( 'mssecurity', 'tempdb' ) 
      ORDER  BY name 

    OPEN dbname_cursor 

    FETCH next FROM dbname_cursor INTO @dbname 

    WHILE @@FETCH_STATUS = 0 
      BEGIN 
          SET @mSQL1 = ' Insert into #DBROLES ( DBName, UserName, db_owner, db_accessadmin, db_securityadmin, db_ddladmin, db_datareader, db_datawriter, db_denydatareader, db_denydatawriter ) SELECT ' + '''' + @dbName + '''' 
                       + ' as DBName ,UserName, ' + Char(13) + ' Max(CASE RoleName WHEN ''db_owner'' THEN ''Yes'' ELSE ''No'' END) AS db_owner, Max(CASE RoleName WHEN ''db_accessadmin '' THEN ''Yes'' ELSE ''No'' END) AS db_accessadmin , Max(CASE RoleName WHEN ''db_securityadmin'' THEN ''Yes'' ELSE ''No'' END) AS db_securityadmin, Max(CASE RoleName WHEN ''db_ddladmin'' THEN ''Yes'' ELSE ''No'' END) AS db_ddladmin, Max(CASE RoleName WHEN ''db_datareader'' THEN ''Yes'' ELSE ''No'' END) AS db_datareader, Max(CASE RoleName WHEN ''db_datawriter'' THEN ''Yes'' ELSE ''No'' END) AS db_datawriter, Max(CASE RoleName WHEN ''db_denydatareader'' THEN ''Yes'' ELSE ''No'' END) AS db_denydatareader, Max(CASE RoleName WHEN ''db_denydatawriter'' THEN ''Yes'' ELSE ''No'' END) AS db_denydatawriter from ( select b.name as USERName, c.name as RoleName from ' 
                       + @dbName + '.dbo.sysmembers a ' + Char(13) 
                       + ' join ' + @dbName + '.dbo.sysusers b ' 
                       + Char(13) + ' on a.memberuid = b.uid join ' 
                       + @dbName + '.dbo.sysusers c on a.groupuid = c.uid )s Group by USERName order by UserName' 

          --Print @mSql1 
          EXECUTE (@mSql1) 

          FETCH next FROM dbname_cursor INTO @dbname 
      END 

    CLOSE dbname_cursor 

    DEALLOCATE dbname_cursor 

    SELECT * 
    FROM   #dbroles 
    WHERE  ( ( @database IS NULL ) 
              OR ( dbname LIKE '%' + @database + '%' ) ) 
           AND ( ( @user IS NULL ) 
                  OR ( username LIKE '%' + @user + '%' ) ) 
           AND ( ( @dbo IS NULL ) 
                  OR ( db_owner = 'Yes' ) ) 
           AND ( ( @access IS NULL ) 
                  OR ( db_accessadmin = 'Yes' ) ) 
           AND ( ( @security IS NULL ) 
                  OR ( db_securityadmin = 'Yes' ) ) 
           AND ( ( @ddl IS NULL ) 
                  OR ( db_ddladmin = 'Yes' ) ) 
           AND ( ( @datareader IS NULL ) 
                  OR ( db_datareader = 'Yes' ) ) 
           AND ( ( @datawriter IS NULL ) 
                  OR ( db_datawriter = 'Yes' ) ) 
           AND ( ( @denyread IS NULL ) 
                  OR ( db_denydatareader = 'Yes' ) ) 
           AND ( ( @denywrite IS NULL ) 
                  OR ( db_denydatawriter = 'Yes' ) ) 