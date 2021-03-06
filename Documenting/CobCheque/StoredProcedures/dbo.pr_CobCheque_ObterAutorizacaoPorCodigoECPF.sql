SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Obter determinada autorização por cliente
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_ObterAutorizacaoPorCodigoECPF
(
	@cod_autorizacao int = null,
	@num_cpf decimal(15,0) = null
)
as
set nocount on
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
	and	(cod_autorizacao = @cod_autorizacao or @cod_autorizacao is null)

set nocount off


GO
