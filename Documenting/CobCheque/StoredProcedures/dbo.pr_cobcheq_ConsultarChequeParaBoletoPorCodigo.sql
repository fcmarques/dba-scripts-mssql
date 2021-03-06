SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/* 
Descrição          : Stored Procedure para Retorna os dados do cheque para um boleto especifico
Autor                : Fernando S. Jaconete
Data                 : 27/07/2006    
Empresa           : B2Br
Projeto              : CobCheque
*/

    
CREATE PROCEDURE dbo.pr_cobcheq_ConsultarChequeParaBoletoPorCodigo(    
 @cod_dados_pagamento int    
)    
AS    
set nocount on
BEGIN    
--// ---------------------------------------------------    
--// SELECIONA O CLIENTE DA BASE    
--// ---------------------------------------------------    
 SELECT cheque.num_cheque, cheque.num_cpf, cheque.cod_motivo_devolucao, motivo.desc_motivo_devolucao    
 , ISNULL(cheque.num_conta,'0') num_conta, ISNULL(cheque.num_agencia,'0') num_agencia    
 , cheque.cod_banco,  cheque.num_cupom, cheque.cod_loja    
 , empresa.nom_fantasia, cheque.dat_movimento, cheque.dat_importacao, cheque.dat_lucros_perdas    
 , cheque.dat_recebido_filial, cheque.dat_enviado_filial, cheque.val_cheque_dinamico, detalhe.dat_emissao, detalhe.qtd_dias_atraso, detalhe.val_cheque, detalhe.val_encargos_atraso, detalhe.val_desconto, detalhe.val_total,    
 datediff(d,cheque.dat_movimento,getdate()) dias_atraso    
 FROM dbo.tb_cobch_cheque cheque, dbo.tb_cobch_motivo_devolucao motivo, sicc.dbo.c_empresa_filial empresa,    
 tb_cobch_dados_pagto_detalhe detalhe  (nolock)  
 where cheque.cod_motivo_devolucao = motivo.cod_motivo_devolucao    
 and cheque.cod_loja = empresa.cod_fil    
 and cheque.num_cheque = detalhe.num_cheque    
 and detalhe.cod_dados_pagamento = @cod_dados_pagamento    
END  
set nocount off  


GO
