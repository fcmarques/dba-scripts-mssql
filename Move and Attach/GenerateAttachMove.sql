-- Build the sp_attach_db: 
-- In this example, I am assuming that only the drive letter changes, not the whole 
-- path of the files. You can modify this script according to your needs: 
SET NOCOUNT ON  
DECLARE     @cmd        VARCHAR(MAX), 
            @dbname     VARCHAR(200), 
            @prevdbname VARCHAR(200) 

SELECT @cmd = '', @dbname = ';', @prevdbname = '' 
CREATE TABLE #Attach 
    (Seq        INT IDENTITY(1,1) PRIMARY KEY, 
     dbname     SYSNAME       NULL, 
     fileid     INT           NULL, 
     filename   VARCHAR(1000) NULL, 
     TxtAttach  VARCHAR( MAX)  NULL 
) 

INSERT INTO #Attach 
SELECT DISTINCT DB_NAME(dbid) AS dbname, fileid,  
            CASE SUBSTRING(filename,1,1)  
                  WHEN 'E' THEN 'I' + SUBSTRING(filename,2,LEN(filename))  
                  WHEN 'F' THEN 'J' + SUBSTRING(filename,2,LEN(filename)) 
                  ELSE filename 
            END, 
            CONVERT(VARCHAR(MAX),'') AS TxtAttach 
FROM master.dbo.sysaltfiles 
WHERE dbid IN (SELECT dbid FROM master.dbo.sysaltfiles  
            WHERE SUBSTRING(filename,1,1) IN ('E','F')) 
            AND DATABASEPROPERTYEX(DB_NAME(dbid) , 'Status' ) = 'ONLINE' 
            AND DB_NAME(dbid) NOT IN ('master','tempdb','msdb','model') 
ORDER BY dbname, fileid,  
            CASE SUBSTRING(filename,1,1)  
                  WHEN 'E' THEN 'I' + SUBSTRING(filename,2,LEN(filename))  
                  WHEN 'F' THEN 'J' + SUBSTRING(filename,2,LEN(filename)) 
                  ELSE filename 
            END 

UPDATE #Attach 
SET @cmd = TxtAttach =   
            CASE WHEN dbname <> @prevdbname  
            THEN CONVERT(VARCHAR(200),'exec sp_attach_db @dbname = N''' + dbname + '''') 
            ELSE @cmd 
            END +',@filename' + CONVERT(VARCHAR(10),fileid) + '=N''' + filename +'''', 
    @prevdbname = CASE WHEN dbname <> @prevdbname THEN dbname ELSE @prevdbname END, 
    @dbname = dbname 
FROM #Attach  WITH (INDEX(0),TABLOCKX) 
OPTION (MAXDOP 1) 

SELECT TxtAttach 
FROM 
(SELECT dbname, MAX(TxtAttach) AS TxtAttach FROM #Attach 
GROUP BY dbname) AS x 

DROP TABLE #Attach 
GO