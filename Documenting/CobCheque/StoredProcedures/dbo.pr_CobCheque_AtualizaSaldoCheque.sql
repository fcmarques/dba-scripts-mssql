SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição          : Stored Procedure para Atualizar Saldo de Cheque
Autor                : Fernando S. Jaconete
Data                 : 22/09/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

CREATE PROCEDURE dbo.pr_CobCheque_AtualizaSaldoCheque(
	@NUM_CPF decimal(15,0)
	,@NUM_CHEQUE VARCHAR(20)
	,@val_cheque_dinamico decimal(12,2)
)
AS
set nocount on
BEGIN
		UPDATE  dbo.tb_cobch_cheque SET
			val_cheque_dinamico = (val_cheque_dinamico - @val_cheque_dinamico)
		WHERE
			NUM_CPF = @NUM_CPF
			AND NUM_CHEQUE = @NUM_CHEQUE

END
set nocount off


GO
