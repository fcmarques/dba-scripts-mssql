SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
DescriþÒo	: Insere dados do recebimento
Autor		: Marcelo Brefore
Data		: 09/08/2006
Empresa		: B2Br
Projeto		: SICC New / sicc
*/

-- TRANSFERIDO EM 02/02/2007 10:26:56
CREATE  PROCEDURE [dbo].[pr_CobCheque_InsereRecebimento](
	@cod_dados_pagamento int,
	@num_cpf bigint,
	@cod_filial int,
	@dat_recebimento datetime,
	@cod_origem int,
	@num_caixa int,
	@val_recebimento decimal(12,2),
	@num_documento bigint,
	@cod_operador bigint,
	@dat_atualizacao datetime
)
AS
SET NOCOUNT ON

	insert into tb_cobch_recebimento
		(cod_dados_pagamento,
		num_cpf,
		cod_filial,
		dat_recebimento,
		cod_origem,
		num_caixa,
		val_recebimento,
		num_documento	,
		cod_operador,
		dat_atualizacao)
	values
		(@cod_dados_pagamento ,
		@num_cpf ,
		@cod_filial ,
		@dat_recebimento ,
		@cod_origem ,
		@num_caixa ,
		@val_recebimento ,
		@num_documento ,
		@cod_operador ,
		@dat_atualizacao )

	SELECT @@IDENTITY

SET NOCOUNT OFF





GO
