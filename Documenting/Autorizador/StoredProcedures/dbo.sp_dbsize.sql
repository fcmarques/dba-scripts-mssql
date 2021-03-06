SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_dbsize]
AS
BEGIN
	BEGIN try  
DECLARE @banco VARCHAR(500)  
		,@SIZE numeric 
		,@LIVRE numeric 
		,@dbsize numeric 
		,@logsize bigint
		,@reservedpages  bigint
		,@usedpages  bigint
		,@pages bigint
		,@data datetime
		,@pct_livre decimal (38,2);

set @data = (convert (datetime,getdate(),102));

set @banco = db_name ();

		select @dbsize = sum(convert(bigint,case when status & 64 = 0 then size else 0 end))
				 from dbo.sysfiles
				 where maxsize like '-1'
				 
--definindo a quatidade de pagians reservadas
		select @reservedpages = sum(a.total_pages),
			@usedpages = sum(a.used_pages),
			@pages = sum(CASE
							When it.internal_type IN (202,204) Then 0
							When a.type <> 1 Then a.used_pages
							When p.index_id < 2 Then a.data_pages
							Else 0
							END)
		from sys.partitions p join sys.allocation_units a on p.partition_id = a.container_id
			left join sys.internal_tables it on p.object_id = it.object_id

set @SIZE  = convert(dec,(ltrim(str((convert (dec (15,2),@dbsize))* 8192 / 1048576,15,2))));
SET @LIVRE = convert (dec,(ltrim(str((case when @dbsize >= @reservedpages then (convert (dec (15,2),@dbsize) - convert (dec (15,2),@reservedpages)) * 8192 / 1048576 else 0 end),15,2))));
set @pct_livre = (@livre * 100)/@size;   
INSERT INTO [r-dbgen64].dbalog.dbo.VOLUMETRIA (BANCO,DSK_ALOCADO_MB,DSK_LIVRE_MB,PCT_LIVRE_MB,DATA,SERVIDOR) VALUES(@banco,@SIZE,@LIVRE,@pct_livre,@data,@@SERVERNAME);
         
         
END try  
BEGIN catch  
SELECT -100 AS l1 
,       ERROR_NUMBER() AS tablename 
,       ERROR_SEVERITY() AS row_count 
,       ERROR_STATE() AS reserved 
,       ERROR_MESSAGE() AS data 
,       1 AS index_size, 1 AS unused, 1 AS schemaname  
END catch

	SET NOCOUNT ON;

    
	
END


GO
