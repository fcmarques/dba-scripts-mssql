SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Consulta Filiais
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

CREATE proc [dbo].[pr_sicc_ConsultarFiliais]   
AS  
set nocount on  
   
 select c_empresa_filial.cod_fil as CodFilial, c_empresa_filial.nom_fantasia as NomeFilial  
 from c_empresa_filial with (nolock)  
 where c_empresa_filial.ind_ativa = 'S'  
 and c_empresa_filial.cod_fil <> 999  
 and c_empresa_filial.cod_fil <> 220  
 order by c_empresa_filial.nom_fantasia  
  
set nocount off  


GO
