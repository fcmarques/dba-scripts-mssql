/*
listar todos os data files e calcular o espaço livre
calcular espaço utilizado + 20%
criar um loop para limpar a cada 1 gb
	o loop deve limpar 1 gb pçor vez e alternar entre os arquivo ou fazer todo o arquivo
*/	
use AUTCOM
go
declare @size int
		,@ctrl int
		,@id int

DECLARE cursor_n1 CURSOR FOR
	SELECT [file_id],round (size/128 - (CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128),-1)*1.3
	FROM sys.database_files
	where type=0

	select size/128
	from sys.database_files
	where file_id=1
OPEN cursor_n1
FETCH NEXT FROM cursor_n1 INTO @id, @size
WHILE @@FETCH_STATUS = 0
	BEGIN
			set @size = (select ((size*8)/1024)-1024
			from sys.database_files
			where file_id = @id)
		
			DBCC SHRINKFILE (@id,@size)
			print @id
							
	
	FETCH NEXT FROM cursor_n1 INTO @id, @size
	END

CLOSE cursor_n1
DEALLOCATE cursor_n1
