SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

create  PROCEDURE dbo.pr_CobCheque_ImportaChequesEmCobranca

AS

BEGIN
	-- Declaração das variáveis utilizadas durante todo a procedure
	DECLARE	
		@codigo_cliente decimal(18,0), 
		@numero varchar(5), 
		@complemento varchar(45), 
		@bairro varchar(45), 
		@cidade varchar(30), 
		@uf char(2), 
		@cep varchar(10), 
		@complemento_cep varchar(3), 
		@identidade varchar(15), 
		@ddd  decimal(9,0), 
		@telefone varchar(20), 
		@telefone_comercial varchar(20), 
		@email varchar(65), 
		@cnpj_cpf varchar(15), 
		@razao_social varchar(60), 
		@endereco varchar(60), 
		@tam_endereco int,
		@codigo_cartao varchar(50), 
		@tipo_logradouro varchar(11), 
		@num_caracteres int, 
		@endereco_parte varchar(20),
		@conta varchar(20), 
		@agencia varchar(20), 
		@codigo_banco decimal(5,0), 
		@cheque varchar(20),
		@valor decimal(12,2), 
		@cupom decimal(9,0), 
		@codigo_loja decimal(5,0),
		@data_movimento datetime, 
		@motivo_devolucao_cheque decimal(5,0),
		@data_alteracao_devolucao datetime, 
		@tipo_devolucao_cheque char(1), 
		@descricao varchar(50),
		@data_ultima_importacao datetime, 
		@cod_empresa int, 
		@cod_filial int, 
		@cod_cliente int, 
		@cod_titular int,
		@num_substituicao int, 
		@num_digito int, 
		@tbrows int, 
		@contador int
	
	-- Resgata a data da última importação realizada -------------------------------------------
	SELECT @data_ultima_importacao = dat_ultima_importacao
	FROM TB_COBCH_PARAMETRO

	-- Declaração da tabela temporária que armazenará a consulta.
	DECLARE @tb_temp table (contador int identity(1,1), 
				codigo_cliente decimal(18,0), 
				numero varchar(5), 
				complemento varchar(45), 
				bairro varchar(45), 
				cidade varchar(30), 
				uf char(2), 
				cep varchar(10), 
				complemento_cep varchar(3), 
				identidade varchar(15), 
				ddd  decimal(9,0), 
				telefone varchar(20), 
				telefone_comercial varchar(20), 
				email varchar(65), 
				cnpj_cpf varchar(15), 
				razao_social varchar(60), 
				endereco varchar(60),
				codigo_cartao varchar(50),
				conta varchar(20), 
				agencia varchar(20), 
				codigo_banco decimal(5,0), 
				cheque varchar(20),
				valor decimal(12,2), 
				cupom decimal(9,0), 
				codigo_loja decimal(5,0),
				data_movimento datetime, 
				motivo_devolucao_cheque decimal(5,0),
				data_alteracao_devolucao datetime, 
				tipo_devolucao_cheque char(1), 
				descricao varchar(50))
	
	-- Insere na tabela temporária os dados do sistema de Filial ------------------------------------------------
	INSERT @tb_temp(codigo_cliente , 
			numero , 
			complemento , 
			bairro , 
			cidade , 
			uf , 
			cep , 
			complemento_cep , 
			identidade, 
			ddd  , 
			telefone , 
			telefone_comercial , 
			email , 
			cnpj_cpf , 
			razao_social , 
			endereco ,
			codigo_cartao ,
			conta , 
			agencia, 
			codigo_banco , 
			cheque ,
			valor , 
			cupom , 
			codigo_loja ,
			data_movimento , 
			motivo_devolucao_cheque ,
			data_alteracao_devolucao, 
			tipo_devolucao_cheque , 
			descricao)
	SELECT  cli.codigo_cliente, 
		cli.numero, 
		cli.complemento, 
		cli.bairro, 
		cli.cidade, 
		cli.uf, 
		cli.cep, 
		cli.complemento_cep, 
		cli.identidade, 
		cli.ddd, 
		cli.telefone, 
		cli.telefone_comercial, 
		cli.email, 
		cli.cnpj_cpf, 
		cli.razao_social, 
		cli.endereco,
		co.codigo_cartao,
		co.conta, 
		co.agencia, 
		co.codigo_banco, 
		co.cheque,
		co.valor, 
		co.cupom, 
		co.codigo_loja,
		co.data_movimento, 
		co.motivo_devolucao_cheque,
		co.data_alteracao_devolucao, 
		co.tipo_devolucao_cheque, 
		mo.descricao
	FROM 	RIACHU_DBAUTC.autcom.dbo.cliente cli
	INNER JOIN RIACHU_DBAUTC.autcom.dbo.item_cofre co   
		on cli.cnpj_cpf = co.codigo_cartao
	INNER JOIN RIACHU_DBAUTC.autcom.dbo.motivo_devolucao_cheque mo 
		on (mo.motivo_devolucao_cheque = co.motivo_devolucao_cheque and mo.tipo_devolucao_cheque = 'C')
	WHERE 	(co.codigo_fp = 1 or co.codigo_fp = 2) 
		and (co.tipo_devolucao_cheque = 'C')
		and (co.data_alteracao_devolucao > @data_ultima_importacao)
		and (co.cheque is not null)
		and (co.codigo_loja in(select 
						cast(cod_filial as decimal(5,0)) 
					from 
						dbo.tb_cobch_filial_implantacao (nolock)))
	ORDER BY co.data_alteracao_devolucao ASC





	
	-----------------------------------------------------------------------------------------------
	
	SELECT @tbrows = COUNT(codigo_cliente) FROM @tb_temp
	SET @contador = 1
	
	WHILE (@contador <= @tbrows)
	BEGIN
		--Seleciona uma tupla da tabela temporária e preenche as variáveis--------------
		SELECT 	@contador = contador, 
			@codigo_cliente = codigo_cliente , 
			@numero = numero , 
			@complemento = complemento , 
			@bairro = bairro , 
			@cidade = cidade , 
			@uf = uf , 
			@cep = cep , 
			@complemento_cep = complemento_cep , 
			@identidade = identidade, 
			@ddd = ddd  , 
			@telefone = telefone , 
			@telefone_comercial = telefone_comercial , 
			@email = email , 
			@cnpj_cpf = cnpj_cpf , 
			@razao_social = razao_social , 
			@endereco = endereco ,
			@codigo_cartao = codigo_cartao ,
			@conta = conta , 
			@agencia = agencia, 
			@codigo_banco = codigo_banco , 
			@cheque = cheque ,
			@valor = valor , 
			@cupom = cupom , 
			@codigo_loja = codigo_loja ,
			@data_movimento = data_movimento , 
			@motivo_devolucao_cheque = motivo_devolucao_cheque ,
			@data_alteracao_devolucao = data_alteracao_devolucao, 
			@tipo_devolucao_cheque = tipo_devolucao_cheque , 
			@descricao = descricao
		FROM @tb_temp
		WHERE contador = @contador
		
		--------------------------------------------------------------------------------
		--Inclui o cliente caso este ainda não esteja cadastrado.
		--Verifica através do CPF/CNPJ se a pessoa já está cadastrada no CobCheque
		IF (NOT EXISTS(SELECT 1
			FROM tb_cobch_cliente cl
			WHERE cl.num_cpf = @cnpj_cpf))
		BEGIN
			SET @cep = @cep + @complemento_cep
		
			--Retorna o tipo de logradouro e o número de caracteres que devem ser excluídos do 
			--endereço para que o logradouro seja armazenado -----------------------------------------
			SET @endereco_parte = SUBSTRING(LTRIM(@endereco),1,20)
			SELECT @tipo_logradouro = tipo, @num_caracteres = num_caract
			FROM dbo.ObtemTipoLogradouro(@endereco_parte)
			SET @endereco = LTRIM(@endereco)
			SET @tam_endereco = LEN(@endereco)
			------------------------------------------------------------------------------------------
		
			-- Inclui o cliente na base cobcheque
			INSERT INTO TB_COBCH_CLIENTE
					(num_cpf,
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
					num_tel_comercial)
			VALUES
					(Convert(decimal(15,0),@cnpj_cpf),
					@razao_social,
					Substring(@endereco,1+@num_caracteres,@tam_endereco),
					@tipo_logradouro,
					@numero,
					Substring(LTRIM(@complemento),1,30),
					Substring(LTRIM(@bairro),1,30),
					@cidade,
					@uf,
					Convert(varchar,@cep),
					Substring(LTRIM(@ddd),1,4),
					dbo.NormalizaTelefone(@telefone),
					Substring(LTRIM(@ddd),1,4),
					dbo.NormalizaTelefone(@telefone_comercial))
		
		END
		
		--Verifica se o cheque do cliente ainda não está cadastrado.
		IF (NOT EXISTS(select 1
			from tb_cobch_cheque cl
			where cl.num_cpf = @codigo_cartao and cl.num_cheque = @cheque))
		BEGIN
	
			--Inclui os dados do cheque 'EM COBRANCA'
			INSERT INTO TB_COBCH_CHEQUE
				(num_cpf,
				num_conta,
				num_agencia,
				cod_banco,
				num_cheque,
				val_cheque,
				val_cheque_dinamico,
				num_cupom,
				cod_loja,
				dat_movimento,
				dat_importacao,
				cod_motivo_devolucao)
			VALUES
				(Convert(decimal(15,0),@codigo_cartao),
				@conta,
				@agencia,
				@codigo_banco,
				@cheque,
				@valor,
				@valor,
				@cupom,
				Convert(int,@codigo_loja),
				@data_movimento,
				GetDate(),
				@motivo_devolucao_cheque)
		END
	
		--Verifica se a data da importação desse objeto é maior que a armazenada
		IF @data_ultima_importacao < @data_alteracao_devolucao
		BEGIN	
			set @data_ultima_importacao = @data_alteracao_devolucao
		END
	
		--Verifica se o motivo de devolução ainda não está armazenado
		IF (NOT EXISTS(SELECT 1 FROM TB_COBCH_MOTIVO_DEVOLUCAO WHERE cod_motivo_devolucao = @motivo_devolucao_cheque))
		BEGIN
			INSERT INTO TB_COBCH_MOTIVO_DEVOLUCAO(	cod_motivo_devolucao, 
								desc_motivo_devolucao)
			VALUES
				(@motivo_devolucao_cheque, 
				 @descricao)
		END
	
		--Verifica se o cliente possui cadastro no SICC
		IF (EXISTS(SELECT 1 from SICC.dbo.c_info_cadastro WHERE num_cpf = @cnpj_cpf))
		BEGIN
			SELECT 
				@cod_empresa = inf.cod_emp, 
				@cod_filial = inf.cod_fil, 
				@cod_cliente = inf.num_cli, 
				@cod_titular = ca.num_tit_cred, 
				@num_substituicao = ca.qtd_subs, 
				@num_digito = ca.num_dig
			FROM 	SICC.dbo.c_info_cadastro inf  (NOLOCK)
			INNER JOIN SICC.dbo.c_cartao ca  (NOLOCK) 
				ON (inf.cod_emp = ca.cod_emp 
				AND inf.cod_fil = ca.cod_fil
				AND inf.num_cli = ca.num_cli)
			WHERE inf.num_cpf = @cnpj_cpf 
	
			--Armazena os dados do cadastro do SICC no Cliente
			UPDATE TB_COBCH_CLIENTE 
			SET 	cod_empresa = @cod_empresa,
			 	cod_filial = @cod_filial,
			 	cod_cliente = @cod_cliente,
			 	cod_titular = @cod_titular,
			 	num_substituicao = @num_substituicao,
			 	num_digito = @num_digito
			WHERE num_cpf = @cnpj_cpf
	
	
			--Bloqueia a conta no SICC
			UPDATE SICC.dbo.c_autorizador_cliente
			SET dat_cheque_cobranca	= @data_movimento
			WHERE cod_emp = @cod_empresa and cod_fil = @cod_filial and num_cli = @cod_cliente
	
			UPDATE SICC.dbo.c_controle_saldo
			SET dat_cheque_cobranca = @data_movimento
			WHERE cod_emp = @cod_empresa and cod_fil = @cod_filial and num_cli = @cod_cliente

		END
		
		-- Incrementa o contador para a consulta na tabela temporária
		set @contador = @contador + 1
	
	END
	
	-- Altera o valor da última importação realizada. -----------------------------
	UPDATE tb_cobch_parametro
	   SET dat_ultima_importacao = @data_ultima_importacao
END

/* 
Descrição	: Consultar Cliente Funcionario
Autor		: Marcelo Brefore
Data		: 09/08/2006
Empresa		: B2Br
Projeto		: SICC New / sicc

Observações	: Em ambiente de testes é utilizado o servidor RIACHU_DBAUTC, database autcom
		  **** Em ambiente de produção é utilizado o servidor RIACHU_DBAUTC ****

*/



GO
