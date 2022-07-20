SELECT S.srvname, 
       S.srvproduct, 
       S.providername, 
       S.datasource, 
       S.location, 
       S.providerstring, 
       S.catalog, 
       S.srvnetname, 
       S.collation, 
       'status' AS STATE 
INTO   #tblinkedservers 
FROM   sys.sysservers S

DECLARE @srvname VARCHAR(100) 
DECLARE @sqlstr VARCHAR(1000) 
DECLARE @retval INT 
DECLARE @srvr NVARCHAR(128) 
DECLARE @srvrstate VARCHAR(5) 
DECLARE linkedserverscursor CURSOR FOR 
  SELECT srvname 
  FROM   #tblinkedservers 

OPEN linkedserverscursor 

FETCH next FROM linkedserverscursor INTO @srvname 

WHILE @@FETCH_STATUS = 0 
  BEGIN 
      SET @srvr = @srvname 

      BEGIN try 
          EXEC @retval = sys.Sp_testlinkedserver @srvr; 
      END try 

      BEGIN catch 
          SET @retval = Sign(@@error); 
      END catch; 

      IF @retval <> 0 
		SET @srvrstate = 'NOK';
      ELSE 
        SET @srvrstate = 'OK' 

      UPDATE #tblinkedservers 
      SET    state = @srvrstate 
      WHERE  srvname = @srvr 

      FETCH next FROM linkedserverscursor INTO @srvname 
  END 

CLOSE linkedserverscursor 

DEALLOCATE linkedserverscursor 

SELECT * 
FROM   #tblinkedservers 

DROP TABLE #tblinkedservers 