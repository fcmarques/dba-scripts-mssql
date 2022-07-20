SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Inclui dados do Recibo
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_IncluirRecibo

as
SET NOCOUNT ON
	INSERT INTO [CobCheque].[dbo].[tb_cobch_recibo]
		(dat_inclusao)
	VALUES( Getdate() )

	SELECT CAST(@@Identity AS INTEGER)
SET NOCOUNT OFF


GO
