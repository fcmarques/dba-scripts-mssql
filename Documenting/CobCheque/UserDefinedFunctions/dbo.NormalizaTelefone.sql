SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE FUNCTION dbo.NormalizaTelefone(@telefone varchar(20))
RETURNS varchar(9)
AS
BEGIN
	DECLARE @tamanho int
	DECLARE @telefone_normalizado varchar(9)
	DECLARE @reduzido varchar(20)

	set @tamanho = LEN(@telefone)
	set @reduzido = Replace(@telefone,' ','')
	set @tamanho = LEN(@reduzido)
	if @tamanho>8
	BEGIN
		set @telefone_normalizado = SUBSTRING(@reduzido,@tamanho-7,@tamanho)
	END
	ELSE
	BEGIN
		set @telefone_normalizado = @reduzido
	END

	RETURN @telefone_normalizado
END


GO
