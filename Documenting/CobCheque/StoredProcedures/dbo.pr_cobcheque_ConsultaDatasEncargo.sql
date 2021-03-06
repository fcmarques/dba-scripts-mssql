SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição          : Stored Procedure para consultar datas Encargo
Autor                : Fernando S. Jaconete
Data                 : 22/09/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

Create proc dbo.pr_cobcheque_ConsultaDatasEncargo
	 @cod_empresa int
	,@cod_filial int
	,@TipoConsulta int
	,@dat_fim_vigencia	datetime = null
	,@num_dias_de		int = null
	,@num_dias_ate		int = null

as

set nocount on

declare @DataAtual smalldatetime, 
	@DataVigenciaFinal smalldatetime,
	@DataVigAtual smalldatetime, 
	@DataVigFutura smalldatetime, 
	@DataVigAnterior smalldatetime,
	@DataConsulta	smalldatetime

set  @DataAtual = getdate()
select @DataAtual = convert(varchar,@DataAtual,101)

-- Verifica a perído de vigencia em que se encontra a data atual
select   @DataVigAtual = dat_vigencia_inicial
	,@DataVigenciaFinal = dat_vigencia_final
from 
	tb_cobch_encargo (nolock)
where 
	cod_filial = @cod_filial
and 	cod_empresa = @cod_empresa
and 	@DataAtual between dat_vigencia_inicial and dat_vigencia_final

/* A partir da data atual descobre a data de vigencia inicial do periodo 
** imediantemente anterior a data atual 
*/
select @DataVigAnterior = (select Top 1 dat_vigencia_inicial
			   from 
				tb_cobch_encargo (nolock)
			   where 
				cod_filial = @cod_filial
			   and 	cod_empresa = @cod_empresa
			   and 	dat_vigencia_final < @DataVigAtual
			   order by dat_vigencia_inicial desc
			   )

/* A partir da data atual descobre a data de vigencia inicial do periodo 
** imediantemente posterior a data atual 
*/
select @DataVigFutura = (select Top 1 dat_vigencia_inicial
			   from 
				tb_cobch_encargo (nolock)

			   where 
				cod_filial = @cod_filial
			   and 	cod_empresa = @cod_empresa
			   and 	dat_vigencia_inicial > @DataVigenciaFinal
			   order by dat_vigencia_inicial desc
			   )


/* Joga em uma tabela temporária  os valores das variáveis
** que contêm as datas Atual, Futura e Passada
*/
select 
	 @DataVigAnterior	as Passada
	,@DataVigFutura 	as Futura
	,@DataVigAtual		as Atual
into 
	#Datas 

/*  
** Seleciona a data de acordo com o tipo de consulta informado na tela 
*/
if @TipoConsulta = 0
	select @DataConsulta = (select Passada from #Datas)
else if @TipoConsulta = 1
	select @DataConsulta = (select Atual from #Datas)
else if @TipoConsulta = 2
	select @DataConsulta = (select Futura from #Datas)


/* Consulta os descontos lancados em um determinado período a partir
** da data selecionada pelo tipo de consulta, sendo Atual ou Futura ou Passada
*/
Execute pr_CobCheque_ConsultarEncargosPorFilialVigencia @cod_empresa, @cod_filial, @DataConsulta, 
	@dat_fim_vigencia, @num_dias_de, @num_dias_ate

drop table #Datas

set nocount off


GO
