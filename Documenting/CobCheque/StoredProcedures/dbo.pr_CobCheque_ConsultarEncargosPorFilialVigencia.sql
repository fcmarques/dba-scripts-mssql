SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Obtem autorizações que foram processadas no dia para o cliente selecionado
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/
CREATE procedure dbo.pr_CobCheque_ConsultarEncargosPorFilialVigencia
	 @cod_empresa 		int = null
	,@cod_loja 		int
	,@dat_inicio_vigencia 	datetime = null
	,@dat_fim_vigencia	datetime = null
	,@num_dias_de		int = null
	,@num_dias_ate		int = null
AS

set nocount on 

SELECT 
	 cod_empresa
	,cod_filial
	,dat_vigencia_inicial as dat_vigencia_inicial
	,dat_vigencia_final as dat_vigencia_final
	,num_dias_de
	,num_dias_ate
	,pct_encargo
	,nom_login_responsavel
	,dat_atualizacao as dat_atualizacao

FROM 
	dbo.tb_cobch_encargo (nolock)
where 
	(@cod_empresa is null or @cod_empresa = cod_empresa)
and  cod_filial = @cod_loja   
and  (@dat_inicio_vigencia is null or @dat_inicio_vigencia = dat_vigencia_inicial)  
and  (@dat_fim_vigencia is null or @dat_fim_vigencia = dat_vigencia_final)  
and  (@num_dias_de is null or @num_dias_de = num_dias_de)  
and  (@num_dias_ate is null or @num_dias_ate = num_dias_ate)  

set nocount off


GO
