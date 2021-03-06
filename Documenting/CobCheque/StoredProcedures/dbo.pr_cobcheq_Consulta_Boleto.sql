SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/* 
Descrição          : Stored Procedure para Consulta cheques para Boleto
Autor                : Fernando S. Jaconete
Data                 : 22/09/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

CREATE PROCEDURE [dbo].[pr_cobcheq_Consulta_Boleto]
(
@cpf decimal(15,0)    
)     

AS    

set nocount on  

	select cod_dados_pagamento, 
	num_cpf, 
	cod_filial_emissao, 
	dat_emissao, 
	num_algoritmo, 
	val_cheque, 
	val_encargos_atraso, 
	val_desconto, 
	val_total, 
	cod_autorizacao, 
	nom_login_responsavel, 
	dat_atualizacao
	from dbo.tb_cobch_dados_pagamento (nolock)  

	where num_cpf = @cpf    
	and cod_dados_pagamento not in 
		(select cod_dados_pagamento from tb_cobch_recebimento where num_cpf = @cpf)  

set nocount off 


GO
