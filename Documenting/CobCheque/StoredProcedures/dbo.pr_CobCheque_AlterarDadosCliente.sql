SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



/* 
Descrição          : Stored Procedure para alterar dados do cliente
Autor                : Fernando S. Jaconete
Data                 : 22/09/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

create procedure dbo.pr_CobCheque_AlterarDadosCliente(
	@num_cpf 			decimal(15,0), 
	@cod_cliente 			int,
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
	@cod_titular 			int,
	@num_substituicao 		int, 
	@num_digito			char(1)
)
as
	UPDATE tb_cobch_cliente
	SET
	num_cpf 		=	@num_cpf 	,
	cod_cliente		=	@cod_cliente 	,
	num_rg 			=	@num_rg 	,
	nom_cliente 		=	@nom_cliente 	,
	desc_logradouro 	=	@desc_logradouro 	,
	desc_tipo_logradouro 	=	@desc_tipo_logradouro 	,
	num_endereco 		=	@num_endereco 	,
	desc_complemento 	=	@desc_complemento 	,
	desc_bairro 		=	@desc_bairro 	,
	desc_cidade 		=	@desc_cidade 	,
	desc_uf 		=	@desc_uf 	,
	num_cep 		=	@num_cep 	,
	num_ddd_contato 	=	@num_ddd_contato 	,
	num_tel_contato 	=	@num_tel_contato 	,
	num_ddd_comercial 	=	@num_ddd_comercial 	,
	num_tel_comercial 	=	@num_tel_comercial 	,
	num_ramal_comercial 	=	@num_ramal_comercial 	,
	cod_empresa		=	@cod_empresa	,
	cod_filial		=	@cod_filial 	,	
	cod_titular		=	@cod_titular 	,
	num_substituicao	=	@num_substituicao 	,
	num_digito		=	@num_digito	
	WHERE num_cpf = @num_cpf



GO
