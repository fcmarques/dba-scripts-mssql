SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/* 
Descrição	: Efetua pesquisa de Vigência para Verificar Existência
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_JaExisteVigencia(  
 @cod_loja   int,  
 @dat_inicio_vigencia  datetime,  
 @dat_fim_vigencia datetime)  
  
AS  

set nocount on  

 declare @num int  
 declare @existe bit  
 select @num = count(cod_filial)  
 FROM dbo.tb_cobch_desconto (nolock)  
 where  cod_filial = @cod_loja   
   and ((dat_vigencia_inicial <= @dat_inicio_vigencia  
  and dat_vigencia_final >= @dat_inicio_vigencia)   
  or (dat_vigencia_inicial >= @dat_inicio_vigencia and dat_vigencia_final <= @dat_fim_vigencia))  
  
 if (@num > 0)  
 begin  
  set @existe = 1  
 end  
 else  
 begin  
  set @existe = 0  
 end  
 select @existe ja_existe  
  
set nocount off



GO
