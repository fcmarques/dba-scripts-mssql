SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/* 
Descrição	: Stored Procedure para consultar recebimento o histórico
Autor		: Paula Akemi
Data		: 04/08/06
Empresa		: B2Br
Projeto		: SICC New
*/
CREATE procedure dbo.pr_CobCheque_ConsultarDetalhesDadosPagamento
(
	@cod_dados_pagamento	int
)

as

SET NOCOUNT ON

SELECT	[cod_dados_pagamento],
	[num_cpf],
	[num_cheque],
	[dat_emissao],
	[qtd_dias_atraso],
	[val_cheque],
	[val_encargos_atraso],
	[val_desconto],
	[val_total]
FROM	[CobCheque].[dbo].[tb_cobch_dados_pagto_detalhe] (nolock)
WHERE	(cod_dados_pagamento = @cod_dados_pagamento)

SET NOCOUNT OFF



GO
