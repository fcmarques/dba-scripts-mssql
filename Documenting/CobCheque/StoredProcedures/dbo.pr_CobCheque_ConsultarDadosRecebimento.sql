SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Consulta dados de Recebimento
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_ConsultarDadosRecebimento(
	@num_cpf		decimal(15,0)
)
as
set nocount on
	SELECT 	[cod_recebimento], 
		[cod_dados_pagamento], 
		[num_cpf], 
		[cod_filial], 
		[dat_recebimento], 
		[cod_origem], 
		[num_caixa], 
		[val_recebimento], 
		[num_documento], 
		[cod_operador], 
		[dat_atualizacao] 
	FROM 	[CobCheque].[dbo].[tb_cobch_recebimento] (nolock)
	WHERE	num_cpf = @num_cpf
set nocount off


GO
