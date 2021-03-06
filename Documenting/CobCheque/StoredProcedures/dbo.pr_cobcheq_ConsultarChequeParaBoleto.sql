SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/* 
Descrição          : Stored Procedure para Retorna os dados do cheque em cobrança para um boleto especifico
Autor                : Fernando S. Jaconete
Data                 : 07/07/2006 
Empresa           : B2Br
Projeto              : CobCheque
*/

CREATE PROCEDURE dbo.pr_cobcheq_ConsultarChequeParaBoleto(    
 @cod_dados_pagamento int
)    
AS    
set nocount on
BEGIN    
 SELECT cheque.num_cheque, 
	cheque.num_cpf, 
	cheque.cod_motivo_devolucao, 
	motivo.desc_motivo_devolucao, 
	ISNULL(cheque.num_conta,'0') num_conta, 
	ISNULL(cheque.num_agencia,'0') num_agencia, 
	cheque.cod_banco,  
	cheque.num_cupom, 
	cheque.cod_loja, 
	empresa.nom_fantasia, 
	cheque.dat_movimento, 
	cheque.dat_importacao, 
	cheque.dat_lucros_perdas, 
	cheque.dat_recebido_filial, 
	cheque.dat_enviado_filial, 
	cheque.val_cheque_dinamico, 
	detalhe.dat_emissao, 
	detalhe.qtd_dias_atraso, 
	detalhe.val_cheque, 
	detalhe.val_encargos_atraso, 
	detalhe.val_desconto, 
	detalhe.val_total,    
	datediff(d,cheque.dat_movimento,getdate()) dias_atraso    

	FROM tb_cobch_dados_pagto_detalhe detalhe  (nolock)  
	inner join		
		tb_cobch_cheque cheque (nolock)
	on
		 cheque.num_cheque = detalhe.num_cheque    
	  and    cheque.num_cpf  = detalhe.num_cpf
	inner join 
		tb_cobch_motivo_devolucao motivo (nolock)  
	on 
		motivo.cod_motivo_devolucao = cheque.cod_motivo_devolucao
	inner join  
		sicc.dbo.c_empresa_filial empresa (nolock)  
	on
		cheque.cod_loja = empresa.cod_fil    
	where 
	 	detalhe.cod_dados_pagamento = @cod_dados_pagamento
		
END  
  set nocount off


GO
