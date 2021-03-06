SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Insere dados Resumo de pagamento referente a boleto
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

CREATE  PROCEDURE [dbo].[pr_CobCheque_InsereResumoBoletoDadosPagamento](
	@cod_dados int,
	@cpf decimal,
	@cod_filial int,
	@dt_emissao datetime,
	@algoritmo int,
	@val_cheque decimal,
	@val_encargos_atraso decimal,
	@val_desconto decimal,
	@val_total decimal,
	@cod_autorizacao int,
	@login_resp varchar,
	@dt_atualizacao datetime
)
AS
SET NOCOUNT ON

	insert into tb_cobch_dados_pagamento
	(cod_dados_pagamento,
	num_cpf,
	cod_filial_emissao,
	dat_emissao,
	num_algoritmo,
	val_cheque,
	val_encargos_atraso,
	val_desconto,
	val_total,
	cod_autorizacao,
	nom_login_responsavel,
	dat_atualizacao)
	values
	(@cod_dados,
	@cpf,
	@cod_filial,
	@dt_emissao,
	@algoritmo,
	@val_cheque,
	@val_encargos_atraso,
	@val_desconto,
	@val_total,
	@cod_autorizacao,
	@login_resp,
	@dt_atualizacao)
SET NOCOUNT OFF


GO
