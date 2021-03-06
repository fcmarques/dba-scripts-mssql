SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/* 
Descrição          : Stored Procedure para Atualizar os dados do cheque em cobrança    
Autor                : Jeovane Maciel
Data                 : 04/07/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

CREATE  PROCEDURE dbo.pr_cobcheq_AtualizarChequeEmCobranca(
	@NUM_CPF decimal(15,0)
	,@NUM_CHEQUE VARCHAR(20)
	,@DAT_RECEBIDO_FILIAL DATETIME
)
AS
set nocount on
BEGIN
	UPDATE  dbo.tb_cobch_cheque SET
		dat_recebido_filial = @DAT_RECEBIDO_FILIAL
	WHERE
		NUM_CPF = @NUM_CPF
		AND NUM_CHEQUE = @NUM_CHEQUE
END
set nocount off



GO
