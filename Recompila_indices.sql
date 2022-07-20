declare @cmd nvarchar(max),
		@ctrl int,
		@id int

--Criação da tabel de controle para acompanhar o processo
if ((select Object_id('RCPL_IDCE')) is null)
	begin
	create table RCPL_IDCE (id int identity (1,1), cmd varchar(max), ctrl int, start datetime, finished datetime)
	end

--Variavel de controle para que seja possíve rodar mais de um processo se necessario "lembrar de alterar o passo anterios para não fazer os mesmos indices"
set @ctrl = (select max(ctrl) from RCPL_IDCE)+1

--Validação da variavel de controle
if (@ctrl is null)
	begin
	set @ctrl = 1
	end
	
--Populo a tabela com todos os indices começando pela PK
insert into RCPL_IDCE (cmd, ctrl) select 'alter index '+b.name+' on '+a.name+'  rebuild with (online=on,fillfactor=90, maxdop=4)' as cmd, @ctrl
from sys.tables as a join sys.indexes as b on a.object_id=b.object_id  and b.index_id>0 and a.name not in (select a.name
from sys.tables as a join sys.columns as b on a.object_id=b.object_id
 where b.system_type_id in (34,35,165,241)
 or (b.system_type_id = 165 and max_length < 0)
 or (b.system_type_id = 167 and max_length < 0)
 or (b.system_type_id = 231 and max_length < 0)
)
insert into RCPL_IDCE (cmd, ctrl) select 'alter index '+b.name+' on '+a.name+'  rebuild with (online=off,fillfactor=90, maxdop=4)' as cmd, @ctrl
from sys.tables as a join sys.indexes as b on a.object_id=b.object_id  and b.index_id>0 and a.name in (select a.name
from sys.tables as a join sys.columns as b on a.object_id=b.object_id
 where b.system_type_id in (34,35,165,241)
 or (b.system_type_id = 165 and max_length < 0)
 or (b.system_type_id = 167 and max_length < 0)
 or (b.system_type_id = 231 and max_length < 0)
)

 
 
DECLARE cursor_n1 CURSOR FOR
select id, cmd from RCPL_IDCE where ctrl=@ctrl
OPEN cursor_n1
	FETCH NEXT FROM cursor_n1 INTO @id, @cmd
	WHILE @@FETCH_STATUS = 0
		BEGIN
		update RCPL_IDCE set start=getdate() where id=@id
		exec sp_executesql @cmd
		update RCPL_IDCE set finished=getdate() where id=@id
		FETCH NEXT FROM cursor_n1 INTO @id,@cmd
	END
CLOSE cursor_n1
DEALLOCATE cursor_n1
go
select * from RCPL_IDCE


 