SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Exclui determinado Cadastro de cheque de determinado cliente
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_ExcluirCadastroCheque(
	@num_cheque	varchar(20),
	@num_cpf	decimal(15,0)
)
as
set nocount on
	DELETE FROM [CobCheque].[dbo].[tb_cobch_cheque]
	WHERE num_cheque = @num_cheque 
	and num_cpf = @num_cpf
set nocount off


GO
