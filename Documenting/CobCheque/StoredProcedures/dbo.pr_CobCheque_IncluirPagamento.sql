SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Inclui dados de Pagamento
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_IncluirPagamento(
		@cod_pagamento int,
		@num_cpf decimal(15),
		@cod_filial_emissao int,
		@dat_emissao datetime,
		@num_algoritmo int,
		@val_cheque decimal (12,2),
		@val_encargos_atraso decimal (12,2), 
		@val_desconto decimal (12,2),
		@val_total decimal (12,2),
		@cod_autorizacao int,
		@nom_login_responsavel varchar(15),
		@dat_atualizacao datetime
)
as
set nocount on
	INSERT INTO [CobCheque].[dbo].[tb_cobch_dados_pagamento]
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
	VALUES(
		@cod_pagamento,
		@num_cpf,
		@cod_filial_emissao,
		@dat_emissao,
		@num_algoritmo,
		@val_cheque,
		@val_encargos_atraso, 
		@val_desconto,
		@val_total,
		@cod_autorizacao,
		@nom_login_responsavel,
		@dat_atualizacao  )
	
set nocount off



GO
