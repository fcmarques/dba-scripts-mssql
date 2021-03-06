SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Exclui determinada Autorização de um determinado cliente
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_ExcluirAutorizacaoPendente(
	@num_cpf		decimal(15,0),
	@cod_autorizacao	int
)
as
set nocount on
	DELETE FROM [CobCheque].[dbo].[tb_cobch_autorizacao]
	WHERE num_cpf = @num_cpf 
	and cod_autorizacao = @cod_autorizacao
set nocount off


GO
