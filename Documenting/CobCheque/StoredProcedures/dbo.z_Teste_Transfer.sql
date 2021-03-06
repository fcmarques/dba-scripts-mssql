SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF



-- TRANSFERIDO EM 18/11/2010 09:05:25
CREATE PROCEDURE [dbo].[z_Teste_Transfer]  AS

SELECT 	DR.Filial,
	DR.NumeroOCT,
	SUM(DS.ValorRecebidoCheque) AS VrRecCheque,
	SUM(DS.ValorRecebidoDinheiro) AS VrRecDinheiro
INTO #Recebimento
FROM M_RMB805 DR LEFT JOIN M_RMB803 DS ON DR.Filial = DS.Filial AND
					  DR.AnoSangria = DS.AnoSugestao AND
					  DR.MesSangria = DS.MesSugestao AND
					  DR.DiaSangria = DS.DiaSugestao AND
					  DR.HoraSangria = DS.HoraSugestao AND
					  DR.MinutoSangria = DS.MinutoSugestao AND
					  DR.SegundoSangria = DS.SegundoSugestao
GROUP BY DR.Filial, 
	 DR.NumeroOCT	 
ORDER BY DR.Filial, 
	 DR.NumeroOCT
	

SELECT 	R.Filial,
	R.NumeroOCT,
	R.AnoEmissao,
       	R.MesEmissao,
       	R.DiaEmissao,
	R.HoraEmissao,
	R.MinutoEmissao,
	R.SegundoEmissao,
	R.AnoMovto,
	R.MesMovto,
	R.DiaMovto,
	R.AnoCredito,
	R.MesCredito,
	R.DiaCredito,
	R.AnoLiberacao,
	R.MesLiberacao,
	R.DiaLiberacao,
	R.TipoNumerario,
	R.NumeroRelacaoCHQ,
	R.ValorOCT,
	C.Cod_Coleta,
	VrRecCheque,
	VrRecDinheiro
FROM (M_RMB804 R LEFT JOIN C_RMB_coletas_filial C ON R.Filial = C.Cod_Filial) 
		 LEFT JOIN #Recebimento VR ON R.Filial = VR.Filial AND
					      R.NumeroOCT = VR.NumeroOCT
ORDER BY R.Filial, 
	 R.NumeroOCT

drop table #Recebimento	



GO
