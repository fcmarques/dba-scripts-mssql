SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/* 
Descrição          : Stored Procedure para boleto e verificar existencia
Autor                : Fernando S. Jaconete
Data                 : 04/07/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

create procedure dbo.pr_CobCheque_AdicionarDesconto(  
  @cod_empresa   int,  
  @cod_filial  int,  
  @dat_vigencia_inicial datetime,  
  @dat_vigencia_final datetime,  
  @num_dias_de  int,  
  @num_dias_ate  int,  
  @pct_principal  decimal(5,2),  
  @pct_encargo  decimal(5,2),  
  @nom_login_responsavel varchar(15),  
  @dat_atualizacao datetime)  
  
AS  

INSERT INTO dbo.tb_cobch_desconto (  
 cod_empresa,   
 cod_filial,   
 dat_vigencia_inicial,   
 dat_vigencia_final,   
 num_dias_de,   
 num_dias_ate,   
 pct_principal,   
 pct_encargo,   
 nom_login_responsavel,   
 dat_atualizacao)  
 VALUES  
 (  
 @cod_empresa,  
 @cod_filial,  
 @dat_vigencia_inicial,  
 @dat_vigencia_final,  
 @num_dias_de,  
 @num_dias_ate,  
 @pct_principal,  
 @pct_encargo,  
 @nom_login_responsavel,  
 @dat_atualizacao)  



GO
