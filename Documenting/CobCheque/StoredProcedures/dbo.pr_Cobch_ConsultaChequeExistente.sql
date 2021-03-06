SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/* 
Descrição            : Stored Procedure para boleto e verificar existencia
Autor                : Fernando S. Jaconete
Data                 : 22/09/2006
Empresa              : B2Br
Projeto              : CobCheque
*/
create procedure [dbo].[pr_Cobch_ConsultaChequeExistente]
(
@cpf as decimal,
@num_cheque as varchar(20)
)
as

set nocount on

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
		(NUM_CPF = @cpf)  AND
	        (cheque.num_cheque = @num_cheque)

set nocount off



GO
