SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[Rsp_Limpeza]

AS
begin

set nocount on
declare	@data_aux 	datetime,
	@data_limpeza 	char(16),
	@error		int,
	@rowcount	int

--select @data_aux = dateadd(month, -1, getdate())
select @data_aux = dateadd(day, -15, getdate())
select @data_limpeza =  cast(datepart(year,@data_aux) as char(4))
	+ case 
		when datepart(month,@data_aux) < 10 then '0' + cast(datepart(month,@data_aux) as char(1))
		else cast(datepart(month,@data_aux) as char(2))
	end
	+ case 
		when datepart(day,@data_aux) < 10 then '0' + cast(datepart(day,@data_aux) as char(1))
		else cast(datepart(day,@data_aux) as char(2)) 
	end 
	+ '00000000' 

set rowcount 50000

delete from log_trans
--select * from log_trans
	where log_trans.data_hora < @data_limpeza
		and log_trans.data_hora not in 
			(select data_hora 
				from ind_trans (nolock)
				where log_trans.data_hora = ind_trans.data_hora
					and log_trans.num_caixa = ind_trans.num_caixa
					and log_trans.cod_cliente = ind_trans.cod_cliente)

select @rowcount = @@rowcount , @error = @@error
if ( @error <> 0 ) 
begin
	rollback transaction
	insert into log_erro values(@data_limpeza,NULL,NULL, 'Limpeza', getdate() , @error )
	raiserror('Erro na inclusao log_erro. Cod = %d',14,1,@error )
	return(8)
end

set rowcount 0

insert into log_erro values(@data_limpeza,NULL,NULL, 'Limpeza', getdate() , 0 )
select @rowcount as num_registros

EXEC ('DBCC DBREINDEX(log_trans,'''' ,50) WITH NO_INFOMSGS')
EXEC ('DBCC UPDATEUSAGE(autorizador,log_trans)')

EXEC ('DBCC DBREINDEX(ind_trans,'''' ,50) WITH NO_INFOMSGS')
EXEC ('DBCC UPDATEUSAGE(autorizador,ind_trans)')


EXEC ('DBCC CHECKDB(autorizador)')
--EXEC ('DBCC DROPCLEANBUFFERS')
--EXEC ('DBCC FREEPROCCACHE')

end

GO
