SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Seleciona Ultima Vigência de uma filial
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

CREATE procedure dbo.pr_CobCheque_SelecionarUltimaVigencia  
  (@cod_empresa   int = null,  
  @cod_loja   int,  
  @dat_inicio_vigencia  datetime)  
    
AS  
set nocount on


	select top 1 cod_empresa, 
	cod_filial, 
	dat_vigencia_inicial, 
	dat_vigencia_final   
	
	from dbo.tb_cobch_desconto (nolock)  

	where dat_vigencia_final < @dat_inicio_vigencia  
	  and (cod_empresa = @cod_empresa or @cod_empresa is null)   
	  and cod_filial = @cod_loja  
	
	order by dat_vigencia_inicial desc  

set nocount off



GO
