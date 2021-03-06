SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/* 
Descrição	: Consulta motivo de devolução de cheque pesquisado por codigo de motivo
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/
create procedure dbo.pr_CobCheque_ConsultarMotivoDevolucaoCheque(
	@cod_motivo_devolucao  decimal(5,0) = null
)
as
set nocount on

	SELECT 	[cod_motivo_devolucao], 
		[desc_motivo_devolucao] 
	FROM [CobCheque].[dbo].[tb_cobch_motivo_devolucao] (nolock)
	WHERE cod_motivo_devolucao = @cod_motivo_devolucao or @cod_motivo_devolucao is null

set nocount off


GO
