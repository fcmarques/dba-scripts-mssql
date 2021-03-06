SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE procedure [dbo].[rsp_sel_reg]
as
begin
set nocount on
declare @cod_cliente char(11),
	@data_hora char(16),
	@num_caixa char(3),
	@txt_registro char(255)

select top 1 @txt_registro = txt_registro,
	@cod_cliente = i.cod_cliente,
	@data_hora = i.data_hora,
	@num_caixa = i.num_caixa 
from ind_trans i (nolock), log_trans l (nolock)
where i.data_hora = l.data_hora  
	and i.num_caixa = l.num_caixa  
	and i.cod_cliente = l.cod_cliente
	and data_hora_envio < getdate()
order by ind_prior, data_hora_envio

update ind_trans 
set data_hora_envio = dateadd(ss, +20, getdate())
where data_hora = @data_hora  
	and num_caixa = @num_caixa  
	and cod_cliente = @cod_cliente

select @txt_registro as txt_registro
end





GO
