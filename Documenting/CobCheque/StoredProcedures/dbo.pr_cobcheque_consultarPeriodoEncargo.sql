SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Consulta Período do Encargo
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

CREATE PROCEDURE dbo.pr_cobcheque_consultarPeriodoEncargo(  
 @codEmpresa INT  
 ,@codFilial INT  
 ,@dataInicio DATETIME  
 ,@dataFinal DATETIME  
)  
  
AS  
set nocount on
BEGIN  
  
 SELECT DISTINCT  
  encargo.cod_empresa  
  ,encargo.cod_filial  
  ,empresa.nom_fantasia  
  ,encargo.dat_vigencia_inicial  
  ,encargo.dat_vigencia_final    
 FROM   
  tb_cobch_encargo encargo  (nolock)  
  inner join sicc.dbo.c_empresa_filial empresa (nolock)  
   on encargo.cod_filial = empresa.cod_fil  
 WHERE   
 -- // intersecção pelo dia minimo  
  ((@dataInicio between dat_vigencia_inicial and dat_vigencia_final)  
  OR  
 -- // intersecção pelo dia máximo  
  (@dataFinal between  dat_vigencia_inicial and dat_vigencia_final))  
  AND (@codFilial = cod_filial)  
  AND (@codEmpresa = cod_empresa)  
END  
set nocount off


GO
