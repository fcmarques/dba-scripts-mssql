SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição          : Stored Procedure para boleto e verificar existencia
Autor                : Fernando S. Jaconete
Data                 : 22/09/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

create procedure dbo.pr_CobCheque_AtualizarBaixaSICC(
	@cod_emp  int,
	@cod_fil int,
	@num_cli int,
	@data_cheque_cobranca datetime)
AS

	UPDATE SICC.dbo.c_autorizador_cliente
	SET dat_cheque_cobranca = @data_cheque_cobranca
	where cod_emp = @cod_emp and cod_fil = @cod_fil and num_cli = @num_cli

	UPDATE SICC.dbo.c_controle_saldo
	SET dat_cheque_cobranca = @data_cheque_cobranca
	where cod_emp = @cod_emp and cod_fil = @cod_fil and num_cli = @num_cli



GO
