SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Gera Codigo para Tabela DadosPagamento
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

CREATE PROCEDURE [dbo].[pr_CobCheque_GeraCodigoDadosPagamento] 
AS    
set nocount on
	select max(cod_dados_pagamento) as codigo 
	from tb_cobch_dados_pagamento (nolock)  
set nocount off


GO
