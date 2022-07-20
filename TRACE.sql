exec sp_trace_setstatus @traceid=3,@status=0 -- stop
exec sp_trace_setstatus @traceid=3,@status=1 -- start
exec sp_trace_setstatus @traceid=1,@status=2 --exclui

SELECT * FROM :: fn_trace_getinfo(3) 


select * from :: fn_trace_geteventinfo (1)
EXEC sp_trace_setstatus @traceid = 2 , @status = 0;

SELECT *
FROM ::fn_trace_geteventinfo(1)
WHERE EventID= '4'


SET NOCOUNT ON;
/*CRIANDO O TRACE*/
DECLARE 
  @TraceID INT             -- Código do Trace Criado
 ,@Arquivo NVARCHAR(256)   -- Nome do Arquivo Criado
 ,@TamanhoArquivo BIGINT   -- Tamanho Maximo do Arquivo
 ,@on bit
 ,@Valor BIGINT;           -- Valor do Parâmetro
 
set @on =1

SELECT @Arquivo = 'f:\MSSQL\MON\trace'+REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR,getdate(),120),' ',''),'-',''),':','')
      ,@TamanhoArquivo = 1024;
      
EXEC sp_trace_create 
       @traceid     =  @TraceID OUTPUT 
      ,@options     =  2 -- TRACE_FILE_ROLLOVER
      ,@tracefile   =  @Arquivo
      ,@maxfilesize =  @TamanhoArquivo 
      ,@stoptime    =  NULL;
      
SELECT @TraceID "Código do Trace Criado";

EXEC sp_trace_setstatus @traceid = @TraceID , @status = 0;

/*CADASTRO DE EVENTOS - SQL:StmtCompleted*/

DECLARE 
   @TraceID INT
  ,@evt int-- Código do Trace Criado
  ,@on bit
  ,@col int
 
set @on =1
set @TraceID=1
set @evt=12
set @col=1
EXEC sp_trace_setevent 
  @traceid  = @TraceID
 ,@eventid  = 12 -- SQL:StmtCompleted = Occurs when the Transact-SQL statement has completed.
 ,@columnid = 1 -- SPID = Server Process ID assigned by SQL Server to the process associated with the client.
 ,@on       = @on;







EXEC sp_trace_setevent 
  @traceid  = @TraceID 
 ,@eventid  = 15 -- SQL:StmtCompleted = Occurs when the Transact-SQL statement has completed.
 ,@columnid = 11 -- StartTime = Time at which the event started
 ,@on       = @on;

EXEC sp_trace_setevent 
  @traceid  = @TraceID 
 ,@eventid  = 41 -- SQL:StmtCompleted = Occurs when the Transact-SQL statement has completed.
 ,@columnid = 1 -- EndTime = Time at which the event ended
 ,@on       = @on;


EXEC sp_trace_setfilter 
  @traceid             = 1
 ,@columnid            = 3  -- DatabaseID = ID of the database where the statement was executed.
 ,@logical_operator    = 0  -- 0 = "AND" / 1 = "OR"
 ,@comparison_operator = 0  -- 0 = "=" / 1 = "<>" / 2 = ">" / 3 = "<" / 4 = ">=" / 5 = "<=" / 6 = "LIKE" / 7 = "NOT LIKE"
 ,@value               = 13;  -- INT / N'value'

 
SET NOCOUNT OFF;



select 504,c.name,c.description,c.definition,convert(sysname,DatabasePropertyEx(db_name(),'Collation')) from master.dbo.syscharsets c where c.id = convert(tinyint, databasepropertyex( db_name(), 'sqlcharset')) 