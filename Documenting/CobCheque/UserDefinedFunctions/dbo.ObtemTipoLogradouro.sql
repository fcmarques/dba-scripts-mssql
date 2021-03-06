SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER ON

CREATE FUNCTION dbo.ObtemTipoLogradouro(@logra varchar(11))
RETURNS @retorno table(tipo varchar(11), num_caract int)
AS
BEGIN
	DECLARE @tipo as varchar(11)
	Declare @cont as int	



	IF (SUBSTRING(@logra,1,9) = 'Aeroporto')	
	BEGIN
		set @tipo = 'Aeroporto'
		set @cont = 9		
	END
	ELSE IF (SUBSTRING(@logra,1,4) = 'Aer.') or (SUBSTRING(@logra,1,4) = 'Aer ')
	BEGIN
		set @tipo = 'Aeroporto'
		set @cont = 4		
	END
	ELSE IF SUBSTRING(@logra,1,6)='Acesso'
	BEGIN
		set @tipo = 'Acesso'		
		set @cont = 6		
	END
	ELSE IF SUBSTRING(@logra,1,3)='Ac.' or SUBSTRING(@logra,1,3)='Ac '
	BEGIN
		set @tipo = 'Acesso'		
		set @cont = 3		
	END

	ELSE IF SUBSTRING(@logra,1,7)='Alameda'
	BEGIN
		set @tipo = 'Alameda'		
		set @cont = 7		
	END
	ELSE IF SUBSTRING(@logra,1,3)='Al.' or SUBSTRING(@logra,1,3)='Al '
	BEGIN
		set @tipo = 'Alameda'		
		set @cont = 3		
	END
	ELSE IF	SUBSTRING(@logra,1,4) = 'Área' or SUBSTRING(@logra,1,4) = 'Area'
	BEGIN
		set @tipo = 'Área'		
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,3) = 'Ar.' or SUBSTRING(@logra,1,3) = 'Ar '
	BEGIN
		set @tipo = 'Área'		
		set @cont = 3
	END
	ELSE IF SUBSTRING(@logra,1,7) = 'Avenida'
	BEGIN
		set @tipo = 'Avenida'
		set @cont = 7
	END
	ELSE IF SUBSTRING(@logra,1,3) = 'Av.' or SUBSTRING(@logra,1,3) = 'Av ' or SUBSTRING(@logra,1,3) = 'Av='
	BEGIN
		set @tipo = 'Avenida'		
		set @cont = 3
	END
	ELSE IF SUBSTRING(@logra,1,5) = 'Campo'
	BEGIN
		set @tipo = 'Campo'		
		set @cont = 5
	END
	ELSE IF SUBSTRING(@logra,1,7) = 'Chácara' or SUBSTRING(@logra,1,7) = 'Chacara'
	BEGIN
		set @tipo = 'Chácara'
		set @cont = 7
	END
	ELSE IF SUBSTRING(@logra,1,3) = 'Ch.' or SUBSTRING(@logra,1,3) = 'Ch '
	BEGIN
		set @tipo = 'Chácara'
		set @cont = 3
	END
	ELSE IF SUBSTRING(@logra,1,7) = 'Colônia' or SUBSTRING(@logra,1,7) = 'Colonia'
	BEGIN
		set @tipo = 'Colônia'
		set @cont = 7
	END
	ELSE IF SUBSTRING(@logra,1,10) = 'Condomínio' or SUBSTRING(@logra,1,10) = 'Condominio'
	BEGIN
		set @tipo = 'Condomínio'
		set @cont = 10
	END
	ELSE IF SUBSTRING(@logra,1,5) = 'Cond.' or SUBSTRING(@logra,1,5) = 'Cond '
	BEGIN
		set @tipo = 'Condomínio'
		set @cont = 5
	END
	ELSE IF SUBSTRING(@logra,1,8) = 'Conjunto'
	BEGIN
		set @tipo = 'Conjunto'
		set @cont = 8
	END
	ELSE IF SUBSTRING(@logra,1,5) = 'Conj.' or SUBSTRING(@logra,1,5) = 'Conj '
	BEGIN
		set @tipo = 'Conjunto'	
		set @cont = 5
	END
	ELSE IF SUBSTRING(@logra,1,8) = 'Distrito'
	BEGIN
		set @tipo = 'Distrito'	
		set @cont = 8
	END
	ELSE IF SUBSTRING(@logra,1,5) = 'Dist.' or SUBSTRING(@logra,1,5) = 'Dist '
	BEGIN
		set @tipo = 'Distrito'
		set @cont = 5
	END
	ELSE IF SUBSTRING(@logra,1,9) = 'Esplanada'
	BEGIN
		set @tipo = 'Esplanada'
		set @cont = 9
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Esp ' or SUBSTRING(@logra,1,4) = 'Esp.'
	BEGIN
		set @tipo = 'Esplanada'
		set @cont = 4
	END	
	ELSE IF SUBSTRING(@logra,1,7) = 'Estação' or SUBSTRING(@logra,1,7) = 'Estacao' or SUBSTRING(@logra,1,7) = 'Estaçao' or SUBSTRING(@logra,1,7) = 'Estacão'
	BEGIN
		set @tipo = 'Estação'
		set @cont = 7
	END
	ELSE IF SUBSTRING(@logra,1,7) = 'Estrada'
	BEGIN
		set @tipo = 'Estrada'
		set @cont = 7
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Est ' or SUBSTRING(@logra,1,4) = 'Est.'
	BEGIN
		set @tipo = 'Estrada'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,6) = 'Favela'
	BEGIN
		set @tipo = 'Favela'
		set @cont = 6
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Fav.' or SUBSTRING(@logra,1,4) = 'Fav '
	BEGIN
		set @tipo = 'Favela'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,7) = 'Fazenda'
	BEGIN
		set @tipo = 'Fazenda'
		set @cont = 7
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Faz.' or SUBSTRING(@logra,1,4) = 'Faz '
	BEGIN
		set @tipo = 'Fazenda'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,5) = 'Feira'
	BEGIN
		set @tipo = 'Feira'
		set @cont = 5
	END
	ELSE IF SUBSTRING(@logra,1,6) = 'Jardim'
	BEGIN
		set @tipo = 'Jardim'
		set @cont = 6
	END
	ELSE IF SUBSTRING(@logra,1,3) = 'Jd.' or SUBSTRING(@logra,1,3) = 'Jd '
	BEGIN
		set @tipo = 'Jardim'
		set @cont = 3
	END
	ELSE IF SUBSTRING(@logra,1,7) = 'Ladeira'
	BEGIN
		set @tipo = 'Ladeira'
		set @cont = 7
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Lad.' or SUBSTRING(@logra,1,4) = 'Lad '
	BEGIN
		set @tipo = 'Ladeira'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,3) = 'Ld.' or SUBSTRING(@logra,1,3) = 'Ld '
	BEGIN
		set @tipo = 'Ladeira'
		set @cont = 3
	END
	ELSE IF SUBSTRING(@logra,1,5) = 'Lagoa'
	BEGIN
		set @tipo = 'Lagoa'
		set @cont = 5
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Lago'
	BEGIN
		set @tipo = 'Lago'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,5) = 'Largo'
	BEGIN
		set @tipo = 'Largo'
		set @cont = 5
	END
	ELSE IF SUBSTRING(@logra,1,3) = 'Lg.' or SUBSTRING(@logra,1,3) = 'Lg '
	BEGIN
		set @tipo = 'Largo'
		set @cont = 3
	END

	ELSE IF SUBSTRING(@logra,1,10) = 'Loteamento'
	BEGIN
		set @tipo = 'Loteamento'
		set @cont = 10
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Lot.' or SUBSTRING(@logra,1,4) = 'Lot '
	BEGIN
		set @tipo = 'Loteamento'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,5) = 'Morro'
	BEGIN
		set @tipo = 'Morro'
		set @cont = 5
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Mor.' or SUBSTRING(@logra,1,4) = 'Mor '
	BEGIN
		set @tipo = 'Morro'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,6) = 'Núcleo' or SUBSTRING(@logra,1,6) = 'Nucleo'
	BEGIN
		set @tipo = 'Núcleo'
		set @cont = 6
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Nuc.' or SUBSTRING(@logra,1,4) = 'Nuc '
	BEGIN
		set @tipo = 'Núcleo'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,6) = 'Parque'
	BEGIN
		set @tipo = 'Parque'
		set @cont = 6
	END
	ELSE IF SUBSTRING(@logra,1,3) = 'Pq.' or SUBSTRING(@logra,1,3) = 'Pq '
	BEGIN
		set @tipo = 'Parque'
		set @cont = 3
	END
	ELSE IF SUBSTRING(@logra,1,9) = 'Passarela'
	BEGIN
		set @tipo = 'Passarela'
		set @cont = 9
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Pas.' or SUBSTRING(@logra,1,4) = 'Pas '
	BEGIN
		set @tipo = 'Passarela'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,5) = 'Pátio' or SUBSTRING(@logra,1,5) = 'Patio'
	BEGIN
		set @tipo = 'Pátio'
		set @cont = 5
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Pat.' or SUBSTRING(@logra,1,4) = 'Pát.' or SUBSTRING(@logra,1,4) = 'Pat ' or SUBSTRING(@logra,1,4) = 'Pát '
	BEGIN
		set @tipo = 'Pátio'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,5) = 'Praça' or SUBSTRING(@logra,1,5) = 'Praca'
	BEGIN
		set @tipo = 'Praça'
		set @cont = 5
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Pca ' or SUBSTRING(@logra,1,4) = 'Pça ' or SUBSTRING(@logra,1,4) = 'Pca.' or SUBSTRING(@logra,1,4) = 'Pça.'
	BEGIN
		set @tipo = 'Praça'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,7) = 'Quadra '
	BEGIN
		set @tipo = 'Quadra'
		set @cont = 7
	END
	ELSE IF SUBSTRING(@logra,1,3) = 'Qd.' or SUBSTRING(@logra,1,3) = 'Qd '
	BEGIN
		set @tipo = 'Quadra'
		set @cont = 3
	END
	ELSE IF SUBSTRING(@logra,1,7) = 'Recanto'
	BEGIN
		set @tipo = 'Recanto'
		set @cont = 7
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Rec.' or SUBSTRING(@logra,1,4) = 'Rec '
	BEGIN
		set @tipo = 'Recanto'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,11) = 'Residecial'
	BEGIN
		set @tipo = 'Residencial'
		set @cont = 11
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Res.' or SUBSTRING(@logra,1,4) = 'Res '
	BEGIN
		set @tipo = 'Residencial'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,7) = 'Rodovia'
	BEGIN
		set @tipo = 'Rodovia'
		set @cont = 7
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Rod.' or SUBSTRING(@logra,1,4) = 'Rod '
	BEGIN
		set @tipo = 'Rodovia'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Rua '
	BEGIN
		set @tipo = 'Rua'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,2) = 'R ' or SUBSTRING(@logra,1,2) = 'R.'
	BEGIN
		set @tipo = 'Rua'
		set @cont = 2
	END
	ELSE IF SUBSTRING(@logra,1,5) = 'Setor'
	BEGIN
		set @tipo = 'Setor'
		set @cont = 5
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Set.' or SUBSTRING(@logra,1,4) = 'Set '
	BEGIN
		set @tipo = 'Setor'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,5) = 'Sítio' or SUBSTRING(@logra,1,5) = 'Sitio'
	BEGIN
		set @tipo = 'Sítio'
		set @cont = 5
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Sít.' or SUBSTRING(@logra,1,4) = 'Sit.' or SUBSTRING(@logra,1,4) = 'Sít ' or SUBSTRING(@logra,1,4) = 'Sít.'
	BEGIN
		set @tipo = 'Sítio'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,8) = 'Travessa'
	BEGIN
		set @tipo = 'Travessa'
		set @cont = 8
	END
	ELSE IF SUBSTRING(@logra,1,5) = 'Trav.' or SUBSTRING(@logra,1,5) = 'Trav '
	BEGIN
		set @tipo = 'Travessa'
		set @cont = 5
	END
	ELSE IF SUBSTRING(@logra,1,3) = 'Tv.' or SUBSTRING(@logra,1,5) = 'Tv '
	BEGIN
		set @tipo = 'Travessa'
		set @cont = 3
	END
	ELSE IF SUBSTRING(@logra,1,6) = 'Trecho'
	BEGIN
		set @tipo = 'Trecho'
		set @cont = 6
	END
	ELSE IF SUBSTRING(@logra,1,3) = 'Tr.' or SUBSTRING(@logra,1,3) = 'Tr '
	BEGIN
		set @tipo = 'Trecho'
		set @cont = 3
	END
	ELSE IF SUBSTRING(@logra,1,5) = 'Trevo'
	BEGIN
		set @tipo = 'Trevo'
		set @cont = 5
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Vale'
	BEGIN
		set @tipo = 'Vale'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,6) = 'Vereda'
	BEGIN
		set @tipo = 'Vereda'
		set @cont = 6
	END
	ELSE IF SUBSTRING(@logra,1,3) = 'Via'
	BEGIN
		set @tipo = 'Via'
		set @cont = 3
	END
	ELSE IF SUBSTRING(@logra,1,7) = 'Viaduto'
	BEGIN
		set @tipo = 'Viaduto'
		set @cont = 7
	END
	ELSE IF SUBSTRING(@logra,1,3) = 'Vd.' or SUBSTRING(@logra,1,3) = 'Vd '
	BEGIN
		set @tipo = 'Viaduto'
		set @cont = 3
	END
	ELSE IF SUBSTRING(@logra,1,5) = 'Viela'
	BEGIN
		set @tipo = 'Viela'
		set @cont = 5
	END
	ELSE IF SUBSTRING(@logra,1,4) = 'Vila'
	BEGIN
		set @tipo = 'Vila'
		set @cont = 4
	END
	ELSE IF SUBSTRING(@logra,1,3) = 'Vl ' or SUBSTRING(@logra,1,3) = 'Vl.'
	BEGIN
		set @tipo = 'Vila'
		set @cont = 3
	END
	ELSE 
	BEGIN
		set @tipo = 'Outros'		
		set @cont = 0
	END

	INSERT INTO @RETORNO
		SELECT @tipo tipo, @cont
RETURN
END


GO
