SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição          : Stored Procedure para cancelar negociação do Boleto
Autor                : Fernando S. Jaconete
Data                 : 22/09/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

CREATE PROCEDURE [dbo].[pr_CobCheque_cancelaNegociacaoBoleto] (
	@codigopagamento int
)
AS
set nocount on
	delete tb_cobch_dados_pagto_detalhe
	where cod_dados_pagamento = @codigopagamento
	
	delete tb_cobch_dados_pagamento
	where cod_dados_pagamento = @codigopagamento
set nocount off


GO
