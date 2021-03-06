SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/* 
Descrição          : Stored Procedure para Retorna os dados do cheque em cobrança pesquisados a partir do codigo do cliente.
Autor                : Fernando S. Jaconete
Data                 : 05/07/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

CREATE PROCEDURE dbo.pr_cobcheq_ConsultarChequeEmCobrancaPorCodigo(    
 @NUM_COD decimal(15,0)    
 ,@NUM_CHEQUE VARCHAR(20) = NULL    
)    
AS    
set nocount on
BEGIN    
  SELECT     
   cheque.num_cheque    
   ,cheque.num_cpf    
   ,cheque.cod_motivo_devolucao    
   ,motivo.desc_motivo_devolucao    
   ,ISNULL(cheque.num_conta,'0') num_conta    
   ,ISNULL(cheque.num_agencia,'0') num_agencia    
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
  FROM dbo.tb_cobch_cheque cheque  (nolock)  
  LEFT JOIN dbo.tb_cobch_motivo_devolucao motivo    (nolock)
   ON cheque.cod_motivo_devolucao = motivo.cod_motivo_devolucao    
  LEFT JOIN sicc.dbo.c_empresa_filial empresa   (nolock) 
   ON cheque.cod_loja = empresa.cod_fil    
  WHERE    
   NUM_CPF in (select num_cpf from tb_cobch_cliente     
     where (convert(varchar,cod_empresa) +     
     convert(varchar,cod_filial) +     
     convert(varchar,cod_cliente) +     
     convert(varchar,cod_titular) +     
     convert(varchar,num_substituicao) +     
     convert(varchar,num_digito)) = @NUM_COD)    
   AND (@NUM_CHEQUE IS NULL OR NUM_CHEQUE = @NUM_CHEQUE)    
END  
  set nocount off



GO
