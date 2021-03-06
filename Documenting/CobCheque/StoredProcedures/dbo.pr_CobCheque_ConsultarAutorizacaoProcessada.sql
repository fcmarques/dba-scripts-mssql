SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Obtem autorizações que foram processadas no dia para o cliente selecionado
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_ConsultarAutorizacaoProcessada(
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
		and (ind_autorizacao is null or upper(ind_autorizacao) = 'S')
		and val_total = @val_total
		and (datediff(day,dat_requisicao,@dat_atualizacao) = 0)



GO
