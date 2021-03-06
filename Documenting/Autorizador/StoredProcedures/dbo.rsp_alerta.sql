SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE rsp_alerta      
---- envia msg de alerta qd db ou log estiver com pouca area livre       
----      
---- server: riachu_crm riachuelocrm / tempdb      
----  riachu_dbgen autcom / sisap / tempdb      
----  riachu_fin sicc / sicc_hist / tempdb      
----  sapbwdbp bwp / tempdb      
----  sapr3dbp r3p / tempdb      
----  sapw3dbp w3p / tempdb      
AS            
      
--/*      
--formato mensagens      
-- @msg_w_<nnn> não hold / red      
-- @msg_c_<nnn> hold / pink      
-- @msg_a_<nnn> hold / azul       
      
--*/      
            
DECLARE @bytesperpage		DEC(15,0)
		,@cmd				VARCHAR(255)      
		,@dbname			sysname            
		,@dbsize_pg			DEC(15,0)            
		,@dbused_perc		INT      
		,@id				INT         
		,@limite_used_mb	DEC(15,2)        
		,@log				INT          
		,@logsize_pg		DEC(15)            
		,@log_hold_thres	INT      
		,@log_msg_thres		INT      
		,@msg_full			VARCHAR(255)      
		,@pages				INT      
		,@pagespermb		DEC(15,0)           
		,@reserved_mb		DEC(15,2)      
		,@subject_full		VARCHAR(80)      
		,@type				CHAR(2)      


IF OBJECT_ID('tempdb..#spt_space') IS NOT NULL
	DROP TABLE #spt_space
    
CREATE TABLE #spt_space(    
	rows		INT NULL,            
	reserved	DEC(15) NULL,            
	data		DEC(15) NULL,            
	indexp		DEC(15) NULL,            
	unused		DEC(15) NULL)            
      
IF OBJECT_ID('tempdb..#space_mb') IS NOT NULL
	DROP TABLE #space_mb
    
CREATE TABLE #space_mb (      
	objname			VARCHAR(80) NOT NULL,      
	rows			INT NOT NULL,      
	reserved		DEC(15,0) NOT NULL,      
	data			DEC(15,0) NOT NULL,      
	index_size		DEC(15,0) NOT NULL,      
	unused			DEC(15,0) NOT NULL)      
	
      
SELECT	@dbsize_pg = SUM(CONVERT(DEC(15),size))            
FROM	dbo.sysfiles (NOLOCK)    
WHERE	(status & 64 = 0)            
          
SELECT	@logsize_pg = SUM(CONVERT(DEC(15),size))            
FROM	dbo.sysfiles (NOLOCK)    
WHERE	(status & 64 <> 0)            
            
SELECT	@bytesperpage = low            
FROM	master.dbo.spt_values (NOLOCK)            
WHERE	number = 1            
		AND type = 'E'      
      
SELECT	@pagesperMB = 1048576 / @bytesperpage            

INSERT INTO #spt_space (reserved) VALUES (@dbsize_pg)      
            
UPDATE #spt_space            
	SET		data = (SELECT ISNULL(SUM(CONVERT(DEC(15),dpages)), 0)            
	FROM	sysindexes (NOLOCK)    
	WHERE	indid in (0, 1) )          
      
UPDATE #spt_space            
	SET		indexp = (SELECT ISNULL(SUM(CONVERT(DEC(15),dpages)),0)      
	FROM	sysindexes (NOLOCK)    
    WHERE	indid not in (0, 1, 255))      
            
UPDATE #spt_space            
	SET unused = reserved - (SELECT ISNULL(SUM(CONVERT(DEC(15),used)), 0)
							 FROM sysindexes (NOLOCK)
							 WHERE indid in (0, 1))            
      
INSERT INTO #space_mb       
SELECT  DB_NAME(),       
		ISNULL(CONVERT(INT, rows), 0),            
		reserved * d.low / 1024.,            
		data * d.low  / 1024.,            
		indexp * d.low / 1024.,            
		unused * d.low / 1024.       
FROM	#spt_space (NOLOCK),
		master.dbo.spt_values d (NOLOCK)    
WHERE	d.number = 1      
		AND d.type = 'E'      
         
SELECT	@dbused_perc = ((data + index_size) / reserved) * 100      
FROM	#space_mb (NOLOCK)    
      
IF @dbused_perc >= 98      
BEGIN            
SELECT		@msg_full = '"@MSG_C_AreaBanco ' + DB_NAME() + ' - '       
			+ CAST(@dbused_perc as VARCHAR(3)) + ' por cento utilizada "'       
 
SET @cmd = '\\riachu_fs\sistemas\producao\bat\sqlogger.bat ' + @msg_full      
EXEC master..xp_cmdshell @cmd      

     
 SET @cmd = 'CREATE TABLE #space (c1 VARCHAR(100))      
  INSERT #space values (''O banco '' + DB_NAME() + '' esta com ' +       
  CAST(@dbused_perc as VARCHAR(3)) +       
    '% de sua capacidade preenchida'')      
  SELECT c1 FROM #space'      
SELECT @cmd      
 EXEC master.dbo.xp_sendmail 'sonia@riachuelo.com.br; fesantos@riachuelo.com.br',       
  @query = @cmd,       
  @no_header= 'TRUE',      
  @subject = @subject_full      
    
           
END          

IF OBJECT_ID('tempdb..#space_log') IS NOT NULL
		DROP TABLE #space_log
      
CREATE TABLE #space_log(        
	db			VARCHAR(50),        
	logsize		INT,        
	used		INT,        
	status		INT)        
        
INSERT INTO #space_log        
   EXEC ('DBCC SQLPERF(LOGSPACE) WITH NO_INFOMSGS')        
        
SELECT	@log = used       
FROM	#space_log (NOLOCK)    
WHERE	db = DB_NAME()      
      
IF (SELECT DB_NAME()) = 'BWP'      
	BEGIN      
		SET @log_msg_thres = 50      
		SET @log_hold_thres = 70      
	END     
ELSE      
	BEGIN      
		SET @log_msg_thres = 60      
		SET @log_hold_thres = 80      
	END     
      
IF @log > @log_hold_thres       
	BEGIN      
		SELECT	@msg_full = '"@MSG_C_AreaLog ' + DB_NAME() + ' - '       
				+ CAST(@log as VARCHAR(3)) + ' por cento utilizada "'
				      
		SET @cmd = '\\riachu_fs\sistemas\producao\bat\sqlogger.bat ' + @msg_full       
		EXEC master..xp_cmdshell @cmd      
	END     
ELSE IF @log BETWEEN @log_msg_thres AND @log_hold_thres      
	BEGIN      
		SELECT	@msg_full = '"@MSG_W_AreaLog ' + DB_NAME() + ' - '       
				+ CAST(@log as VARCHAR(3)) + ' por cento utilizada "'      
		
		SET @cmd = '\\riachu_fs\sistemas\producao\bat\sqlogger.bat ' + @msg_full      
		EXEC master..xp_cmdshell @cmd      
	END     
      
return (0)

GO
