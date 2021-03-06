SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE procedure [dbo].[rsp_del_ind]
	@data_hora char(16),
	@num_caixa char(3),
	@cod_cliente char(11)
as
begin

set nocount on
declare @cod_retorno int

delete from ind_trans 
where data_hora = @data_hora
	and num_caixa = @num_caixa
	and cod_cliente = @cod_cliente

select @cod_retorno = @@error
if @cod_retorno <> 0
begin
	raiserror('Erro exclusao ind_trans. Cod = %d',14,1,@cod_retorno)
	return(8)

end
end


GO
