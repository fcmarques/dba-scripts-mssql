SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição          : Stored Procedure para atualizar Autorização Pendente
Autor                : Fernando S. Jaconete
Data                 : 22/09/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

create procedure dbo.pr_CobCheque_AtualizaAutorizacaoPendente(
	@num_cpf		decimal(15,0),
	@cod_autorizacao	int,
	@ind_autorizacao	char(1),
	@dat_atualizacao	datetime,
	@nom_login_responsavel  varchar(15)
	
)
as
set nocount on
	UPDATE [CobCheque].[dbo].[tb_cobch_autorizacao]
	SET 	[ind_autorizacao]=@ind_autorizacao,
		dat_atualizacao = @dat_atualizacao,
		nom_login_responsavel = @nom_login_responsavel
	WHERE num_cpf = @num_cpf and cod_autorizacao = @cod_autorizacao
set nocount off


GO
