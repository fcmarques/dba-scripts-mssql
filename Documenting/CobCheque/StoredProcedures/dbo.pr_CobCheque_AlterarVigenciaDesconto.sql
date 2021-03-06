SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição          : Stored Procedure para alterar a Vigencia para Desconto
Autor                : Fernando S. Jaconete
Data                 : 04/07/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

create procedure dbo.pr_CobCheque_AlterarVigenciaDesconto(  
 @cod_empresa   INT  
 ,@cod_filial   INT  
 ,@dat_inicial_ANTERIOR  DATETIME  
 ,@dat_final_ANTERIOR  DATETIME  
 ,@dat_inicial_ATUAL  DATETIME  
 ,@dat_final_ATUAL  DATETIME  
 ,@nom_login_responsavel  VARCHAR(15)  
)  
AS  
set nocount on

 UPDATE tb_cobch_desconto  
 SET  
  dat_vigencia_inicial    = @dat_inicial_ATUAL  
  ,dat_vigencia_final = @dat_final_ATUAL  
  ,nom_login_responsavel = @nom_login_responsavel  
  ,dat_atualizacao = GETDATE()  
  
 WHERE cod_empresa = @cod_empresa  
  AND cod_filial = @cod_filial  
  AND dat_vigencia_inicial = @dat_inicial_ANTERIOR  
  AND dat_vigencia_final = @dat_final_ANTERIOR  

set nocount off


GO
