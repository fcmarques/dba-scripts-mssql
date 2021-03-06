SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Incluir dados cadastrais de cliente
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_IncluirCliente(
	@num_cpf 			decimal(15,0), 
	@num_rg 			varchar(15), 
	@nom_cliente 			varchar(60), 
	@desc_logradouro 		varchar(60), 
	@desc_tipo_logradouro 		varchar(11), 
	@num_endereco 			varchar(5), 
	@desc_complemento 		varchar(30), 
	@desc_bairro 			varchar(30), 
	@desc_cidade 			varchar(30), 
	@desc_uf 			char(2), 
	@num_cep 			decimal(18,0), 
	@num_ddd_contato 		char(4), 
	@num_tel_contato 		char(9), 
	@num_ddd_comercial 		char(4), 
	@num_tel_comercial 		char(9), 
	@num_ramal_comercial 		varchar(5), 
	@cod_empresa			int,
	@cod_filial 			int, 
	@cod_cliente 			int,
	@cod_titular 			int,
	@num_substituicao 		int, 
	@num_digito			char(1)	
)
as
set nocount on
	INSERT INTO [CobCheque].[dbo].[tb_cobch_cliente]
	([num_cpf], 
	[num_rg], 
	[nom_cliente], 
	[desc_logradouro], 
	[desc_tipo_logradouro], 
	[num_endereco], 
	[desc_complemento], 
	[desc_bairro], 
	[desc_cidade], 
	[desc_uf], 
	[num_cep], 
	[num_ddd_contato], 
	[num_tel_contato], 
	[num_ddd_comercial], 
	[num_tel_comercial], 
	[num_ramal_comercial], 
	[cod_empresa], 
	[cod_filial], 
	[cod_cliente], 
	[cod_titular], 
	[num_substituicao], 
	[num_digito])
	VALUES
	(@num_cpf, 
	@num_rg, 
	@nom_cliente, 
	@desc_logradouro, 
	@desc_tipo_logradouro, 
	@num_endereco, 
	@desc_complemento, 
	@desc_bairro, 
	@desc_cidade, 
	@desc_uf, 
	@num_cep, 
	@num_ddd_contato, 
	@num_tel_contato, 
	@num_ddd_comercial, 
	@num_tel_comercial, 
	@num_ramal_comercial, 
	@cod_empresa,
	@cod_filial, 
	@cod_cliente,
	@cod_titular,
	@num_substituicao, 
	@num_digito)
set nocount off


GO
