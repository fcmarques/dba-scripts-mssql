
declare  @banco VARCHAR(30), 
		 @CMD NVARCHAR (1000)

DECLARE cursor_n1 CURSOR FOR
SELECT NAME FROM SYS.databases where database_id>4 and state=0 and name != 'dbalog'

OPEN cursor_n1
	FETCH NEXT FROM cursor_n1  INTO @banco
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
	
	SET @CMD='use '+@banco+char(10)+'insert into [rsqladm\maps].dbalog.dbo.volumetria
SELECT @@SERVERNAME,
       DB_NAME(),
       name,
       physical_name,
      (size*8)/1024 as Size,
	   convert(int,((FILEPROPERTY(name,''SpaceUsed'')*8)/1024)) as SpaceUsed,
      (size*8)/1024-convert(int,((FILEPROPERTY(name,''SpaceUsed'')*8)/1024)),
	   case
			when max_size < 0 then max_size 
			when max_size >=1 then ((max_size*8)/1024)
		else 1
				end,
				convert (date,GETDATE())
			FROM sys.database_files WHERE type=0'
	exec sp_executesql @cmd
			
	FETCH NEXT FROM cursor_n1 INTO @banco
	END
CLOSE cursor_n1
DEALLOCATE cursor_n1
