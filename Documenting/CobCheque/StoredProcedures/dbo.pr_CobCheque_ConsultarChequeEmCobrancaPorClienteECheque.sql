SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Consulta cheques por cliente e cheque
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

CREATE PROCEDURE dbo.pr_CobCheque_ConsultarChequeEmCobrancaPorClienteECheque(                
 @NUM_CPF decimal(15,0) = null                
 ,@cheque varchar(20) = NULL                
)                
AS                
set nocount on
BEGIN                
   SELECT                 
   cheque.num_cheque                
   ,cheque.num_cpf                
   ,cheque.cod_motivo_devolucao                
   ,motivo.desc_motivo_devolucao                
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
  LEFT JOIN dbo.tb_cobch_motivo_devolucao motivo (nolock)               
   ON cheque.cod_motivo_devolucao = motivo.cod_motivo_devolucao                
  LEFT JOIN sicc.dbo.c_empresa_filial empresa   (nolock)             
   ON cheque.cod_loja = empresa.cod_fil                
  WHERE                
   (NUM_CPF = @NUM_CPF OR @NUM_CPF IS NULL)                
   AND (@cheque IS NULL OR cheque.num_cheque = @cheque)            
   AND cheque.val_cheque_dinamico > 0            
            
ORDER BY num_cpf, dat_movimento            
               
END  

set nocount off
  

GO
