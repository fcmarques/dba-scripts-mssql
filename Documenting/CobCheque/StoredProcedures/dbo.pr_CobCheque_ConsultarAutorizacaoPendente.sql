SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Obtem autorização de desconto para uma negociação de cheques pendentes
Autor		: Marcelo Brefore
Data		: 13/06/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_ConsultarAutorizacaoPendente(
	@num_cpf	decimal(15,0),
	@val_total	decimal(12,2),
	@dat_atualizacao	datetime
)
as
	SELECT 	[num_cpf], 
		[cod_autorizacao], 
		[val_cheque], 
		[val_encargo], 
		[val_desconto], 
		[val_total], 
		[ind_autorizacao], 
		[cod_filial_requisicao], 
		[nom_login_requisicao], 
		[dat_requisicao], 
		[nom_login_responsavel], 
		[dat_atualizacao] 
	FROM [CobCheque].[dbo].[tb_cobch_autorizacao] (nolock)
	WHERE 	num_cpf = @num_cpf 
		and ind_autorizacao is null
		and val_total = @val_total
		and (datediff(day,dat_requisicao,@dat_atualizacao) = 0)



GO
