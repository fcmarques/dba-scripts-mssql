SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Obtem os dados do cliente CobCheque com join no SICC
Autor		: Marcelo Brefore
Data		: 09/08/2006
Empresa		: B2Br
Projeto		: CobCheque
*/

CREATE procedure dbo.pr_CobCheque_ObterCliente(  
		@num_cpf decimal(15,0) = null,  
		@cod_cliente int = null  
  
)  
as  
  set nocount on
	select 
		CC.num_cpf, 
		CC.num_rg, 
		CC.nom_cliente, 
		CC.desc_logradouro, 
		CC.desc_tipo_logradouro,   
	  	CC.num_endereco, 
		CC.desc_complemento, 
		CC.desc_bairro, 
		CC.desc_cidade, 
		CC.desc_uf,   
		CC.num_cep, 
		CC.num_ddd_contato, 
		CC.num_tel_contato, 
		CC.num_ddd_comercial,   
  		CC.num_tel_comercial, 
		CC.num_ramal_comercial, 
		CC.cod_empresa, 
		CC.cod_filial,   
  		CC.cod_cliente, 
		CC.cod_titular, 
		CC.num_substituicao, 
		CC.num_digito  
	from tb_cobch_cliente CC (nolock)  
	where 	(num_cpf = @num_cpf or @num_cpf is null) and
		(cod_cliente = @cod_cliente or @cod_cliente is null)
  set nocount on



GO
