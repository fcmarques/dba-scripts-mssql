SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- USE COBCHEQUE
-- GO
-- IF EXISTS(SELECT name FROM sysobjects
--       WHERE name = 'pr_CobCheque_LancarLucrosPerdasSAP')
--    DROP PROCEDURE dbo.pr_CobCheque_LancarLucrosPerdasSAP
-- GO

/* 
DescriþÒo          : Stored Procedure realizar o lanþamento de lucros e perdas do SAP
Autor              : Fernando S. Jaconete
Data               : 22/09/2006
Empresa            : B2Br
Projeto            : CobCheque
*/


-- TRANSFERIDO EM 12/03/2007 10:12:35
CREATE  PROCEDURE dbo.pr_CobCheque_LancarLucrosPerdasSAP

AS
	
-- DeclaraþÒo das varißveis utilizadas durante todo a procedure
declare @tbrows	int
	, @contador int
	, @num_cheque varchar(20)
	, @num_cpf decimal(15,0)
	, @dat_lucros_perdas datetime

-- DeclaraþÒo da tabela temporßria de Lucros e Perdas SAP
declare @tb_sap table (
		contador 		int identity(1,1)
		,num_cheque		varchar(20)
		,num_cpf		decimal(15,0)
		,cod_filial		int
		,cod_banco		decimal(5,0)
		,dat_movimento		datetime
		,val_cheque		decimal(12,2)
		,dat_lucros_perdas	datetime
	)

-- InserþÒo dos dados na tabela temporßria de Lucros e Perdas SAP
insert into @tb_sap (num_cheque,
		num_cpf,
		cod_filial,
		cod_banco,
		dat_movimento,
		val_cheque,
		dat_lucros_perdas)
	select num_cheque,
		num_cpf,
		cod_filial,
		cod_banco,
		dat_movimento,
		val_cheque,
		dat_lucros_perdas
	from tb_cobch_lucros_perdas

-- Verifica quantas linhas a tabela SAP possui.
select @tbrows = count(num_cheque) from tb_cobch_lucros_perdas

-- Varißvel para percorrer a tabela SAP
set @contador = 1

-- Trabalha todas as tuplas da tabela SAP.
WHILE (@contador <= @tbrows)
BEGIN
	-- Coloca os valores da tupla nas varißveis.
	SELECT @num_cheque = num_cheque, 
		@num_cpf = num_cpf, 
		@dat_lucros_perdas = dat_lucros_perdas
	from @tb_sap
	where contador = @contador

	--Atualiza o valor da data de negociacao de lucros e perdas.
	UPDATE CobCheque.dbo.tb_cobch_cheque
	SET dat_lucros_perdas = @dat_lucros_perdas
	WHERE num_cheque = @num_cheque and num_cpf = @num_cpf

-- Incrementa o contador para a pr¾xima consulta na tabela temporßria
SET @contador = @contador + 1
END




GO
