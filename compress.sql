use R3P
go
--declaro as variaves

declare @cmd nvarchar(150),
        @idx_id int,
        @tabela nvarchar(20),
        @idx nvarchar(20),
        @ctrl int,
        @job int
 
if not exists (select name from sys.objects where name ='compress')
	begin
	CREATE TABLE [dbo].[compress](
	[tabela] [sysname] NOT NULL,
	[idx] [sysname] NULL,
	[idx_id] [int] NOT NULL,
	[szidx] [bigint] NULL,
	[start] [datetime] NULL,
	[finished] [datetime] NULL,
	[ctrl] [int] NULL
		)
	end            
--informo a tabela
set @tabela = 'MSEG'

--atribuo o valor para o campo de ctrl da tabela compress assim posso rodar duas sessoes
--set @ctrl=(select isnull ( (MAX(ctrl)+1),1) from compress)
set @ctrl=(select max(ctrl)+1 from compress)

if @ctrl is null
	begin
	set @ctrl=1
	end

--verifico o tamnho da tabela e seus indices

insert into compress (tabela, idx, idx_id, szidx) select a.name,b.name, b.index_id,(SUM(d.used_page_count)*8)/1024/1024 AS IndexSizeGB 
from sys.tables as a join sys.indexes as b on a.object_id=b.object_id 
     				join sys.partitions as c on a.object_id=c.object_id and b.index_id=c.index_id
					join sys.dm_db_partition_stats as d on a.object_id=d.object_id and c.index_id=d.index_id
where c.data_compression = 0
and a.name = @tabela
group by a.name, b.name, b.index_id
having (SUM(d.used_page_count)*8)/1024/1024 > 1

--altero a coluna de controle da tabela compress para executar processos em paralelo

update compress set ctrl = @ctrl where ctrl is null

--declaro o cursor para a sessao
DECLARE cursor_n1 CURSOR FOR
select tabela, idx, idx_id from compress where ctrl=@ctrl and finished is null order by tabela
OPEN cursor_n1
	FETCH NEXT FROM cursor_n1 INTO @tabela,@idx, @idx_id
	WHILE @@FETCH_STATUS = 0
		BEGIN
            if (@idx_id<=1)
			    begin 
				  set @cmd = 'alter table ['+rtrim(@tabela)+'] rebuild with (data_compression=page,online=on,maxdop=4)'
				  --print @cmd
                  update compress set start = GETDATE() where tabela=@tabela
                  exec sp_executesql @cmd
                  update compress set finished = GETDATE() where tabela=@tabela
				end
            else
                begin
                  set   @cmd = 'alter index ['+rtrim(@idx)+'] on '+@tabela+'  rebuild with (data_compression=page,online=on,fillfactor=90,maxdop=4)'
				  --print @cmd
                  update compress set start = GETDATE() where idx=@idx and idx_id=@idx_id --update na tabela compress para controlar o inicio do processo
				  exec sp_executesql @cmd
                  update compress set finished = GETDATE() where idx=@idx and idx_id=@idx_id --update na tabela compress para controlar o fim do processo
				end
                  
    FETCH NEXT FROM cursor_n1 INTO @tabela,@idx, @idx_id
	END
CLOSE cursor_n1
DEALLOCATE cursor_n1
go

