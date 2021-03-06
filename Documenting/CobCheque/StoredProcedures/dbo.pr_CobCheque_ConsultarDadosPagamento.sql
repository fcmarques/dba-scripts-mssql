SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Consulta dados pagamento
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_ConsultarDadosPagamento(
	@num_cpf		decimal(15,0) = null,
	@cod_dados_pagamento	int = null
)
as
set nocount on
	SELECT 	[cod_dados_pagamento], 
		[num_cpf], 
		[cod_filial_emissao], 
		[dat_emissao], 
		[num_algoritmo], 
		[val_cheque], 
		[val_encargos_atraso], 
		[val_desconto], 
		[val_total], 
		[cod_autorizacao], 
		[nom_login_responsavel], 
		[dat_atualizacao] 
	FROM 	[CobCheque].[dbo].[tb_cobch_dados_pagamento] (nolock)
	WHERE 	(num_cpf = @num_cpf or @num_cpf is null)
	AND	(cod_dados_pagamento = @cod_dados_pagamento or @cod_dados_pagamento is null)
set nocount off


GO
