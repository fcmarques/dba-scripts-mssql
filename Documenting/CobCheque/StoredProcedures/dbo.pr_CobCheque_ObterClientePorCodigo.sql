SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: obtem cliente por código
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

CREATE procedure dbo.pr_CobCheque_ObterClientePorCodigo(        
		 @codEmpresa int,  
		 @codFilial int,  
		 @codCliente int,  
		 @codTitular int,  
		 @numSubstituicao int,  
		 @numDigito int  
)        
as       
set nocount on       
	select  num_cpf, 
		num_rg, 
		nom_cliente, 
		desc_logradouro, 
		desc_tipo_logradouro,         	
		num_endereco, 
		desc_complemento, 
		desc_bairro, 
		desc_cidade, 
		desc_uf,         
		num_cep, 
		num_ddd_contato, 
		num_tel_contato, 
		num_ddd_comercial,         
		num_tel_comercial, 
		num_ramal_comercial, 
		cod_empresa, 
		cod_filial,         
		cod_cliente, 
		cod_titular, 
		num_substituicao, 
		num_digito        
from tb_cobch_cliente  (nolock)      

	where cod_empresa = @codEmpresa  
		and cod_filial = @codFilial  
		and cod_cliente = @codCliente  
		and cod_titular = @codTitular  
		and num_substituicao = @numSubstituicao  
		and num_digito = @numDigito  
	order by num_cpf desc      

set nocount off      



GO
