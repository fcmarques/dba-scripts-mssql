SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/* 
Descrição          : Stored Procedure para boleto e verificar existencia
Autor                : Fernando S. Jaconete
Data                 : 04/07/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

CREATE  proc dbo.pr_cobcheque_AdicionarEncargoDaFilial(  
 @CodigoEmpresa   INT,  
 @CodigoLoja   INT,  
 @InicioVigencia  DATETIME,  
 @FimVigencia   DATETIME,  
 @DiasMinimo   INT,  
 @DiasMaximo   INT,  
 @PercentualEncargosMes  DECIMAL(5,2),  
 @NomeUsuarioAlteracao  VARCHAR(15),  
 @DataAlteracao   DATETIME  
)  
AS  
  
BEGIN  
  
 BEGIN TRAN  
  
  INSERT INTO tb_cobch_encargo (  
   cod_empresa  
   ,cod_filial  
   ,dat_vigencia_inicial  
   ,dat_vigencia_final  
   ,num_dias_de  
   ,num_dias_ate  
   ,pct_encargo  
   ,nom_login_responsavel  
   ,dat_atualizacao  
   )  
  VALUES (  
   @CodigoEmpresa  
   ,@CodigoLoja  
   ,@InicioVigencia  
   ,@FimVigencia  
   ,@DiasMinimo  
   ,@DiasMaximo  
   ,@PercentualEncargosMes  
   ,@NomeUsuarioAlteracao  
   ,@DataAlteracao  
  )  
  
  
 IF @@ERROR <> 0   
 BEGIN  
  RAISERROR('Não foi possível incluir o encargo.',16,1)  
  ROLLBACK TRAN  
  RETURN  
 END  
  
 --// ATUALIZA A DATA FINAL DA VIGÊNCIA ANTERIOR  
 --// QUANDO HOUVER    
  
 DECLARE @ultimaVigencia DATETIME  
   
 SELECT TOP 1 @ultimaVigencia = dat_vigencia_final  
 FROM tb_cobch_encargo (nolock)  
 WHERE   
  cod_empresa = @CodigoEmpresa  
  and cod_filial = @CodigoLoja  
  and dat_vigencia_final < @InicioVigencia  
 ORDER BY dat_vigencia_final DESC  
   
 IF @ultimaVigencia IS NOT NULL  
 BEGIN  
  UPDATE tb_cobch_encargo  
  SET dat_vigencia_final = dateadd(d, -1, @InicioVigencia)  
  WHERE dat_vigencia_final = @ultimaVigencia  
   AND cod_empresa = @CodigoEmpresa  
   AND cod_filial = @CodigoLoja  
--   print 'Ultimo periodo termina em: ' + isnull(cast(@ultimaVigencia as varchar),'nenhum')  
--   print 'Nova data de último periodo: ' + cast(dateadd(d, -1, @InicioVigencia) as varchar)  
 END  
  
 IF @@ERROR <> 0   
 BEGIN  
  RAISERROR('Não foi possível atualizar a vigencia anterior.',16,1)  
  ROLLBACK TRAN  
  RETURN  
 END  
  
 COMMIT TRAN  
 RETURN  
  
END  



GO
