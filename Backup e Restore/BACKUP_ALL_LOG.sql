<<<<<<< HEAD
declare @banco nvarchar(50),
		@caminho nvarchar (300),
		@cmd nvarchar(300),
		@id int,
		@recovery int
DECLARE cursor_n1 CURSOR FOR
	select name,database_id from sys.databases where  database_id >4 and name != 'dbalog'
	OPEN cursor_n1
	FETCH NEXT FROM cursor_n1 INTO @banco, @id
		WHILE @@FETCH_STATUS = 0
		BEGIN
		set @caminho = 'G:\MSSQL\Dados1\'+@banco+'.TRN'
		print @caminho	
		set @recovery = (select recovery_model from sys.databases where database_id =@id)
		if (@recovery = 3)
			begin
			set	@cmd = 'alter database '+rtrim(@banco)+' set recovery full'
			exec sp_executesql @cmd
			end
		set @cmd = 'BACKUP log '+@banco+' tO  DISK = '''+@caminho+''' WITH NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD,  STATS = 10'
		exec sp_executesql @cmd
		--print @cmd
		
	
	FETCH NEXT FROM cursor_n1 INTO @banco, @id
END
CLOSE cursor_n1
DEALLOCATE cursor_n1

=======
declare @banco nvarchar(50),
		@caminho nvarchar (300),
		@cmd nvarchar(300),
		@id int,
		@recovery int
DECLARE cursor_n1 CURSOR FOR
	select name,database_id from sys.databases where  database_id >4 and name != 'dbalog'
	OPEN cursor_n1
	FETCH NEXT FROM cursor_n1 INTO @banco, @id
		WHILE @@FETCH_STATUS = 0
		BEGIN
		set @caminho = 'G:\MSSQL\Dados1\'+@banco+'.TRN'
		print @caminho	
		set @recovery = (select recovery_model from sys.databases where database_id =@id)
		if (@recovery = 3)
			begin
			set	@cmd = 'alter database '+rtrim(@banco)+' set recovery full'
			exec sp_executesql @cmd
			end
		set @cmd = 'BACKUP log '+@banco+' tO  DISK = '''+@caminho+''' WITH NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD,  STATS = 10'
		exec sp_executesql @cmd
		--print @cmd
		
	
	FETCH NEXT FROM cursor_n1 INTO @banco, @id
END
CLOSE cursor_n1
DEALLOCATE cursor_n1

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
