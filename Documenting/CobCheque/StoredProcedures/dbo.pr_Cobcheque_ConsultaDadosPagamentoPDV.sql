SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
DescriþÒo	: Stored Procedure para Retorna os dados de Pagamento para o Processo de Baixa de Cheques
		  executado pelo PDV
Autor		: Fernando S. Jaconete
Data		: 04/10/2006
Empresa		: B2Br
Projeto		: CobCheque
*/

-- TRANSFERIDO EM 05/02/2007 10:46:58
CREATE  PROCEDURE dbo.pr_Cobcheque_ConsultaDadosPagamentoPDV
(
@codigo_pagamento int
)
as
set nocount on

select 	pagto.cod_dados_pagamento, 
	pagto.num_cpf, 
	pagto.cod_filial_emissao, 
	cheque.cod_banco,
	cheque.num_agencia,
	cheque.num_cheque,
	pagto_detalhe.val_cheque,
	pagto_detalhe.val_encargos_atraso,
	pagto_detalhe.val_desconto,
	pagto_detalhe.val_total,
	cheque.dat_lucros_perdas,
	cheque.cod_loja,
	cheque.dat_movimento, 
	cheque.dat_importacao
from tb_cobch_dados_pagamento pagto (nolock)
left join tb_cobch_dados_pagto_detalhe pagto_detalhe (nolock)
	on pagto.cod_dados_pagamento = pagto_detalhe.cod_dados_pagamento
	and pagto.num_cpf = pagto_detalhe.num_cpf
left join tb_cobch_cheque cheque (nolock)
	on pagto_detalhe.num_cheque = cheque.num_cheque
	and pagto.num_cpf = cheque.num_cpf
where
	pagto.cod_dados_pagamento = @codigo_pagamento

set nocount off



GO
