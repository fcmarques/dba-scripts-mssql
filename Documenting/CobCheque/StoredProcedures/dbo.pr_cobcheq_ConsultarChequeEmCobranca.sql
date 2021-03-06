SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/* 
Descrição          : Stored Procedure que  Retorna os dados do cheque em cobrança
Autor                : Jeovane Maciel    
Data                 : 21/06/2006    
Empresa           : B2Br
Projeto              : CobCheque
*/

CREATE PROCEDURE dbo.pr_cobcheq_ConsultarChequeEmCobranca(    
 @NUM_CPF decimal(15,0)    
 ,@NUM_CHEQUE VARCHAR(20) = NULL    
)    
AS    
set nocount on
BEGIN    
 --// ---------------------------------------------------    
 --// SELECIONA O CLIENTE DA BASE    
 --// ---------------------------------------------------    
  SELECT     
   cheque.num_cheque    
   ,cheque.num_cpf    
   ,cheque.cod_motivo_devolucao    
   ,devolucao.desc_motivo_devolucao    
   ,cheque.num_conta    
   ,cheque.num_agencia    
   ,cheque.cod_banco    
   ,cheque.val_cheque    
   ,cheque.val_cheque_dinamico    
   ,cheque.num_cupom    
   ,cheque.cod_loja    
   ,empresa.nom_fantasia    
   ,cheque.dat_movimento    
   ,cheque.dat_importacao    
   ,cheque.dat_lucros_perdas    
   ,cheque.dat_recebido_filial    
   ,cheque.dat_enviado_filial    
   ,datediff(d,cheque.dat_movimento,getdate()) as dias_atraso    
  FROM dbo.tb_cobch_cheque cheque  (nolock)  
  LEFT JOIN dbo.tb_cobch_motivo_devolucao devolucao  (nolock)   
   ON cheque.cod_motivo_devolucao = devolucao.cod_motivo_devolucao    
  LEFT JOIN sicc.dbo.c_empresa_filial empresa (nolock)    
   ON cheque.cod_loja = empresa.cod_fil    
  WHERE    
   (NUM_CPF = @NUM_CPF OR @NUM_CPF IS NULL)    
   AND (@NUM_CHEQUE IS NULL OR NUM_CHEQUE = @NUM_CHEQUE)

ORDER BY cheque.num_cpf, cheque.dat_movimento
   
END  
set nocount off



GO
