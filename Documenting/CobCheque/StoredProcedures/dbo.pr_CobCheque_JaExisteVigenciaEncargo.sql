SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição          : Consulta Vigencia para verificar existencia
Autor                : Fernando
Data                 : 26/09/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

create procedure dbo.pr_CobCheque_JaExisteVigenciaEncargo(      
 @cod_loja   int,      
 @dat_inicio_vigencia  datetime,      
 @dat_fim_vigencia datetime)      
      
AS      
    
set nocount on      
    
 declare @num int      
 declare @existe bit      
 select @num = count(cod_filial)      

 FROM dbo.tb_cobch_encargo (nolock)      
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
