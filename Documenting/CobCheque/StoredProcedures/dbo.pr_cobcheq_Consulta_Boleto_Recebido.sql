SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/* 
Descrição          : Stored Procedure para consultar boleto recebido
Autor                : Fernando S. Jaconete
Data                 : 22/09/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

CREATE PROCEDURE [dbo].[pr_cobcheq_Consulta_Boleto_Recebido]
(
@cod_dados_pagamento int      
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

	from tb_cobch_dados_pagamento  (nolock)    

	where cod_dados_pagamento = @cod_dados_pagamento      
	and cod_dados_pagamento in 
		(select cod_dados_pagamento 
			from tb_cobch_recebimento 
		where cod_dados_pagamento = @cod_dados_pagamento)    
set nocount off


GO
