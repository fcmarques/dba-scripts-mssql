SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição          : Stored Procedure para consultar datas de Desconto
Autor                : Fernando S. Jaconete
Data                 : 22/09/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

CREATE proc dbo.pr_cobcheque_ConsultaDatasDesconto 
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

select   @DataVigAtual = dat_vigencia_inicial
	,@DataVigenciaFinal = dat_vigencia_final
from 
	tb_cobch_desconto (nolock)
where 
	cod_filial = @cod_filial
and 	cod_empresa = @cod_empresa
and 	@DataAtual between dat_vigencia_inicial and dat_vigencia_final

select @DataVigAnterior = (select Top 1 dat_vigencia_inicial
			   from 
				tb_cobch_desconto (nolock)
			   where 
				cod_filial = @cod_filial
			   and 	cod_empresa = @cod_empresa
			   and 	dat_vigencia_final < @DataVigAtual
			   order by dat_vigencia_inicial desc
			   )


select @DataVigFutura = (select Top 1 dat_vigencia_inicial
			   from 
				tb_cobch_desconto (nolock)  

			   where 
				cod_filial = @cod_filial
			   and 	cod_empresa = @cod_empresa
			   and 	dat_vigencia_inicial > @DataVigenciaFinal
			   order by dat_vigencia_inicial desc
			   )

select 
	 @DataVigAnterior	as Passada
	,@DataVigFutura 	as Futura
	,@DataVigAtual		as Atual
into 
	#Datas 

if @TipoConsulta = 0
	select @DataConsulta = (select Passada from #Datas)
else if @TipoConsulta = 1
	select @DataConsulta = (select Atual from #Datas)
else if @TipoConsulta = 2
	select @DataConsulta = (select Futura from #Datas)

Execute pr_CobCheque_ConsultarDescontosPorFilialVigencia @cod_empresa, @cod_filial, @DataConsulta, 
	@dat_fim_vigencia, @num_dias_de, @num_dias_ate

drop table #Datas

set nocount off



GO
