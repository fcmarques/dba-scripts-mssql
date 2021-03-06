SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE dbo.pr_CobCheque_IncluirFilialImplantacao

@cod_filial INT

AS

IF NOT EXISTS(SELECT TOP 1 
			1
		FROM
			dbo.tb_cobch_filial_implantacao (NOLOCK)
		WHERE
			cod_filial = @cod_filial)
	BEGIN
		/*
		** INSERE A FILIAL NA TABELA DE CONTROLE
		*/
		INSERT INTO dbo.tb_cobch_filial_implantacao
			(cod_filial
			,dat_implantacao)
		VALUES	
			(@cod_filial
			,GETDATE())

		/*
		** REALIZA A IMPORTACAO INICIAL
		*/
		execute dbo.pr_CobCheque_ImportaChequesEmCobrancaCargaInicial @cod_filial
	END



GO
