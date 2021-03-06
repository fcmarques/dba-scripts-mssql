SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Obtem autorizações que foram processadas no dia para o cliente selecionado
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_ConsultarAutorizacoes(
	@num_cpf	decimal(15,0) = null,
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
	WHERE 	(num_cpf = @num_cpf or @num_cpf is null)
		and ind_autorizacao is null
		and (dat_requisicao >= @dat_atualizacao and dat_requisicao < dateadd(dd,1,@dat_atualizacao))



GO
