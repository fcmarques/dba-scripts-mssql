SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Inclui dados detalhados de pagamento referente a boleto
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

CREATE PROCEDURE [dbo].[pr_CobCheque_InsereDetalheBoletoDadosPagamento](
	@cod_dados int,
	@cpf decimal,
	@cheque varchar(20),
	@dt_emissao datetime,
	@dias_atraso int,
	@val_cheque decimal,
	@val_encargos_atraso decimal,
	@val_desconto decimal,
	@val_total decimal
)
AS
SET NOCOUNT ON

	insert into tb_cobch_dados_pagto_detalhe
	(cod_dados_pagamento,
	num_cpf,
	num_cheque,
	dat_emissao,
	qtd_dias_atraso,
	val_cheque,
	val_encargos_atraso,
	val_desconto,
	val_total)
	values
	(@cod_dados ,
	@cpf ,
	@cheque ,
	@dt_emissao ,
	@dias_atraso ,
	@val_cheque ,
	@val_encargos_atraso ,
	@val_desconto ,
	@val_total )
SET NOCOUNT OFF


GO
