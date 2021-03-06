SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




/*
--------------------------------------------------------------------
Desenvolvido por: Fabio Costa
Data............: 30/06/2005
Objetivo........: Efetua Consulta dos Dados do Funcionßrio para o Gerenciamento
                  de acesso
--------------------------------------------------------------------
*/

-- TRANSFERIDO EM 24/11/2010 14:05:05
CREATE     procedure [dbo].[z_Teste] 
	@TipoPesquisa		varchar(1),
	@ConteudoPesquisa	varchar(60)

AS


if @TipoPesquisa = 'M'
Begin
	SELECT 		v.Num_pront,
			v.Nom_func,
			v.nom_fil,
			v.dat_admi,
			s.dt_atu,
			isnull(i.qtd,0) qtd
			
	
	FROM		v_func_dia_cad v
	
	left join
		c_senha_func s
	on
		s.num_pront = v.num_pront
	
	left join
		c_impressao_holerite i
	on
		i.num_pront = v.num_pront
		and ref = convert(char(4),year(getdate())) + CONVERT(CHAR(02), RIGHT('00' + LTRIM(month(getdate())), 2 ))
	
	WHERE	v.Num_pront = @ConteudoPesquisa
End

Else
Begin
	SELECT 		v.Num_pront,
			v.Nom_func,
			v.nom_fil,
			v.dat_admi,
			s.dt_atu,
			i.qtd
			
	
	FROM		v_func_dia_cad v
	
	left join
		c_senha_func s
	on
		s.num_pront = v.num_pront
	
	left join
		c_impressao_holerite i
	on
		i.num_pront = v.num_pront
		and ref = convert(char(4),year(getdate())) + CONVERT(CHAR(02), RIGHT('00' + LTRIM(month(getdate())), 2 ))
	
	WHERE	v.nom_func like '%' + @ConteudoPesquisa + '%'
End







GO
