SET NOCOUNT ON

declare @banco nvarchar(50),
		@caminho nvarchar (300),
		@cmd nvarchar(300),
		@id int,
		@recovery int
DECLARE cursor_n1 CURSOR FOR
	select name,database_id from sys.databases where  NAME IN ('MidwayAutorizadorConsulta','')
	OPEN cursor_n1
	FETCH NEXT FROM cursor_n1 INTO @banco, @id
		WHILE @@FETCH_STATUS = 0
		BEGIN
		select 'CREATE DATABASE '+@BANCO+' ON'
		union all
		SELECT '(FILENAME = N'''+FILENAME+'''),' FROM SYS.sysaltfiles WHERE DBID=@ID
UNION ALL

SELECT ' FOR ATTACH'


	
	FETCH NEXT FROM cursor_n1 INTO @banco, @id
END
CLOSE cursor_n1
DEALLOCATE cursor_n1
