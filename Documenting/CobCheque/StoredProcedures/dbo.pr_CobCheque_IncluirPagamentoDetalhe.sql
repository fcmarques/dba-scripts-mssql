SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Inclui Dados dos Detalhes de Pagamento
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/
create procedure dbo.pr_CobCheque_IncluirPagamentoDetalhe(
		@cod_pagamento int,
		@num_cpf decimal(15),
		@num_cheque varchar(20),
		@dat_emissao datetime,
		@qtd_dias_atraso int,
		@val_cheque decimal (12,2),
		@val_encargos_atraso decimal (12,2), 
		@val_desconto decimal (12,2),
		@val_total decimal (12,2)
)
as
set nocount on

	INSERT INTO [CobCheque].[dbo].[tb_cobch_dados_pagto_detalhe]
		(cod_dados_pagamento,
		num_cpf,
		num_cheque,
		dat_emissao,
		qtd_dias_atraso,
		val_cheque,
		val_encargos_atraso,
		val_desconto,
		val_total)
	VALUES(
		@cod_pagamento,
		@num_cpf,
		@num_cheque,
		@dat_emissao,
		@qtd_dias_atraso,
		@val_cheque,
		@val_encargos_atraso, 
		@val_desconto,
		@val_total )
	
set nocount off



GO
