SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição          : Stored Procedure para atualizar recebimento do Cheque
Autor                : Fernando S. Jaconete
Data                 : 22/09/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

create procedure dbo.pr_CobCheque_AtualizaDataRecebimentoCheque(
	@num_cpf		decimal(15,0),
	@num_cheque		varchar(20),		
	@dat_recebido_filial	datetime
)
as
set nocount on

	UPDATE 	[CobCheque].[dbo].[tb_cobch_cheque]
	SET 	[dat_recebido_filial]=	@dat_recebido_filial		
	WHERE 	num_cpf = @num_cpf and
		num_cheque = @num_cheque
set nocount off


GO
